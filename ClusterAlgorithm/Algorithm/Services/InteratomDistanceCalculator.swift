//
//  InteratomDistanceCalculator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct InteratomDistanceCalculator {
    func generateJoinedClusterAreas(outOf sphereAreas: [Atom: [Atom]], trimmingExtraAtomsToCount atomsInClusterCount: Int) -> [Atom] {
        var clusterAreasJoined = [Atom]()
        
        for (clusterCenterEnumeratedIndex, element: (clusterCenter, sphereAreaAtoms)) in sphereAreas.enumerated() {
            let atomsByAscendingDistances = calculateInteratomDistance(from: clusterCenter, toEachAtomIn: sphereAreaAtoms)
                .sorted { currentElement, nextElement in
                    return nextElement.value > currentElement.value // the value is the distance
                }
                .map { (atom, distance) in
                    return atom
                }
            
            let clusterArea = trimAtoms(atomsByAscendingDistances, toCount: atomsInClusterCount)
            clusterAreasJoined.append(contentsOf: clusterArea)
            
            print("Germanium atoms: \(clusterCenterEnumeratedIndex + 1) out of \(sphereAreas.count)", terminator: "\n")
        }
        
        return clusterAreasJoined
    }
    
    func calculateInteratomDistance(from clusterCenter: Atom, toEachAtomIn sphereAreaAtoms: [Atom]) -> [Atom: Double] {
        var distances = [Atom: Double]() // the key is the atom from the sphere area; the value is the distance between the atom and the germanium center
        for sphereAreaAtom in sphereAreaAtoms {
            if sphereAreaAtom.id == clusterCenter.id {
                continue
            }
            
            let xDifferenceSquared = pow(clusterCenter.x - sphereAreaAtom.x, 2)
            let yDifferenceSquared = pow(clusterCenter.y - sphereAreaAtom.y, 2)
            let zDifferenceSquared = pow(clusterCenter.z - sphereAreaAtom.z, 2)
            let distanceSquared =
            xDifferenceSquared + yDifferenceSquared + zDifferenceSquared
            
            distances[sphereAreaAtom] = sqrt(distanceSquared)
        }
        return distances
    }
    
    func trimAtoms(_ sortedAtoms: [Atom], toCount count: Int) -> [Atom] {
        let atomsToIncludeRange = 0..<(count - 1) // "- 1" accounting germanium atom-center of the cube area (which will also be the member of the cluster)
        let trimmedAtoms: ArraySlice<Atom>
        
        if atomsToIncludeRange.count <= sortedAtoms.count {
            trimmedAtoms = sortedAtoms[atomsToIncludeRange]
        } else {
            trimmedAtoms = ArraySlice<Atom>(sortedAtoms)
        }
        
        return [Atom](trimmedAtoms)
    }
}
