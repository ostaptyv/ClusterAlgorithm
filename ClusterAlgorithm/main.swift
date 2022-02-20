//
//  main.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 06.05.2021.
//

import Foundation

fileprivate let fileName = "Ge100-1.data"

struct LayerLevel: OptionSet {
    let rawValue: Int
    
    static let cubeArea = LayerLevel(rawValue: 1 << 0)
    static let sphereArea = LayerLevel(rawValue: 1 << 1)
    static let cluster = LayerLevel(rawValue: 1 << 2)
}

// For debug purposes only:
let layerLevels: LayerLevel = []//[.cubeArea, .sphereArea, .cluster]

do {
    print("*** \(fileName) ***")
    
    let clusterAlgorithm = ClusterAlgorithm(fileNameURL: URL(string: fileName)!)
    try clusterAlgorithm.createClusters(with: .radius(25.807432))// + 1.4))
    
    print("✅ Operation successful.")
} catch {
    print("⛔️ " + error.localizedDescription)
    print("Operation aborted.")
}
