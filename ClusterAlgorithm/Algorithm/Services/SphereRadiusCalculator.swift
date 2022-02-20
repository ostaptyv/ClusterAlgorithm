//
//  SphereRadiusCalculator.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct SphereRadiusCalculator {
    func defineSphereRadius(forCount atomsInClusterCount: Int, in atomData: [Atom], limitingRadiusUpTo upperRadiusBound: Double) -> Double {
        var sphereAreaRadius: Double
        var lowerRadiusBound: Double = 0.0
        var upperRadiusBound: Double = upperRadiusBound
        var currentGermaniumCountDifference = 0
        var previousGermaniumCountDifference = 0
        
        repeat {
            previousGermaniumCountDifference = currentGermaniumCountDifference
            print("Suggested sphere radius (lower): \(lowerRadiusBound)", terminator: "\n")
            print("Suggested sphere radius (upper): \(upperRadiusBound)", terminator: "\n")
            var atomsInSphereAreaCount = 0
            let middleRadius = ((upperRadiusBound - lowerRadiusBound) / 2) + lowerRadiusBound
            let centralAtom: Atom = .zero
            
            for atom in atomData {
                let xSquared = pow(atom.x - centralAtom.x, 2)
                let ySquared = pow(atom.y - centralAtom.y, 2)
                let zSquared = pow(atom.z - centralAtom.z, 2)
                let radiusSquared = pow(middleRadius, 2)
                
                if xSquared + ySquared + zSquared <= radiusSquared {
                    atomsInSphereAreaCount += 1
                }
            }
            
            currentGermaniumCountDifference = atomsInSphereAreaCount - atomsInClusterCount
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
