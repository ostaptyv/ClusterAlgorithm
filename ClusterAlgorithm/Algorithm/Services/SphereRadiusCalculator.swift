//
//  SphereRadiusCalculator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct SphereRadiusCalculator {
    func defineSphereRadius(for germaniumCountInCluster: Int, atomDataSplitted: [Atom], upperRadiusBound: Double) -> Double {
        var lowerRadiusBound: Double = 0.0
        var upperRadiusBound: Double = upperRadiusBound
        var sphereAreaRadius: Double
        var currentGermaniumCountDifference = 0
        var previousGermaniumCountDifference = 0
        
        repeat {
            previousGermaniumCountDifference = currentGermaniumCountDifference
            print("Suggested sphere radius (lower): \(lowerRadiusBound)", terminator: "\n")
            print("Suggested sphere radius (upper): \(upperRadiusBound)", terminator: "\n")
            var atomsInSphereAreaCount = 0
            let middleRadius = ((upperRadiusBound - lowerRadiusBound) / 2) + lowerRadiusBound
            // FIXME: FIXME: Imitate checking the central atom with coordinates (x: 0.0, y: 0.0, z: 0.0). This is made to prevent choosing germanium atom near the surface of the nanowire, because in that case radius maybe larger than it's needed. Type and ID values don't matter here
            let germaniumAtom: Atom = .zero // atomDataSplitted[germaniumIndices.first!]
            
            for atomElement in atomDataSplitted {
                let xSquared = pow(atomElement.x - germaniumAtom.x, 2)
                let ySquared = pow(atomElement.y - germaniumAtom.y, 2)
                let zSquared = pow(atomElement.z - germaniumAtom.z, 2)
                let radiusSquared = pow(middleRadius, 2)
                
                if xSquared + ySquared + zSquared <= radiusSquared {
                    atomsInSphereAreaCount += 1
                }
            }
            
            currentGermaniumCountDifference = atomsInSphereAreaCount - germaniumCountInCluster
            if currentGermaniumCountDifference > 0 {
                upperRadiusBound = middleRadius
            } else {
                lowerRadiusBound = middleRadius
            }
            
            print("Suggested sphere radius: \(middleRadius), count: \(atomsInSphereAreaCount)", terminator: "\n")
            sphereAreaRadius = middleRadius
            
        } while abs(previousGermaniumCountDifference) != abs(currentGermaniumCountDifference) || currentGermaniumCountDifference < 0
        
        return sphereAreaRadius
    }
}
