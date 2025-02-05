//
//  Version.swift
//  
//
//  Created by Kevin Pittevils on 10/06/2024.
//

import Foundation

struct Version: Codable, Hashable {
    let major: Int
    let minor: Int
    let patch: Int

    init(version: String) throws {
        let components = version.split(separator: ".")
        guard components.count == 3 || components.count == 4 else { throw Error.invalidVersion }

        try self.init(major: String(components[0]),
                  minor: String(components[1]),
                  patch: String(components[2]))
    }

    init(major: String, minor: String, patch: String) throws {
        guard
            let majorAsInt = Int(major),
            let minorAsInt = Int(minor),
            let patchAsInt = Int(patch)
        else {
            throw Error.invalidVersion
        }

        self.init(major: majorAsInt,
                  minor: minorAsInt,
                  patch: patchAsInt)
    }

    init(major: Int, minor: Int, patch: Int) {
        self.major = major
        self.minor = minor
        self.patch = patch
    }
}

extension Version {
    enum Error: Swift.Error {
        case invalidVersion
    }
}

extension Version: Comparable {
    static func < (lhs: Version, rhs: Version) -> Bool {
        return (lhs.major < rhs.major)
            || (lhs.major == rhs.major && lhs.minor < rhs.minor)
            || (lhs.major == rhs.major && lhs.minor == rhs.minor && lhs.patch < rhs.patch)
    }
}

extension Version: CustomStringConvertible {
    var description: String {
        return "\(major).\(minor).\(patch)"
    }
}

extension Version {
    var nextMinor: Version {
        return .init(major: major, minor: minor + 1, patch: 0)
    }

    var nextMajor: Version {
        return .init(major: major + 1, minor: 0, patch: 0)
    }

    var nextPatch: Version {
        return .init(major: major, minor: minor, patch: patch + 1)
    }
}
