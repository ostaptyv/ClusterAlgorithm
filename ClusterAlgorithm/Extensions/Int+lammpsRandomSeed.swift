//
//  Int+lammpsRandomSeed.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 03.04.2022.
//

import Foundation

extension Int {
    static func lammpsRandomSeed() -> Self {
        return (1...900000000).randomElement()! // 900000000 is defined in LAMMPS source code
    }
}
