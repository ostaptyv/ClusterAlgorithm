//
//  main.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 06.05.2021.
//

import Foundation

do {
    let runner = try MultipleRunner(germaniumPercentage: 0.5,
                                    nanowireVariationsCount: 1,
                                    nanowireDimensions: .siliciumNanowire)
    
    try runner.run(with: [50], deltaPrecision: 0.002)
} catch {
    print("⛔️ " + error.localizedDescription)
    print("Operation aborted.")
}
