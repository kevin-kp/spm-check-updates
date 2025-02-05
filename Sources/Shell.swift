//
//  Shell.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

struct Shell {
    private let command: String

    init(command: String) {
        self.command = command
    }

    @discardableResult
    func run() -> String {
        let task = Process()
        let pipe = Pipe()

        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.standardInput = nil
        task.launch()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!

        return output
    }
}


extension Shell {
    static func getPackageProject(at path: String) throws -> PackageProject {
        let result = Shell(command: "swift package --package-path \(path) dump-package").run()
        let decoded = try JSONDecoder().decode(
            PackageDescription.self,
            from: result.data(using: .utf8)!
        )
        var resolvements: PackageResolvements?
        if let value = (try? String(contentsOfFile: "\(path)/Package.resolved"))?
            .data(using: .utf8) {
            resolvements = try? JSONDecoder().decode(PackageResolvements.self, from: value)
        }
        return PackageProject(package: decoded, resolvements: resolvements)
    }

    static func getPackageWorkspace(at path: String) throws -> XcodeWorkspace {
        let package = try getPackageProject(at: path)
        return XcodeWorkspace(forPackage: package, at: .init(path))
    }
}

extension Shell {
    static func getLatestRepositoryVersion(repo: String, upperbound: Version? = nil) -> Version? {
        let versionRegex = "([0-9]+\\.[0-9]+\\.[0-9]+(\\.[0-9]+)?)"
        guard let filterRegex = try? Regex("refs/tags/v?\(versionRegex)$") else { return nil }
        guard let regex = try? Regex("\(versionRegex)$") else { return nil }
        let v1 = Shell(command: "git ls-remote --tags \(repo)").run()

        let versionComponents = v1.components(separatedBy: CharacterSet.newlines)

        let versions: [Version] = versionComponents.compactMap { line in
            guard (try? filterRegex.firstMatch(in: line)) != nil else { return nil }
            guard let match = try? regex.firstMatch(in: line) else { return nil }
            return try? Version(version: String(line[match.range]))
        }
        guard let upperbound else { return versions.max() }
        return versions.filter { $0 < upperbound }.max()
    }
}
