//
//  Array+atomDescription.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

extension Array where Element == [[Atom]] {
    var atomDescription: String {
        var result = "[\n"
        for zChunk in self {
            result.append("    [\n")
            for yChunk in zChunk {
                result.append("        [\n")
                for element in yChunk {
                    result.append("            \(element),\n")
                }
                result.append("        ],\n")
            }
            result.append("    ],\n")
        }
        result.append("]")
        return result
    }
}
