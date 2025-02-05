//
//  UpgradeEntry.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

struct UpgradeEntry: Hashable {
    let identity: String
    let repository: String
    let current: Version
    let allowedUntil: Version
    let upgrade: Version
    let location: Location
}

extension UpgradeEntry {
    enum Location: Hashable {
        case project
        case workspace
    }
}
