//
//  XcodeProject.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation
import PathKit
import XcodeProj

final class XcodeProject: Project {
    let path: Path 
    let proj: XcodeProj
    var sharedData: SharedWorkspaceData

    let dependencies: [Dependency]

    var resolvements: PackageResolvements? {
        get { return sharedData.packageResolvement }
        set { sharedData.packageResolvement = newValue }
    }

    init(path: Path) throws {
        self.path = path
        proj = try XcodeProj(path: path)
        let sharedDataPath = path + "xcshareddata"
        sharedData = try SharedWorkspaceData(path: sharedDataPath)
        let localDependencies: [Dependency] = proj.pbxproj.rootObject?.localPackages
            .compactMap { package in
                guard let name = package.name else { return nil }
                return .fileSystem([.init(path: package.relativePath, identity: name)])
            } ?? []
        let remoteDependencies: [Dependency] = proj.pbxproj.rootObject?.remotePackages
            .compactMap { package in
                guard let name = package.name else { return nil }
                guard let url = package.repositoryURL else { return nil }
                guard let requirement = try? package.versionRequirement?.asDependencyRequirement()
                else { return nil }
                return .sourceControl([.init(
                    identity: name,
                    requirement: requirement,
                    location: .init(remote: [.init(urlString: url)])
                )])
            } ?? []
        var dependencies: [Dependency] = []
        dependencies.append(contentsOf: localDependencies)
        dependencies.append(contentsOf: remoteDependencies)
        self.dependencies = dependencies
    }
}
