//
//  MultipleRunner.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 21.02.2022.
//

import Foundation

struct MultipleRunner {
    private let fileManager = FileManager.default
    private let urlManager = URLManager()
    
    let germaniumPercentage: Double 
    let nanowireVariations: ClosedRange<UInt>
    let nanowireDimensions: Nanowire.Dimensions
    let isLogEnabled: Bool
    
    func run(with clusterCounts: [UInt], deltaPrecisions: [Double]) throws {
        guard clusterCounts.count == deltaPrecisions.count else {
            throw "Error: Array with the cluster counts should be the same size as the delta precisions array"
        }
        try createSourceFolder()
        try createResultsFolder()
        
        for (clusterCount, deltaPrecision) in zip(clusterCounts, deltaPrecisions) {
            for variation in nanowireVariations {
                let fileName = makeFileName(clusterCount: clusterCount,
                                            variation: variation)
                
                let nanowire = Nanowire(dimensions: nanowireDimensions,
                                        clusterCount: clusterCount,
                                        germaniumPercentage: germaniumPercentage)
                
                let task = ClusterGenerationTask(nanowire: nanowire,
                                                 deltaPrecision: deltaPrecision,
                                                 fileName: fileName,
                                                 isLogEnabled: isLogEnabled)
                
                let convertingStatistics = try task.generateUntilMatchesDelta()
                
                if isLogEnabled {
                    print("\nGeneral atoms count: \(convertingStatistics.atomsCountGeneral)")
                    print("Germanium atoms count before generating the cluster: \(convertingStatistics.clusterAtomsCountBefore)")
                    print("Germanium atoms count after generating the cluster: \(convertingStatistics.clusterAtomsCountAfter)")
                    print("Delta: |\(germaniumPercentage - convertingStatistics.clusterAtomsPercentageAfter)| < \(deltaPrecision)\n")
                
                    print("✅ Operation successful.\n")
                }
            }
        }
    }
    
    func run(with clusterCounts: [UInt], deltaPrecision: Double) throws {
        let deltaPrecisions = [Double](repeating: deltaPrecision,
                                       count: clusterCounts.count)
        try run(with: clusterCounts, deltaPrecisions: deltaPrecisions)
    }
    
    // MARK: - Private methods
    
    private func createSourceFolder() throws {
        let sourceURL = try urlManager.sourceURL
        try fileManager.createDirectory(at: sourceURL, withIntermediateDirectories: true)
        
    }
    private func createResultsFolder() throws {
        let resultsURL = try urlManager.resultsURL
        try fileManager.createDirectory(at: resultsURL, withIntermediateDirectories: true)
    }
    
    private func makeFileName(clusterCount: UInt, variation: UInt) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 5
        formatter.decimalSeparator = ","
        
        let germaniumPercentageNumber = NSNumber(value: germaniumPercentage)
        let germaniumPercentageString = formatter.string(from: germaniumPercentageNumber)!
        let fileName = "Ge\(germaniumPercentageString)-\(clusterCount)-\(variation).data"
        
        if isLogEnabled {
            print("*** \(fileName) ***\n")
        }
        return fileName
    }
    
    init(germaniumPercentage: Double,
         nanowireVariationsCount: UInt,
         nanowireDimensions: Nanowire.Dimensions,
         isLogEnabled: Bool = true) throws {
        
        guard (0.0...1.0).contains(germaniumPercentage) else {
            throw "Error: Percentage of the germanium in the nanowire is bigger than 1.0 or less than 0.0"
        }
        guard nanowireVariationsCount >= 1 else {
            throw "Error: You have to specify variations quantity more than or equal to 1"
        }
        
        self.germaniumPercentage = germaniumPercentage
        self.nanowireVariations = 1...nanowireVariationsCount
        self.nanowireDimensions = nanowireDimensions
        self.isLogEnabled = isLogEnabled
    }
}
