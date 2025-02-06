// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import PathKit
import XcodeProj

@main
struct Cli: ParsableCommand {
    static var configuration = CommandConfiguration(
            abstract: "A utility for updating Swift packages.",
            subcommands: [Dry.self, Interactive.self, Update.self, UpdateAll.self],
            defaultSubcommand: Dry.self)
}

enum UpdateCheckError: Error {
    case noProjectFileFound
    case invalidPackageFile
    case updateResolvementFailed
    case dependencyNotFound
}
