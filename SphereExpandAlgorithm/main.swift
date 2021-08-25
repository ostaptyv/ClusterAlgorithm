//
//  main.swift
//  SphereExpandAlgorithm
//
//  Created by Ostap Tyvonovych on 06.05.2021.
//

import Foundation

let fileName = "Ge500-6.data"

if let currentDirectoryURL = URL(string: "file:///Users/admin/Documents/Diploma/XcodeProjects/(working)SphereExpandAlgorithm/SphereExpandAlgorithm/" + fileName) {
    do {
        print("*** \(fileName) ***")
        try makeSphereClustersAroundGermaniumAtoms(usingDataFrom: currentDirectoryURL,
                                               count: 50,
                                               a: 5.432)
        print("✅ Operation successful.")
    } catch {
        print(error.localizedDescription)
        print("Operation aborted.")
    }
} else {
    print("⛔️ Error when retrieving current directory URL.")
    print("Operation aborted.")
}
