//
//  XcodeWorkspace+Factory.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation
import PathKit

extension XcodeWorkspace {
    struct Factory {
        func create(from path: String) throws -> XcodeWorkspace {
            let contents = try FileManager.default
                .contentsOfDirectory(atPath: path)
            return if let workspace = contents
                .first(where: { $0.contains(".xcworkspace") }) {
                try XcodeWorkspace(pathString: .init("\(path)/\(workspace)"))
            } else if let project = contents.first(where: { $0.contains(".xcodeproj") }) {
                try createFromXcodeProject(path: path, project: project)
            } else if let packagePath = contents.first(where: { $0 == "Package.swift" }) {
                try Shell.getPackageWorkspace(at: "\(path)/\(packagePath)")
            } else {
                print("Cannot find .xcodeproj or Package.swift in the current directory")
                throw UpdateCheckError.noProjectFileFound
            }
        }
    }
}

private extension XcodeWorkspace.Factory {
    func createFromXcodeProject(path: String, project: String) throws -> XcodeWorkspace {
        let path = Path("\(path)/\(project)")
        return try XcodeWorkspace(forXcodeProject: XcodeProject(path: path), at: path)
    }
}
