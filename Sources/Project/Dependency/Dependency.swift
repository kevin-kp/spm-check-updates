//
//  Dependency.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

enum Dependency: Decodable {
    case fileSystem([PackageDescription.FileSystemEntry])
    case sourceControl([PackageDescription.SourceControlEntry])

    enum CodingKeys: String, CodingKey {
        case fileSystem
        case sourceControl
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let key = container.allKeys.first
        switch key {
        case .fileSystem:
            let entries = try container.decode(
                [PackageDescription.FileSystemEntry].self,
                forKey: .fileSystem
            )
            self = .fileSystem(entries)
        case .sourceControl:
            let entries = try container.decode(
                [PackageDescription.SourceControlEntry].self,
                forKey: .sourceControl
            )
            self = .sourceControl(entries)
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unabled to decode enum"
                )
            )
        }
    }
}

extension PackageDescription {
    struct FileSystemEntry: Decodable {
        let path: String
        let identity: String
    }

    struct SourceControlEntry: Decodable {
        let identity: String
        let requirement: Dependency.Requirement
        let location: PackageDescription.Location
    }

    struct Location: Decodable {
        let remote: [Remote]
    }
}

extension PackageDescription.Location {
    struct Remote: Decodable {
        let urlString: String
    }
}
