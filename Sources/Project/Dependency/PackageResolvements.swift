//
//  PackageResolvements.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

struct PackageResolvements: Codable {
    let originHash: String?
    var pins: [Pin]
    let version: Int
}

extension PackageResolvements {
    struct Pin: Codable {
        let identity: String
        let kind: Kind
        let location: String
        let state: State
    }
}

extension PackageResolvements.Pin {
    enum Kind: String, Codable {
        case remoteSourceControl
    }

    struct State: Codable {
        let revision: String
        let version: String?
        let branch: String?

        var versionObject: Version? {
            guard let version else { return nil }
            return try? .init(version: version)
        }
    }
}
