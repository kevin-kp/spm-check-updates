//
//  Cli+Interactive.swift
//  spm-check-updates
//
//  Created by Kevin Pittevils on 29/01/2025.
//

import ArgumentParser
import Foundation
import PathKit
import XcodeProj

extension Cli {
    struct Interactive: ParsableCommand {
        @Argument(help: "The path of the directory that contains an xcodeproj or swift package.")
        var path: String
    }
}

extension Cli.Interactive {
    mutating func run() throws {
        print("[INTERACTIVE] start")
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
            print("Do you want to apply the update for \(entry.identity)? (yes|no)")
            let shouldApplyUpdate = readLine()?.lowercased().starts(with: "y") ?? false
            guard shouldApplyUpdate else { return }
            try workspace.apply(upgradePins: Updater().get(for: entry), for: entry)
            do { try workspace.writeResolvements() } catch { return }
        }
        print("[INTERACTIVE] done")
    }
}
