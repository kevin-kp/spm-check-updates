//
//  SharedWorkspaceData.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation
import PathKit
import XcodeProj

struct SharedWorkspaceData {
    private let path: Path

    let sharedData: XCSharedData?
    var packageResolvement: PackageResolvements?

    // MARK: - Init

    init(path: Path) throws {
        self.path = path
        sharedData = try? XCSharedData(path: path)
        let resolvedPath = path + "swiftpm"
        guard let pbxprojPath = try? resolvedPath.children()
            .first(where: { $0.lastComponent == "Package.resolved" }) else {
            packageResolvement = nil
            return
        }
        let data = try Data(contentsOf: pbxprojPath.url)
        packageResolvement = try JSONDecoder().decode(PackageResolvements.self, from: data)
    }
}

extension SharedWorkspaceData {
    func writeResolvements() throws {
        guard var packageResolvement else { return }
        let resolvedPath = path + "swiftpm"
        guard let pbxprojPath = try? resolvedPath.children()
            .first(where: { $0.lastComponent == "Package.resolved" }) else {
            return
        }
        packageResolvement.pins = packageResolvement.pins.sorted(by: { $0.identity < $1.identity })
        let encoder = JSONEncoder()
        encoder.outputFormatting = .init(arrayLiteral: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        let data = try encoder.encode(packageResolvement)
        try data.write(to: pbxprojPath.url)
    }
}
