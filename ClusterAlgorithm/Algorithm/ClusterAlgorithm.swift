//
//  ClusterAlgorithm.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

enum ClusterMetric {
    case count(UInt)
}

class ClusterAlgorithm {
    private var strategy: ClusterStrategyProtocol!
    let fileURL: URL
    
    func createClusters(with metric: ClusterMetric) throws {
        switch metric {
        case .count(let germaniumCountInCluster):
            strategy = try ClusterCountStrategy(germaniumCountInCluster: germaniumCountInCluster)
        }
        
        strategy.fileURL = fileURL
        try strategy.execute()
    }
    
    init(fileURL: URL) {
        self.fileURL = fileURL
    }
}
