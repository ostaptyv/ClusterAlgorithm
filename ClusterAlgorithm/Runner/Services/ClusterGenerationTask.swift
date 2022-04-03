//
//  ClusterGenerationTask.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

struct ClusterGenerationTask {
    let nanowire: Nanowire
    let deltaPrecision: Double
    let fileName: String
    
    let isLogEnabled: Bool
    
    func generateUntilMatchesDelta() throws -> ConvertingStatistics {
        let fileNameURL = URL(string: fileName)!
        
        let clusterAlgorithm = ClusterAlgorithm(fileNameURL: fileNameURL)
        let sourceNanowireCreator = try SourceNanowireCreator
            .init(fileName: fileName,
                  germaniumCentersPercentage: nanowire.germaniumCentersPercentage,
                  nanowireDimensions: nanowire.dimensions,
                  isLogEnabled: isLogEnabled)
        
        var convertingStatistics: ConvertingStatistics!
        
        repeat {
            try sourceNanowireCreator.createNanowire()
            convertingStatistics = try clusterAlgorithm
                .createClusters(with: .count(nanowire.clusterCount))
            
            if isLogEnabled {
                print("Germanium percentage after generation: \(convertingStatistics.clusterAtomsPercentageAfter)")
            }
        } while isResultPercentageBiggerThanDelta(using: convertingStatistics)
        
        return convertingStatistics
    }
    
    private func isResultPercentageBiggerThanDelta(using statistics: ConvertingStatistics) -> Bool {
        let germaniumPercentage = nanowire.germaniumPercentage
        let generatedClusterAtomsPercentage = statistics.clusterAtomsPercentageAfter
        
        return abs(germaniumPercentage - generatedClusterAtomsPercentage) > deltaPrecision
    }
}
