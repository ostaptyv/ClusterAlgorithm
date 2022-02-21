//
//  CubeAreaGenerator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct CubeAreaGenerator {
    func generateCubeAreas(around clusterCenters: [Atom], using atomDataChunked: Chunk3D<Atom>, cubeEdgeHalfLength: Double) -> [Atom: [Atom]] {
        var cubeAreas = [Atom: [Atom]]() // the key is the central atom in a cluster, the value are the atoms inside the cubic area associated with the given cluster center
        
        for (clusterCenterIndexEnumerated, centralAtom) in clusterCenters.enumerated() {
            var cubeAreaAtoms = [Atom]()
            
            for zChunk in atomDataChunked {
                let z = zChunk[0][0].z
                let cubeZRange = (centralAtom.z - cubeEdgeHalfLength...centralAtom.z + cubeEdgeHalfLength)
                if !cubeZRange.contains(z) {
                    continue
                }

                for yChunk in zChunk {
                    let y = yChunk[0].y
                    let cubeYRange = (centralAtom.y - cubeEdgeHalfLength...centralAtom.y + cubeEdgeHalfLength)
                    if !cubeYRange.contains(y) {
                        continue
                    }

                    for element in yChunk {
                        let x = element.x
                        let cubeXRange = (centralAtom.x - cubeEdgeHalfLength...centralAtom.x + cubeEdgeHalfLength)
                        
                        if cubeXRange.contains(x) {
                            if centralAtom.id == element.id {
                                // print("CONTAINS (\(element.id))") // DEBUG
                            }
                            cubeAreaAtoms.append(element)
                        }
                    }
                }
            }
            cubeAreas[centralAtom] = cubeAreaAtoms
            
            // print("Germanium atoms: \(clusterCenterIndexEnumerated + 1) out of \(clusterCenters.count); cube area count: \(cubeAreas.count)", terminator: "\n")
        }
        
        return cubeAreas
    }
}
