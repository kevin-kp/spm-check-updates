//
//  Dependency+Requirement.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation
import XcodeProj

extension Dependency {
    enum Requirement: Decodable, Equatable {
        case exact(version: Version)
        case revision(revision: String)
        case branch(name: String)
        case range(range: Range)

        enum CodingKeys: String, CodingKey {
            case exact
            case revision
            case branch
            case range
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let key = container.allKeys.first
            switch key {
            case .exact:
                self = .exact(version: try container.decodeUnkeyedVersion(forKey: .exact))
            case .revision:
                self = .revision(revision: try container.decodeUnkeyedString(forKey: .revision))
            case .branch:
                self = .branch(name: try container.decodeUnkeyedString(forKey: .branch))
            case .range:
                var unkeyedContainer = try container.nestedUnkeyedContainer(forKey: .range)
                self = .range(range: try unkeyedContainer.decode(Range.self))
            default:
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Cannot decode Dependency.Requirement"
                    )
                )
            }
        }
    }
}

extension Dependency.Requirement {
    struct Range: Decodable, Equatable {
        let lowerBound: Version
        let upperBound: Version
    }
}

extension Dependency.Requirement.Range {
    enum CodingKeys: String, CodingKey {
        case lowerBound
        case upperBound
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.lowerBound = try container.decodeVersion(forKey: .lowerBound)
        self.upperBound = try container.decodeVersion(forKey: .upperBound)
    }
}


private extension KeyedDecodingContainer {
    func decodeVersion(forKey key: Key) throws -> Version {
        let versionString = try decode(String.self, forKey: key)
        return try Version(version: versionString)
    }

    func decodeUnkeyedVersion(forKey key: Key) throws -> Version {
        var unkeyedContainer = try nestedUnkeyedContainer(forKey: key)
        let versionString = try unkeyedContainer.decode(String.self)
        return try Version(version: versionString)
    }

    func decodeUnkeyedString(forKey key: Key) throws -> String {
        var unkeyedContainer = try nestedUnkeyedContainer(forKey: key)
        return try unkeyedContainer.decode(String.self)
    }
}

extension XCRemoteSwiftPackageReference.VersionRequirement {
    func asDependencyRequirement() throws -> Dependency.Requirement {
        switch self {
        case let .upToNextMajorVersion(string):
            let version = try Version(version: string)
            return .range(range: .init(lowerBound: version, upperBound: version.nextMajor))
        case let .upToNextMinorVersion(string):
            let version = try Version(version: string)
            return .range(range: .init(lowerBound: version, upperBound: version.nextMinor))
        case let .range(from, to):
            let fromVersion = try Version(version: from)
            let toVersion = try Version(version: to)
            return .range(range: .init(lowerBound: fromVersion, upperBound: toVersion))
        case let .exact(string):
            return try .exact(version: Version(version: string))
        case let .branch(string):
            return .branch(name: string)
        case let .revision(string):
            return .revision(revision: string)
        }
    }
}
