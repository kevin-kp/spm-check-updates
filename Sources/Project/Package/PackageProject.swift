//
//  PackageProject.swift
//
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

final class PackageProject: Project {
    let package: PackageDescription
    var resolvements: PackageResolvements?

    var dependencies: [Dependency] {
        return package.dependencies
    }

    init(package: PackageDescription, resolvements: PackageResolvements?) {
        self.package = package
        self.resolvements = resolvements
    }
}
