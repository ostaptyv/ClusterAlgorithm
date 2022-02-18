//
//  InteratomDistanceCalculator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct InteratomDistanceCalculator {
    func calculate(germaniumSphereAreas: [Atom: [Atom]], germaniumCountInCluster: Int) -> [Atom] {
        var atomsToBeConverted = [Atom]()
        
        for (germaniumEnumeratedIndex, element: (germaniumCenter, sphereAreaAtoms)) in germaniumSphereAreas.enumerated() {
            var distances = [Atom: Double]() // the key is the atom from the sphere area; the value is the distance between the atom and the germanium center
            
            for sphereAreaAtom in sphereAreaAtoms {
                if sphereAreaAtom.id == germaniumCenter.id {
                    continue
                }
                
                let xDifferenceSquared = pow(germaniumCenter.x - sphereAreaAtom.x, 2)
                let yDifferenceSquared = pow(germaniumCenter.y - sphereAreaAtom.y, 2)
                let zDifferenceSquared = pow(germaniumCenter.z - sphereAreaAtom.z, 2)
                let distanceSquared =
                    xDifferenceSquared + yDifferenceSquared + zDifferenceSquared
                
                distances[sphereAreaAtom] = sqrt(distanceSquared)
            }
            
            let sortedAtomsByAscendingDistances = distances
                .sorted { currentElement, nextElement  in
                    return currentElement.value < nextElement.value
                }
                .map { (atom, distance) in
                    return atom
                }
            
            let rangeAtomsToInclude = 0..<(germaniumCountInCluster - 1) // "- 1" accounting germanium atom-center of the cube area (which will also be the member of the cluster)
            var atomsInGivenAreaToBeConverted: [Atom]
            
            if rangeAtomsToInclude.count <= sortedAtomsByAscendingDistances.count {
                atomsInGivenAreaToBeConverted = [Atom](sortedAtomsByAscendingDistances[rangeAtomsToInclude])
            } else {
                atomsInGivenAreaToBeConverted = sortedAtomsByAscendingDistances
            }
            
            atomsToBeConverted.append(contentsOf: atomsInGivenAreaToBeConverted)
            
            print("Germanium atoms: \(germaniumEnumeratedIndex + 1) out of \(germaniumSphereAreas.count)", terminator: "\n")
        }
        
        return atomsToBeConverted
    }
}
