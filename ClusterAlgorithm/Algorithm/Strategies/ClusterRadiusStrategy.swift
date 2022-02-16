//
//  ClusterRadiusStrategy.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

class ClusterRadiusStrategy: ClusterStrategyProtocol {
    
    private let lammpsSerializer = LAMMPSSerializer()
    private let dataPreparer = DataPreparer()
    private let cubeAreaGenerator = CubeAreaGenerator()
    private let sphereAreaGenerator = SphereAreaGenerator()
    private let atomsConverter = AtomsConverter()
    
    private var atomDataSplitted = [Atom]()
    let clusterRadius: Decimal
    var fileURL: URL?
        
    func execute() throws {
        guard let unwrappedFileUrl = fileURL else {
            throw "File URL wasn't specified before executing a strategy"
        }
        guard !clusterRadius.isZero else {
            return
        }
        
        // Read data from file
        let fileTextData = try readData(from: unwrappedFileUrl)
        
        let rawAtomDataSplitted = try lammpsSerializer.decode(from: fileTextData)
        atomDataSplitted = dataPreparer.prepareRawData(rawAtomDataSplitted)
        let atomDataChunked = dataPreparer.chunkAtomData(atomDataSplitted)
        let germaniumIndices = germaniumIndices(in: atomDataSplitted)
        
        let germaniumCount = germaniumIndices.count
        print("* General number of Ge atoms found: \(germaniumCount)")
        
        // Create cubic areas around germanium atoms
        var germaniumCubeAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING CUBE AREAS") {
            let germaniumAtoms = atomDataSplitted.filter { atom in
                return atom.type == 2
            }
            
            germaniumCubeAreas = cubeAreaGenerator
                .generateCubeAreas(germaniumAtoms: germaniumAtoms,
                                   cubeAreaEdgeHalfLength: clusterRadius,
                                   atomDataChunked: atomDataChunked)
        }
        
        // Create sphere areas around germanium atoms
        var germaniumSphereAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING SPHERE AREAS") {
            germaniumSphereAreas = sphereAreaGenerator
                .generateSphereAreas(germaniumCubeAreas: germaniumCubeAreas,
                                     sphereAreaRadius: clusterRadius)
        }
        
        var atomsToConvertCount = 0
        
        // Convert atoms to Germanium ones
        performOperation(title: "CONVERTING FINAL ATOMS") {
            let atomIndicesToConvert = germaniumSphereAreas
                .flatMap { (_, atomsToConvert) in
                    return atomsToConvert
                }
                .map { atom in
                    return atom.id
                }
            atomsToConvertCount = atomIndicesToConvert.count
            
            atomsConverter.convertAtoms(at: atomIndicesToConvert, in: &atomDataSplitted)
        }
        
        // Final statistics
        let germaniumCountAfterConverting = atomsToConvertCount + germaniumCount // atomToConvert includes Si atoms which was then converted to Ge atoms so we need to add the germanium atoms which, in fact, are "centers" of the resulting clusters
        logConvertingStatistics(before: germaniumCount, after: germaniumCountAfterConverting)
        
        dataPreparer.makeOneBasedAtomIDs(in: &atomDataSplitted)
        
        let resultTextData = try lammpsSerializer.encode(from: atomDataSplitted, originalTextData: fileTextData)
        
        // Write data to the original file
        try writeData(resultTextData, to: unwrappedFileUrl)
    }
    
    // MARK: - Private methods
    
    private func readData(from url: URL) throws -> String {
        var fileTextData = ""
        
        do {
            fileTextData = try String(contentsOf: url, encoding: .utf8)
        } catch {
            throw "Error when reading text data file: \(error)"
        }
        
        return fileTextData
    }
    
    private func writeData(_ resultTextData: String, to url: URL) throws {
        do {
            try resultTextData.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            throw "Error when writing to text data file: \(error)"
        }
    }
    
    private func germaniumIndices(in atomDataSplitted: [Atom]) -> [Int] {
        var germaniumIndices = [Int]()
        for (index, element) in atomDataSplitted.enumerated() {
            if element.type == 2 {
                germaniumIndices.append(index)
            }
        }
        
        return germaniumIndices
    }
    
    private func logConvertingStatistics(before germaniumCountBeforeConverting: Int, after germaniumCountAfterConverting: Int) {
        print("\nGeneral atoms count: \(atomDataSplitted.count)")
        print("Germanium atoms count before generating the cluster: \(germaniumCountBeforeConverting)")
        print("Germanium atoms count after generating the cluster: \(germaniumCountAfterConverting)")
    }
    
    private func performOperation(title: String, closure: () -> Void) {
        let hyphenCount: Int
        
        if title.count < 72 {
            hyphenCount = (72 - title.count) / 2
        } else {
            hyphenCount = 5
        }
        
        let hyphenDivider = String(repeating: "-", count: hyphenCount)
        
        print("\n\(hyphenDivider) START \(title.uppercased()) \(hyphenDivider)")
        closure()
        print("\(hyphenDivider)- END \(title.uppercased()) -\(hyphenDivider)")
    }
    
    init(clusterRadius: Decimal) throws {
        guard !clusterRadius.isSignMinus else {
            throw "Error: You can't specify negative radius"
        }
        self.clusterRadius = clusterRadius
    }
}
