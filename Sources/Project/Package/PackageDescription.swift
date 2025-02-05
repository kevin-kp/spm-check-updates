//
//  PackageDescription.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

struct PackageDescription: Decodable {
    let name: String
    let dependencies: [Dependency]
}
