//
//  ClusterCountStrategy.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 05.05.2021.
//

import Foundation

class ClusterCountStrategy: ClusterStrategyProtocol {
    
    private let lammpsSerializer = LAMMPSSerializer()
    private let dataPreparer = DataPreparer()
    private let sphereRadiusCalculator = SphereRadiusCalculator()
    private let cubeAreaGenerator = CubeAreaGenerator()
    private let sphereAreaGenerator = SphereAreaGenerator()
    private let interatomDistanceCalculator = InteratomDistanceCalculator()
    private let atomsConverter = AtomsConverter()
    
    private var atomDataSplitted = [Atom]()
    let germaniumCountInCluster: Int
    var fileURL: URL?
        
    func execute() throws {
        guard let unwrappedFileUrl = fileURL else {
            throw "File URL wasn't specified before executing a strategy"
        }
        guard germaniumCountInCluster > 1 else {
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
        
        // Define sphere radius based on one germanium atom to use it further in the algorithm
        var sphereAreaRadius: Decimal = 0.0
        
        performOperation(title: "DEFINING SPHERE RADIUS") {
            let upperRadiusBound = atomDataChunked.last![0][0].z - atomDataChunked.first![0][0].z
            
            sphereAreaRadius = sphereRadiusCalculator
                .defineSphereRadius(for: germaniumCountInCluster,
                                       atomDataSplitted: atomDataSplitted,
                                       upperRadiusBound: upperRadiusBound)
        }
        
        // FIXME: FIXME: Used if we need to generate cluster with specific radius; should be rewrited as a separate option of a algorithm standing together with a count defined clusters
        //    sphereAreaRadius = 25.807 + 1.4 //51.614
        
        // Create cubic areas around germanium atoms
        var germaniumCubeAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING CUBE AREAS") {
            let germaniumAtoms = atomDataSplitted.filter { atom in
                return atom.type == 2
            }
            
            germaniumCubeAreas = cubeAreaGenerator
                .generateCubeAreas(germaniumAtoms: germaniumAtoms,
                                   cubeAreaEdgeHalfLength: sphereAreaRadius,
                                   atomDataChunked: atomDataChunked)
        }
        
        // Create sphere areas around germanium atoms
        var germaniumSphereAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING SPHERE AREAS") {
            germaniumSphereAreas = sphereAreaGenerator
                .generateSphereAreas(germaniumCubeAreas: germaniumCubeAreas,
                                     sphereAreaRadius: sphereAreaRadius)
        }
        
        // Calculate the distances between atoms inside spheric area and germanium center, take quantity equal to 'germaniumCountInCluster' and mark them as "should be converted"
        var atomsToConvert = [Atom]()
        
        performOperation(title: "CALCULATING DISTANCES BETWEEN ATOMS IN SPHERES") {
            atomsToConvert = interatomDistanceCalculator
                .calculate(germaniumSphereAreas: germaniumSphereAreas,
                           germaniumCountInCluster: germaniumCountInCluster)
        }
        
        // Convert atoms to Germanium ones
        performOperation(title: "CONVERTING FINAL ATOMS") {
            let atomIndicesToConvert = atomsToConvert.map { atom in
                return atom.id
            }
            atomsConverter.convertAtoms(at: atomIndicesToConvert, in: &atomDataSplitted)
        }
        
        // Final statistics
        let germaniumCountAfterConverting = atomsToConvert.count + germaniumCount // atomToConvert includes Si atoms which was then converted to Ge atoms so we need to add the germanium atoms which, in fact, are "centers" of the resulting clusters
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
    
    init(germaniumCountInCluster: UInt) throws {
        guard germaniumCountInCluster != 0 else {
            throw "Error: You can't specify quantity of germanium atoms as zero because every germanium cluster contains at least 1 atom (itself)"
        }
        
        self.germaniumCountInCluster = Int(germaniumCountInCluster)
    }
}
