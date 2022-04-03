//
//  SourceNanowireCreator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

struct SourceNanowireCreator {
    private let fileManager = FileManager.default
    private let urlManager = URLManager()
    
    let fileName: String
    let germaniumCentersPercentage: Double
    let nanowireLength: Nanowire.Length
    let isLogEnabled: Bool
    
    private var sourcePath: String {
        get throws {
            return try urlManager.workingFolderURL
                .appendingPathComponent(urlManager.sourcePath)
                .appendingPathComponent(fileName)
                .path
        }
    }
    
    func createNanowire(seed: Int = .lammpsRandomSeed()) throws {
        if isLogEnabled {
            print("Seed: \(seed)")
        }
        let workingFolderPath = try urlManager.workingFolderURL.path
        
        try writeEnvironmentalVariables(seed: seed)
        try shell("cd \(workingFolderPath) && /usr/local/bin/lmp_serial -in SiGe_Nanowire_Xcode.in")
    }
    
    // MARK: - Private methods
    
    private func writeEnvironmentalVariables(seed: Int) throws {
        let environmentalVariablesToWrite: [EnvironmentalVariables: Any] = [
            .seed: seed,
            .nanowireLength: nanowireLength.rawValue,
            .germaniumCentersPercentage: germaniumCentersPercentage,
            .writeFilePath: try sourcePath
        ]
        
        for (name, value) in environmentalVariablesToWrite {
            setenv(name.rawValueWithDomainPrefix, "\(value)", 1)
        }
    }
    
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
    
    init(fileName: String,
         germaniumCentersPercentage: Double,
         nanowireLength: Nanowire.Length,
         isLogEnabled: Bool = true) throws {
        
        guard (0.0...1.0).contains(germaniumCentersPercentage) else {
            throw "Error: Percentage of the germanium centers is bigger than 1.0 or less than 0.0"
        }
        guard nanowireLength.rawValue > 0.0 else {
            throw "Error: Nanowire length can't be less or equal to zero"
        }
        
        self.fileName = fileName
        self.germaniumCentersPercentage = germaniumCentersPercentage
        self.nanowireLength = nanowireLength
        self.isLogEnabled = isLogEnabled
    }
}
