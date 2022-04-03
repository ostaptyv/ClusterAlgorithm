//
//  Nanowire.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

struct Nanowire {
    let length: Length
    let clusterCount: UInt
    let germaniumPercentage: Double
    
    var germaniumCentersPercentage: Double {
        return germaniumPercentage / Double(clusterCount)
    }
}

extension Nanowire {
    enum Length {
        case full
        case phononAnalysis
        case other(Double)
        
        var rawValue: Double {
            switch self {
            case .full:
                return 488.88
            case .phononAnalysis:
                return 19.45
            case .other(let length):
                return length
            }
        }
    }
}
