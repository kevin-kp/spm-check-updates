//
//  Cli+UpdateAll.swift
//  spm-check-updates
//
//  Created by Kevin Pittevils on 30/01/2025.
//

import ArgumentParser
import Foundation
import PathKit
import XcodeProj

extension Cli {
    struct UpdateAll: ParsableCommand {
        @Argument(help: "The path of the directory that contains an xcodeproj or swift package.")
        var path: String
    }
}

extension Cli.UpdateAll {
    mutating func run() throws {
        print("[UPDATE ALL] start")
        let workspace = try XcodeWorkspace.Factory().create(from: path)
        let entries = workspace.upgradeEntries()
        try entries.forEach { entry in
            if entry.allowedUntil < entry.upgrade {
                print(
                    "[UPGRADE] New upgrade available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
                )
            } else {
                print(
                    "[UPDATE] new update available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
                )
            }
            print("Updating \(entry.identity)...")
            try workspace.apply(upgradePins: Updater().get(for: entry), for: entry)
            do { try workspace.writeResolvements() } catch { return }
        }
        print("[UPDATE ALL] done")
    }
}
