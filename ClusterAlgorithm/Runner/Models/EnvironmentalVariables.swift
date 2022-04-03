//
//  EnvironmentalVariables.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

extension SourceNanowireCreator {
    enum EnvironmentalVariables: String {
        case seed
        case nanowireLength
        case germaniumCentersPercentage
        case writeFilePath
        
        var rawValueWithDomainPrefix: String {
            return "xcode_ClusterAlgorithm_" + self.rawValue
        }
    }
}
