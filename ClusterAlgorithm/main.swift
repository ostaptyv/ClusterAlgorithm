//
//  main.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 06.05.2021.
//

import Foundation

do {
    let runner = try MultipleRunner(germaniumPercentage: 0.1,
                                    nanowireVariationsCount: 1,
                                    nanowireDimensions: .phononAnalysis)
    
    try runner.run(with: [1, 10, 50, 100, 500], deltaPrecision: 0.002)
} catch {
    print("⛔️ " + error.localizedDescription)
    print("Operation aborted.")
}
