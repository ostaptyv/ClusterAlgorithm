//
//  Atom.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct Atom: Hashable {
    var id: Int
    var type: Int
    var x: Double
    var y: Double
    var z: Double
    
    static let zero = Atom(id: 0,
                           type: 0,
                           x: 0.0,
                           y: 0.0,
                           z: 0.0)
}
