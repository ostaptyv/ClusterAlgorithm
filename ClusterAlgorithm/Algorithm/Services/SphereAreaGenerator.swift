//
//  SphereAreaGenerator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct SphereAreaGenerator {
    func generateSphereAreas(germaniumCubeAreas: [Atom: [Atom]], sphereAreaRadius: Decimal) -> [Atom: [Atom]] {
        var germaniumSphereAreas = [Atom: [Atom]]() // the key is a germanium atom, the value are atoms inside the spheric area associated with the given germanium atom
 
        let germaniumAtoms = [Atom](germaniumCubeAreas.keys)
        let germaniumCount = germaniumAtoms.count
        
        for (index, germaniumAtom) in germaniumAtoms.enumerated() {
            var sphereAreaAtoms = [Atom]()
            
            for atomElement in germaniumCubeAreas[germaniumAtom]! {
                let xSquared = pow(atomElement.x - germaniumAtom.x, 2)
                let ySquared = pow(atomElement.y - germaniumAtom.y, 2)
                let zSquared = pow(atomElement.z - germaniumAtom.z, 2)
                let radiusSquared = pow(sphereAreaRadius, 2)

                if xSquared + ySquared + zSquared <= radiusSquared {
                    sphereAreaAtoms.append(atomElement)
                }
            }
            germaniumSphereAreas[germaniumAtom] = sphereAreaAtoms
            
            print("Germanium atoms: \(index + 1) out of \(germaniumCount); sphere area count: \(germaniumSphereAreas.count)", terminator: "\n")
        }
        
//        // For debug purposes only:
//        if layerLevels.contains(.sphereArea) {
//            atomDataSplitted[sphereAreaIndex].type = 4
//        }
        
        return germaniumSphereAreas
    }
}
