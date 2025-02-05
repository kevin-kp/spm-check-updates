//
//  Cli+Dry.swift
//  spm-check-updates
//
//  Created by Kevin Pittevils on 29/01/2025.
//

import ArgumentParser
import Foundation

extension Cli {
    struct Dry: ParsableCommand {
        @Argument(help: "The path of the directory that contains an xcodeproj or swift package.")
        var path: String
    }
}

extension Cli.Dry {
    mutating func run() throws {
        print("[DRY RUN] start")
        let workspace = try XcodeWorkspace.Factory().create(from: path)
        let entries = workspace.upgradeEntries()
        for entry in entries {
            if entry.allowedUntil < entry.upgrade {
                print(
                    "[UPGRADE] New upgrade available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
                )
            } else {
                print(
                    "[UPDATE] new update available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
                )
            }
        }
        print("[DRY RUN] done")
    }
}
