//
//  XcodeWorkspace.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation
import PathKit
import XcodeProj

final class XcodeWorkspace {
    private let path: Path

    let workspace: XCWorkspace
    /// Shared data.
    var sharedData: SharedWorkspaceData?

    /// User data.
    let userData: [XCUserData]

    private(set) var xcodeProjects: [XcodeProject] = []
    private(set) var packageProjects: [PackageProject] = []

    public var allProjects: [Project] {
        return xcodeProjects + packageProjects
    }

    // MARK: - Init

    init(forXcodeProject project: XcodeProject, at path: Path) {
        self.path = path
        workspace = XCWorkspace()
        sharedData = nil
        userData = []
        xcodeProjects = [project]
    }

    init(forPackage package: PackageProject, at path: Path) {
        self.path = path
        workspace = XCWorkspace()
        sharedData = nil
        userData = []
        packageProjects = [package]
    }

    init(path: Path) throws {
        self.path = path
        workspace = try XCWorkspace(path: path)
        let sharedDataPath = path + "xcshareddata"
        sharedData = try SharedWorkspaceData(path: sharedDataPath)
        let userDataPath = path + "xcuserdata"
        userData = XCUserData.path(userDataPath)
            .glob("*.xcuserdatad")
            .compactMap { try? XCUserData(path: $0) }
        try workspace.data.children.forEach { child in
            switch child.location {
            case let .group(string):
                let projectPath = path + ".." + string
                guard let contents = try? FileManager.default
                    .contentsOfDirectory(atPath: projectPath.string) else { return }
                for group in contents {
                    if group.contains(".pbxproj"), let proj = try? XcodeProject(path: projectPath) {
                        xcodeProjects.append(proj)
                    } else if group.contains("Package.swift") {
                        let package = try Shell.getPackageProject(at: projectPath.string)
                        packageProjects.append(package)
                    }
                }
            default:
                break
            }
        }
    }

    convenience init(pathString: String) throws {
        try self.init(path: Path(pathString))
    }
}

extension XcodeWorkspace {
    func writeResolvements() throws {
        try sharedData?.writeResolvements()
    }
}

extension XcodeWorkspace {
    func apply(upgradePins: [PackageResolvements.Pin], for entry: UpgradeEntry) {
        if sharedData?.packageResolvement?.pins
            .first(where: { $0.identity == entry.identity }) != nil {
            print("replaced pin in workspace")
            var pins = sharedData?.packageResolvement?.pins ?? []
            for pin in upgradePins {
                pins = pins.filter { $0.identity != pin.identity }
                pins.append(pin)
            }
            sharedData?.packageResolvement?.pins = pins
        }
        for project in allProjects {
            if project.resolvements?.pins.first(where: { $0.identity == entry.identity }) != nil {
                print("replaced pin in project")
                var pins = project.resolvements?.pins ?? []
                for pin in upgradePins {
                    pins = pins.filter { $0.identity != pin.identity }
                    pins.append(pin)
                }
                project.resolvements?.pins = pins
            }
        }
    }
}
