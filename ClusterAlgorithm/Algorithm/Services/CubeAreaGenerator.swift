//
//  CubeAreaGenerator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct CubeAreaGenerator {
    func generateCubeAreas(germaniumAtoms: [Atom], cubeAreaEdgeHalfLength: Double, atomDataChunked: Chunk3D<Atom>) -> [Atom: [Atom]] {
        var germaniumCubeAreas = [Atom: [Atom]]() // the key is a germanium atom, the value are atoms inside the cubic area associated with the given germanium atom
        let germaniumCount = germaniumAtoms.count
        
        for (index, germaniumAtom) in germaniumAtoms.enumerated() {
            var cubeAreaAtoms = [Atom]()
            
            for zChunk in atomDataChunked {
                let z = zChunk[0][0].z
                let cubeZRange = (germaniumAtom.z - cubeAreaEdgeHalfLength...germaniumAtom.z + cubeAreaEdgeHalfLength)
                if !cubeZRange.contains(z) {
                    continue
                }

                for yChunk in zChunk {
                    let y = yChunk[0].y
                    let cubeYRange = (germaniumAtom.y - cubeAreaEdgeHalfLength...germaniumAtom.y + cubeAreaEdgeHalfLength)
                    if !cubeYRange.contains(y) {
                        continue
                    }

                    for element in yChunk {
                        let x = element.x
                        let cubeXRange = (germaniumAtom.x - cubeAreaEdgeHalfLength...germaniumAtom.x + cubeAreaEdgeHalfLength)
                        
                        if cubeXRange.contains(x) {
                            cubeAreaAtoms.append(element)
                            
                            // For debug purposes only:
//                            if germaniumAtom.id != element.id && layerLevels.contains(.cubeArea) {
//                                atomDataSplitted[element.id].type = 3
//                            }
                        }
                    }
                }
            }
            germaniumCubeAreas[germaniumAtom] = cubeAreaAtoms
            
            print("Germanium atoms: \(index + 1) out of \(germaniumCount); cube area count: \(germaniumCubeAreas.count)", terminator: "\n")
        }
        
        return germaniumCubeAreas
    }
}
