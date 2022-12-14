//
//  ConvertingStatistics.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 21.02.2022.
//

import Foundation

struct ConvertingStatistics {
    var clusterAtomsCountBefore: Int
    var clusterAtomsCountAfter: Int
    var atomsCountGeneral: Int
    
    var clusterAtomsPercentageAfter: Double {
        let clusterCountAfter = Double(clusterAtomsCountAfter)
        let clusterCountGeneral = Double(atomsCountGeneral)
        
        return clusterCountAfter / clusterCountGeneral
    }
}
