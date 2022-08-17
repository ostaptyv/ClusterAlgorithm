//
//  LayerLevel.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 17.08.2022.
//

import Foundation

struct LayerLevel: OptionSet {
    let rawValue: Int
    
    static let cubeArea = LayerLevel(rawValue: 1 << 0)
    static let sphereArea = LayerLevel(rawValue: 1 << 1)
    static let cluster = LayerLevel(rawValue: 1 << 2)
}
