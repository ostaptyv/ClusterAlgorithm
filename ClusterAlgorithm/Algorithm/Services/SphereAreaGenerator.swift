//
//  SphereAreaGenerator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct SphereAreaGenerator {
    func generateSphereAreas(insideOf cubeAreas: [Atom: [Atom]], withRadius sphereAreaRadius: Double) -> [Atom: [Atom]] {
        var sphereAreas = [Atom: [Atom]]() // the key is the central atom in a cluster, the value are atoms inside the spheric area associated with the given cluster center
 
        let clusterCenters = [Atom](cubeAreas.keys)
        
        for (clusterCenterIndexEnumerated, centralAtom) in clusterCenters.enumerated() {
            var sphereAreaAtoms = [Atom]()
            
            for atom in cubeAreas[centralAtom]! {
                let xSquared = pow(atom.x - centralAtom.x, 2)
                let ySquared = pow(atom.y - centralAtom.y, 2)
                let zSquared = pow(atom.z - centralAtom.z, 2)
                let radiusSquared = pow(sphereAreaRadius, 2)

                if xSquared + ySquared + zSquared <= radiusSquared {
                    sphereAreaAtoms.append(atom)
                }
            }
            sphereAreas[centralAtom] = sphereAreaAtoms
            
            // print("Germanium atoms: \(clusterCenterIndexEnumerated + 1) out of \(clusterCenters.count); sphere area count: \(sphereAreas.count)", terminator: "\n")
        }
        
        return sphereAreas
    }
}
