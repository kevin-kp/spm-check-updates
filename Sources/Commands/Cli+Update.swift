//
//  Cli+Update.swift
//  spm-check-updates
//
//  Created by Kevin Pittevils on 29/01/2025.
//

import ArgumentParser
import Foundation
import PathKit
import XcodeProj

extension Cli {
    struct Update: ParsableCommand {
        @Argument(help: "The path of the directory that contains an xcodeproj or swift package.")
        var path: String

        @Argument(help: "The dependency that needs to be updated.")
        var dependency: String
    }
}

extension Cli.Update {
    mutating func run() throws {
        print("[UPDATE] start")
        let workspace = try XcodeWorkspace.Factory().create(from: path)
        guard let entry = workspace.upgradeEntries().first(where: { $0.identity == dependency }) else {
            print("No update available for \(dependency)")
            return
        }

        if entry.allowedUntil < entry.upgrade {
            print(
                "[UPGRADE] New upgrade available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
            )
        } else {
            print(
                "[UPDATE] new update available for \(entry.identity): [\(entry.current)] -> \(entry.upgrade)"
            )
        }
        print("updating \(entry.identity)...")
        try workspace.apply(upgradePins: Updater().get(for: entry), for: entry)
        do { try workspace.writeResolvements() } catch { return }
        print("[UPDATE] done")
    }
}
