//
//  Dimensions.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

extension Nanowire {
    struct Dimensions {
        let length: Double
        let radius: Double
        
        init(length: Double, radius: Double) throws {
            guard length > 0.0 else {
                throw "Error: Nanowire length can't be less or equal to zero"
            }
            guard radius > 0.0 else {
                throw "Error: Nanowire radius can't be less or equal to zero"
            }
            
            self.length = length
            self.radius = radius
        }
    }
}

extension Nanowire.Dimensions {
    static let siliciumNanowire = try! Nanowire.Dimensions(length: 488.88, radius: .a * 5)
    static let phononAnalysis = try! Nanowire.Dimensions(length: 19.45 * 2, radius: .a * 3)
    static func a(length lengthMultipleOfLatticeConstant: UInt,
                  radius radiusMultipleOfLatticeConstant: UInt) -> Nanowire.Dimensions {
        
        let length = Double(lengthMultipleOfLatticeConstant)
        let radius = Double(radiusMultipleOfLatticeConstant)
        return try! Nanowire.Dimensions(length: .a * length, radius: .a * radius)
    }
}
