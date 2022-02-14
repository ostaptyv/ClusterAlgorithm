//
//  AtomsConverter.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

struct AtomsConverter {
    var cubeAreaIndices: [Int]?
    var sphereAreaIndices: [Int]?
    
    func convertAtoms(at atomIndicesToConvert: [Int], in atomDataSplitted: inout [Atom]) {
        let allAtomsCount = atomDataSplitted.count
        
        if layerLevels.contains(.cubeArea) {
            createCubeDebugData(in: &atomDataSplitted)
        }
        if layerLevels.contains(.sphereArea) {
            createSphereDebugData(in: &atomDataSplitted)
        }
        
        for (index, atomToConvertIndex) in atomIndicesToConvert.enumerated() {
            if layerLevels.contains(.cluster) {
                // For debug purposes only:
                atomDataSplitted[atomToConvertIndex].type = 5
            } else {
                atomDataSplitted[atomToConvertIndex].type = 2
            }
            
            print("Atoms passed: \(index) out of \(allAtomsCount)")
        }
    }
    
    private func createCubeDebugData(in atomDataSplitted: inout [Atom]) {
        if let unwrappedCubeAreaIndices = cubeAreaIndices {
            for cubeAreaIndex in unwrappedCubeAreaIndices {
                atomDataSplitted[cubeAreaIndex].type = 3
            }
        }
    }
    private func createSphereDebugData(in atomDataSplitted: inout [Atom]) {
        
        if let unwrappedSphereAreaIndices = sphereAreaIndices {
            for sphereAreaIndex in unwrappedSphereAreaIndices {
                atomDataSplitted[sphereAreaIndex].type = 4
            }
        }
    }
}
