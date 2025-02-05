//
//  XcodeWorkspace+UpgradeEntry.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

extension XcodeWorkspace {
    func upgradeEntries() -> Set<UpgradeEntry> {
        var entries: Set<UpgradeEntry> = []
        for project in allProjects {
            for dependency in project.dependencies {
                guard let range = dependency.asRange() else { continue }
                let entry = range.entry
                guard let pinResult = resolvement(identity: entry.identity, for: project)
                else { continue }
                let resolvement = pinResult.pin
                guard let url = entry.location.remote.first?.urlString else { continue }
                guard let current = resolvement.state.versionObject else { continue }
                let latest = Shell.getLatestRepositoryVersion(repo: url)
                let latestCompatible = Shell.getLatestRepositoryVersion(
                    repo: url,
                    upperbound: range.upper
                )
                guard let latestCompatible, latestCompatible > current else { continue }
                entries.insert(.init(
                    identity: entry.identity,
                    repository: url,
                    current: current,
                    allowedUntil: range.upper,
                    upgrade: latestCompatible,
                    location: pinResult.location
                ))
                guard let latest, latest > latestCompatible else { continue }
                entries.insert(.init(
                    identity: entry.identity,
                    repository: url,
                    current: current,
                    allowedUntil: range.upper,
                    upgrade: latest,
                    location: pinResult.location
                ))
            }
        }
        return entries
    }
}

private extension XcodeWorkspace {
    struct PinResult {
        let pin: PackageResolvements.Pin
        let location: UpgradeEntry.Location
    }

    func resolvement(identity: String, for project: Project) -> PinResult? {
        let location: UpgradeEntry.Location = sharedData?.packageResolvement?
            .pins == nil ? .project : .workspace
        let pins = sharedData?.packageResolvement?.pins ?? project.resolvements?.pins
        guard let pin = pins?.first(where: { $0.identity == identity }) else { return nil }
        return .init(pin: pin, location: location)
    }
}

private extension XcodeWorkspace {
    struct Range {
        let lower: Version
        let upper: Version
        let entry: PackageDescription.SourceControlEntry
    }
}

private extension Dependency {
    func asRange() -> XcodeWorkspace.Range? {
        switch self {
        case let .sourceControl(entries):
            guard let first = entries.first else { return nil }
            return first.requirement.asRange(for: first)
        default:
            return nil
        }
    }
}

private extension Dependency.Requirement {
    func asRange(for entry: PackageDescription.SourceControlEntry) -> XcodeWorkspace.Range? {
        switch self {
        case let .exact(version: version):
            return .init(lower: version, upper: version.nextPatch, entry: entry)
        case let .range(range: range):
            return .init(lower: range.lowerBound, upper: range.upperBound, entry: entry)
        default:
            return nil
        }
    }
}
