//
//  ClusterRadiusStrategy.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

class ClusterRadiusStrategy: ClusterStrategyProtocol {
    
    private var fileRepository: RepositoryProtocol!
    private let lammpsSerializer = LAMMPSSerializer()
    private let dataPreparer = DataPreparer()
    private let cubeAreaGenerator = CubeAreaGenerator()
    private let sphereAreaGenerator = SphereAreaGenerator()
    private let atomsConverter = AtomsConverter()
    
    let clusterRadius: Double
    var fileNameURL: URL? {
        willSet {
            setRepository(with: newValue)
        }
    }
     
    // FIXME: FIXME: Temporary; should be replaced with better architecture solution
    func execute() throws -> ConvertingStatistics {
        guard fileNameURL != nil else {
            throw "Error: File URL wasn't specified before executing a strategy."
        }
        
        // Read data from file
        let fileData = try fileRepository.readData()
        guard let fileTextData = String(data: fileData, encoding: .utf8) else {
            throw "Error: file data is corrupted or not compatible with UTF8"
        }
        
        let rawAtomData = try lammpsSerializer.decode(from: fileTextData)
        var atomData = prepareRawData(rawAtomData)
        let atomDataChunked = dataPreparer.chunkAtomData(atomData)
        let clusterCenters = clusterCenters(in: atomData)
        let clusterCentersCount = clusterCenters.count
        
        // print("* General number of Ge atoms found: \(clusterCentersCount)")
        
        // FIXME: FIXME: Temporary; should be replaced with better architecture solution
        guard !clusterRadius.isZero else {
            try fileRepository.copyDataToResults()
            return ConvertingStatistics(clusterAtomsCountBefore: clusterCentersCount,
                                        clusterAtomsCountAfter: clusterCentersCount,
                                        atomsCountGeneral: atomData.count)
        }
        
        // Create cubic areas around germanium atoms
        var cubeAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING CUBE AREAS") {
            cubeAreas = cubeAreaGenerator
                .generateCubeAreas(around: clusterCenters,
                                   using: atomDataChunked,
                                   cubeEdgeHalfLength: clusterRadius)
        }
        
        // Create sphere areas around germanium atoms
        var sphereAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING SPHERE AREAS") {
            sphereAreas = sphereAreaGenerator
                .generateSphereAreas(insideOf: cubeAreas, withRadius: clusterRadius)
        }
        
        // Convert atoms to Germanium ones
        var atomsToConvertCount = 0
        
        performOperation(title: "CONVERTING FINAL ATOMS") {
            let atomIndicesToConvert = sphereAreas
                .flatMap { (_, sphereAreaAtoms) in
                    return sphereAreaAtoms
                }
                .map { atom in
                    return atom.id
                }
            atomsToConvertCount = atomIndicesToConvert.count
            
            atomsConverter.convertAtoms(atPositions: atomIndicesToConvert,
                                        in: &atomData)
        }
        
        // Final statistics
        let germaniumCountAfterConverting = atomsToConvertCount
        logConvertingStatistics(before: clusterCentersCount,
                                after: germaniumCountAfterConverting,
                                generalCount: atomData.count)
        
        // Write data to the original file
        let atomDataIDsOneBased = dataPreparer.shiftIDsToBaseOne(in: atomData)
        let resultTextData = try lammpsSerializer.encode(from: atomDataIDsOneBased, originalTextData: fileTextData)
        guard let resultData = resultTextData.data(using: .utf8) else {
            throw "Result of the algorithm can't be converted to buffer of bytes without losing some information (see: https://developer.apple.com/documentation/foundation/nsstring/1413692-data)"
        }
        
        try fileRepository.writeData(resultData)
        
        // FIXME: FIXME: Temporary; should be replaced with better architecture solution
        return ConvertingStatistics(clusterAtomsCountBefore: clusterCentersCount,
                                    clusterAtomsCountAfter: germaniumCountAfterConverting,
                                    atomsCountGeneral: atomData.count)
    }
    
    // MARK: - Private methods
    
    private func setRepository(with fileNameURL: URL?) {
        guard let fileNameURL = fileNameURL else {
            return
        }
        fileRepository = FileRepository(fileName: fileNameURL.path)
    }
    
    private func prepareRawData(_ rawData: [Atom]) -> [Atom] {
        // Convert string data to numbers to be able to do mathematical operations on them
        let atomDataSorted = dataPreparer.sortAtomDataInIncreasingOrder(rawData)
        let atomDataIDReassigned = dataPreparer.reassignIDsToIndices(of: atomDataSorted)
        
        return atomDataIDReassigned
    }
    
    private func clusterCenters(in atomData: [Atom]) -> [Atom] {
        return atomData.filter { atom in
            return atom.type == 2
        }
    }
    
    private func logConvertingStatistics(before germaniumCountBeforeConverting: Int, after germaniumCountAfterConverting: Int, generalCount atomDataCount: Int) {
        // print("\nGeneral atoms count: \(atomDataCount)")
        // print("Germanium atoms count before generating the cluster: \(germaniumCountBeforeConverting)")
        // print("Germanium atoms count after generating the cluster: \(germaniumCountAfterConverting)")
    }
    
    private func performOperation(title: String, closure: () -> Void) {
        let hyphenCount: Int
        
        if title.count < 72 {
            hyphenCount = (72 - title.count) / 2
        } else {
            hyphenCount = 5
        }
        
        let hyphenDivider = String(repeating: "-", count: hyphenCount)
        
        // print("\n\(hyphenDivider) START \(title.uppercased()) \(hyphenDivider)")
        closure()
        // print("\(hyphenDivider)- END \(title.uppercased()) -\(hyphenDivider)")
    }
    
    init(clusterRadius: Double) throws {
        guard clusterRadius.sign == .plus else {
            throw "Error: You can't specify negative radius"
        }
        self.clusterRadius = clusterRadius
    }
}
