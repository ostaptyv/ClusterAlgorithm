//
//  ClusterAlgorithm.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

enum ClusterMetric {
    case count(UInt)
    case radius(Double)
}

class ClusterAlgorithm {
    private var strategy: ClusterStrategyProtocol!
    
    /// The file name with file extension being processed by this strategy.
    ///
    /// The property should not contain any other paths, schemes, arguments, etc.
    ///
    /// For example:
    ///
    ///     let strategy = YourStrategy()
    ///     strategy.fileNameURL = URL(string: "my_file.txt")!
    ///
    /// - Returns: `URL` instance containing a file name and its extension, and `nil` if the value wasn't set.
    let fileNameURL: URL
    
    // FIXME: FIXME: Temporary; should be replaced with better architecture solution
    @discardableResult
    func createClusters(with metric: ClusterMetric) throws -> ConvertingStatistics {
        switch metric {
        case .count(let germaniumCountInCluster):
            strategy = try ClusterCountStrategy(atomsInClusterCount: germaniumCountInCluster)
        case .radius(let clusterRadius):
            strategy = try ClusterRadiusStrategy(clusterRadius: clusterRadius)
        }
        
        strategy.fileNameURL = fileNameURL
        
        // FIXME: FIXME: Temporary; should be replaced with better architecture solution
        return try strategy.execute()
    }
    
    /// Creates a new instance of the cluster algorithm.
    ///
    ///  - Parameters:
    ///     - fileNameURL: A `URL` instance containing a file name and its extension.
    init(fileNameURL: URL) {
        self.fileNameURL = fileNameURL
    }
}
