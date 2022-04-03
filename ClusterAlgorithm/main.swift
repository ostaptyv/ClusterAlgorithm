//
//  main.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 06.05.2021.
//

import Foundation

fileprivate let fileName = "Ge0,5-10-1.data"

struct LayerLevel: OptionSet {
    let rawValue: Int
    
    static let cubeArea = LayerLevel(rawValue: 1 << 0)
    static let sphereArea = LayerLevel(rawValue: 1 << 1)
    static let cluster = LayerLevel(rawValue: 1 << 2)
}

// For debug purposes only:
let layerLevels: LayerLevel = []//[.cubeArea, .sphereArea, .cluster]

do {
    let runner = try MultipleRunner(germaniumPercentage: 0.1,
                                    nanowireVariationsCount: 1,
                                    nanowireDimensions: .phononAnalysis,
                                    isLogEnabled: false)
    
    try runner.run(with: [1, 10, 50, 100, 500], deltaPrecision: 0.002)
} catch {
    print("⛔️ " + error.localizedDescription)
    print("Operation aborted.")
}
