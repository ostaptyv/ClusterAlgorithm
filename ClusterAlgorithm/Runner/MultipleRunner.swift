//
//  MultipleRunner.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 21.02.2022.
//

import Foundation

struct MultipleRunner {
    private enum EnvironmentalVariables: String {
        case seed
        case nanowireLength
        case percentageOfCenters
        case writeFilePath
        
        var rawValueWithDomainPrefix: String {
            return "xcode_ClusterAlgorithm_" + self.rawValue
        }
    }
    enum NanowireLength {
        case full
        case phononAnalysis
        case other(Double)
        
        fileprivate var rawValue: Double {
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
    
    private let fileManager = FileManager.default
    private let urlManager = URLManager()
    
    let germaniumPercentage: Double 
    let nanowireVariationsCount: UInt 
    let nanowireLength: NanowireLength
    let isLogVerbose: Bool
    
    func run(with clusterCountConfigurations: [UInt], deltaPrecision: Double) throws {
        let deltaPrecisions = [Double](repeating: deltaPrecision,
                                       count: clusterCountConfigurations.count)
        
        try run(with: clusterCountConfigurations, deltaPrecisions: deltaPrecisions)
    }
    
    func run(with clusterCountConfigurations: [UInt], deltaPrecisions: [Double]) throws {
        guard clusterCountConfigurations.count == deltaPrecisions.count else {
            throw "Error: Array with the cluster configurations should be the same size as the delta precisions array"
        }
        try createSourceFolder()
        try createResultsFolder()
        
        for (clusterCountConfiguration, deltaPrecision) in zip(clusterCountConfigurations, deltaPrecisions) {
            
            let percentageOfCenters = germaniumPercentage / Double(clusterCountConfiguration)
            var generatedClusterAtomsPercentage = 0.0
            
            for variation in 0..<nanowireVariationsCount {
                
                let fileName = makeFileName(clusterCountConfiguration: clusterCountConfiguration, variation: variation)
                print("*** \(fileName) ***\n")
                
                var convertingStatistics: ConvertingStatistics?
                
                repeat {
                    let seed = (1...900000000).randomElement()!
                    print("Seed: \(seed)")
                    
                    let sourcePath = try urlManager.workingFolderURL
                        .appendingPathComponent(urlManager.sourcePath)
                        .appendingPathComponent(fileName)
                        .path
                    let environmentalVariablesToWrite: [EnvironmentalVariables: Any] = [
                        .seed: seed,
                        .nanowireLength: nanowireLength.rawValue,
                        .percentageOfCenters: percentageOfCenters,
                        .writeFilePath: sourcePath
                    ]
                    
                    for (name, value) in environmentalVariablesToWrite {
                        setenv(name.rawValueWithDomainPrefix, "\(value)", 1)
                    }
                    
                    let workingFolderPath = try urlManager.workingFolderURL.path
                    let _ = try shell("cd \(workingFolderPath) && /usr/local/bin/lmp_serial -in SiGe_Nanowire.in")
                    
                    let clusterAlgorithm = ClusterAlgorithm(fileNameURL: URL(string: fileName)!)
                    convertingStatistics = try clusterAlgorithm.createClusters(with: .count(clusterCountConfiguration))
                    
                    let clusterCountAfter = Double(convertingStatistics!.clusterAtomsCountAfter)
                    let clusterCountGeneral = Double(convertingStatistics!.atomsCountGeneral)
                    generatedClusterAtomsPercentage = clusterCountAfter / clusterCountGeneral
                    
                    if isLogVerbose {
                        print("Germanium percentage after generation: \(generatedClusterAtomsPercentage)")
                    }
                } while abs(germaniumPercentage - generatedClusterAtomsPercentage) > deltaPrecision
                
                print("\nGeneral atoms count: \(convertingStatistics!.atomsCountGeneral)")
                print("Germanium atoms count before generating the cluster: \(convertingStatistics!.clusterAtomsCountBefore)")
                print("Germanium atoms count after generating the cluster: \(convertingStatistics!.clusterAtomsCountAfter)")
                print("Delta: |\(germaniumPercentage - generatedClusterAtomsPercentage)| < \(deltaPrecision)\n")
                
                print("✅ Operation successful.\n")
            }
        }
    }
    
    // MARK: - Private methods
    
    @discardableResult
    private func shell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/bash")
        
        try task.run()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
    
    private func createSourceFolder() throws {
        let sourceURL = try urlManager.workingFolderURL
            .appendingPathComponent(urlManager.sourcePath)
        try fileManager.createDirectory(at: sourceURL, withIntermediateDirectories: true)
        
    }
    private func createResultsFolder() throws {
        let resultsURL = try urlManager.workingFolderURL
            .appendingPathComponent(urlManager.resultsPath)
        try fileManager.createDirectory(at: resultsURL, withIntermediateDirectories: true)
    }
    
    private func makeFileName(clusterCountConfiguration: UInt, variation: UInt) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 1
        formatter.maximumFractionDigits = 5
        formatter.decimalSeparator = ","
        
        let germaniumPercentageString = formatter.string(from: NSNumber(value: germaniumPercentage))!
        return "Ge\(germaniumPercentageString)-\(clusterCountConfiguration)-\(variation + 1).data"
    }
    
    init(germaniumPercentage: Double, nanowireVariationsCount: UInt, nanowireLength: NanowireLength, isLogVerbose: Bool = false) throws {
        guard (0.0...1.0).contains(germaniumPercentage) else {
            throw "Error: Percentage of the germanium in the nanowire is bigger than 1.0 or less than 0.0"
        }
        guard nanowireLength.rawValue > 0.0 else {
            throw "Error: Nanowire length can't be less or equal to zero"
        }
        
        self.germaniumPercentage = germaniumPercentage
        self.nanowireVariationsCount = nanowireVariationsCount
        self.nanowireLength = nanowireLength
        self.isLogVerbose = isLogVerbose
    }
}
