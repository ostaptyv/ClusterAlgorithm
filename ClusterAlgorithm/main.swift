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


//do {
//    print("*** \(fileName) ***")
//
//    let clusterAlgorithm = ClusterAlgorithm(fileNameURL: URL(string: fileName)!)
//    try clusterAlgorithm.createClusters(with: .count(10))
//
//    print("✅ Operation successful.")
//} catch {
//    print("⛔️ " + error.localizedDescription)
//    print("Operation aborted.")
//}


//do {
//    let runner = try MultipleRunner(germaniumPercentage: 0.5,
//                                    nanowireVariationsCount: 2,
//                                    nanowireLength: .full,
//                                    isLogVerbose: true)
//
//    try runner.run(with: [1], deltaPrecision: 0.002)
//} catch {
//    print("⛔️ " + error.localizedDescription)
//    print("Operation aborted.")
//}

do {
    let runner = try MultipleRunner(germaniumPercentage: 0.1,
                                    nanowireVariationsCount: 1,
                                    nanowireLength: .phononAnalysis,
                                    isLogVerbose: true)
    
    try runner.run(with: [1, 10, 50, 100, 500], deltaPrecision: 0.002)
} catch {
    print("⛔️ " + error.localizedDescription)
    print("Operation aborted.")
}
