//
//  Project.swift
//  
//
//  Created by Kevin Pittevils on 11/06/2024.
//

import Foundation

protocol Project: AnyObject {
    var dependencies: [Dependency] { get }
    var resolvements: PackageResolvements? { get set }
}
