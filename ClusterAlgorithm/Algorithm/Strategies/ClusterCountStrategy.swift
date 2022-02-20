//
//  ClusterCountStrategy.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 05.05.2021.
//

import Foundation

class ClusterCountStrategy: ClusterStrategyProtocol {
    
    private var fileRepository: RepositoryProtocol!
    private let lammpsSerializer = LAMMPSSerializer()
    private let dataPreparer = DataPreparer()
    private let sphereRadiusCalculator = SphereRadiusCalculator()
    private let cubeAreaGenerator = CubeAreaGenerator()
    private let sphereAreaGenerator = SphereAreaGenerator()
    private let interatomDistanceCalculator = InteratomDistanceCalculator()
    private let atomsConverter = AtomsConverter()
    
    let atomsInClusterCount: Int
    var fileNameURL: URL? {
        willSet {
            setRepository(with: newValue)
        }
    }
        
    func execute() throws {
        guard fileNameURL != nil else {
            throw "Error: File URL wasn't specified before executing a strategy"
        }
        guard atomsInClusterCount > 1 else {
            return
        }
        
        // Read data from file
        let fileData = try fileRepository.readData()
        guard let fileTextData = String(data: fileData, encoding: .utf8) else {
            throw "Error: file data is corrupted or not compatible with UTF8"
        }
        
        let rawAtomData = try lammpsSerializer.decode(from: fileTextData)
        var atomData = prepareRawAtomData(rawAtomData)
        let atomDataChunked = dataPreparer.chunkAtomData(atomData)
        let clusterCenters = clusterCenters(in: atomData)
        let clusterCentersCount = clusterCenters.count
        
        print("* General number of Ge atoms found: \(clusterCentersCount)")
        
        // Define sphere radius based on one germanium atom to use it further in the algorithm
        var sphereAreaRadius: Double = 0.0
        
        performOperation(title: "DEFINING SPHERE RADIUS") {
            let upperRadiusBound = atomDataChunked.last![0][0].z - atomDataChunked.first![0][0].z
            
            sphereAreaRadius = sphereRadiusCalculator
                .defineSphereRadius(forCount: atomsInClusterCount,
                                    in: atomData,
                                    limitingRadiusUpTo: upperRadiusBound)
        }
        
        // Create cubic areas around germanium atoms
        var cubeAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING CUBE AREAS") {
            cubeAreas = cubeAreaGenerator
                .generateCubeAreas(around: clusterCenters,
                                   using: atomDataChunked,
                                   cubeEdgeHalfLength: sphereAreaRadius)
        }
        
        // Create sphere areas around germanium atoms
        var sphereAreas = [Atom: [Atom]]()
        
        performOperation(title: "GENERATING SPHERE AREAS") {
            sphereAreas = sphereAreaGenerator
                .generateSphereAreas(insideOf: cubeAreas, withRadius: sphereAreaRadius)
        }
        
        // Calculate the distances between the atoms inside spheric area and the cluster center and take quantity equal to 'atomsInClusterCount'
        var atomsToConvert = [Atom]()
        
        performOperation(title: "CALCULATING DISTANCES BETWEEN ATOMS IN SPHERES") {
            atomsToConvert = interatomDistanceCalculator
                .generateJoinedClusterAreas(outOf: sphereAreas,
                                            trimmingExtraAtomsToCount: atomsInClusterCount)
        }
        
        // Convert atoms to Germanium ones
        performOperation(title: "CONVERTING FINAL ATOMS") {
            let atomIndicesToConvert = atomsToConvert
                .map { atom in
                    return atom.id
                }
            
            atomsConverter.convertAtoms(atPositions: atomIndicesToConvert,
                                        in: &atomData)
        }
        
        // Final statistics
        let germaniumCountAfterConverting = atomsToConvert.count + clusterCentersCount // atomToConvert includes Si atoms which were then converted to Ge atoms so we need to add the germanium atoms which, in fact, are "centers" of the resulting clusters
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
    }
    
    // MARK: - Private methods
    
    private func setRepository(with fileNameURL: URL?) {
        guard let fileNameURL = fileNameURL else {
            return
        }
        fileRepository = FileRepository(fileName: fileNameURL.path)
    }
    
    private func prepareRawAtomData(_ rawData: [Atom]) -> [Atom] {
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
        print("\nGeneral atoms count: \(atomDataCount)")
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
    
    // MARK: - Initializers
    
    init(atomsInClusterCount: UInt) throws {
        guard atomsInClusterCount != 0 else {
            throw "Error: You can't specify quantity of germanium atoms as zero because every germanium cluster contains at least 1 atom (itself)"
        }
        
        self.atomsInClusterCount = Int(atomsInClusterCount)
    }
}
