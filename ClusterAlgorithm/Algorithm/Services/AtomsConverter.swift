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
    
    func convertAtoms(atPositions atomIndicesToConvert: [Int], in atomData: inout [Atom]) {
        let allAtomsCount = atomData.count
        
        if layerLevels.contains(.cubeArea) {
            createCubeDebugData(in: &atomData)
        }
        if layerLevels.contains(.sphereArea) {
            createSphereDebugData(in: &atomData)
        }
        
        for (index, atomToConvertIndex) in atomIndicesToConvert.enumerated() {
            if layerLevels.contains(.cluster) {
                // For debug purposes only:
                atomData[atomToConvertIndex].type = 5
            } else {
                atomData[atomToConvertIndex].type = 2
            }
            
            print("Atoms passed: \(index) out of \(allAtomsCount)")
        }
    }
    
    private func createCubeDebugData(in atomData: inout [Atom]) {
        if let unwrappedCubeAreaIndices = cubeAreaIndices {
            for cubeAreaIndex in unwrappedCubeAreaIndices {
                atomData[cubeAreaIndex].type = 3
            }
        }
    }
    private func createSphereDebugData(in atomData: inout [Atom]) {
        
        if let unwrappedSphereAreaIndices = sphereAreaIndices {
            for sphereAreaIndex in unwrappedSphereAreaIndices {
                atomData[sphereAreaIndex].type = 4
            }
        }
    }
}
