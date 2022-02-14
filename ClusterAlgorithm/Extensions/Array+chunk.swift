//
//  Array+chunk.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

typealias Chunk2D<Element> = [[Element]]
typealias Chunk3D<Element> = [[[Element]]]

extension Array {
    func chunk(by shouldBeCut: (Element, Element) -> Bool) -> Chunk2D<Element> {
        var lastCuttingEdge = 0
        var result = [[Element]]()
        for i in 0..<self.count - 1 {
            if shouldBeCut(self[i], self[i + 1]) {
                let chunk = [Element](self[lastCuttingEdge...i])
                result.append(chunk)
                lastCuttingEdge = i + 1
            }
        }
        let lastChunk = [Element](self[lastCuttingEdge..<self.count])
        result.append(lastChunk)
        
        return result
    }
}
