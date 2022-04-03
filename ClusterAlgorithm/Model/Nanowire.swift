//
//  Nanowire.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

struct Nanowire {
    let dimensions: Dimensions
    var length: Double {
        return dimensions.length
    }
    var radius: Double {
        return dimensions.radius
    }
    
    let clusterCount: UInt
    let germaniumPercentage: Double
    
    var germaniumCentersPercentage: Double {
        return germaniumPercentage / Double(clusterCount)
    }
    
    init(dimensions: Dimensions,
         clusterCount: UInt,
         germaniumPercentage: Double) {
        
        self.dimensions = dimensions
        self.clusterCount = clusterCount
        self.germaniumPercentage = germaniumPercentage
    }
    init(length: Double,
         radius: Double,
         clusterCount: UInt,
         germaniumPercentage: Double) throws {
        
        self.dimensions = try Dimensions(length: length, radius: radius)
        self.clusterCount = clusterCount
        self.germaniumPercentage = germaniumPercentage
    }
}
