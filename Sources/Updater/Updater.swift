//
//  Updater.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

struct Updater {

    func get(for entry: UpgradeEntry) throws -> [PackageResolvements.Pin] {
        let contents = contents(for: entry)
        let url = try write(contents: contents)
        let packagePath = url.deletingLastPathComponent()
        Shell(command: "swift package resolve --package-path \(packagePath.path())").run()
        let workspace = try Shell.getPackageWorkspace(at: packagePath.path())
        guard let pins = workspace.packageProjects.first?.resolvements?.pins else {
            throw UpdateCheckError.updateResolvementFailed
        }
        return pins
    }

    private func write(contents: String) throws -> URL {
        let fileManager = FileManager.default
        let tempDirURL = fileManager.temporaryDirectory
        let tempFileURL = tempDirURL.appendingPathComponent("Package").appendingPathExtension("swift")
        // Write to temporary file
        try contents.write(to: tempFileURL, atomically: true, encoding: .utf8)
        return tempFileURL
    }

    private func contents(for entry: UpgradeEntry) -> String {
        return """
        // swift-tools-version:5.10
        import PackageDescription

        let package = Package(
            name: "Test",
            dependencies: [
                .package(url: "\(entry.repository)", exact: "\(entry.upgrade)")
            ],
            targets: [
                .target(
                    name: "Test",
                    dependencies: ["\(entry.identity)"]
                ),
            ]
        )
        """
    }
}
