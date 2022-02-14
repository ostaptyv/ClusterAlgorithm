//
//  DataPreparer.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct DataPreparer {
    func prepareRawData(_ rawData: [Atom]) -> [Atom] {
        // Convert string data to numbers to be able to do mathematical operations on them
        var atomDataSplitted = rawData
            .sorted { currentElement, nextElement in // sort atoms in increasing order by Z axis
                return nextElement.z > currentElement.z
            }
            .sorted { currentElement, nextElement in // sort atoms in increasing order by Y axis (in Z-chunks)
                if nextElement.z == currentElement.z {
                    return nextElement.y > currentElement.y
                } else {
                    return false
                }
            }
            .sorted { currentElement, nextElement in // sort atoms in increasing order by X axis (in ZY-chunks)
                if nextElement.z == currentElement.z && nextElement.y == currentElement.y {
                    return nextElement.x > currentElement.x
                } else {
                    return false
                }
            }
        
        reassignIDsToIndices(of: &atomDataSplitted)
        
        return atomDataSplitted
    }
    
    func chunkAtomData(_ atomDataSplitted: [Atom]) -> Chunk3D<Atom> {
        return atomDataSplitted
            .chunk { previousElement, nextElement in // chunk by Z axis
                return previousElement.z != nextElement.z
            }
            .map { zChunk in // chunk by Y axis
                return zChunk.chunk { previousElement, nextElement in
                    return previousElement.y != nextElement.y
                }
            }
    }
    
    func makeOneBasedAtomIDs(in atomsWithZeroBasedIDs: inout [Atom]) {
        atomsWithZeroBasedIDs = atomsWithZeroBasedIDs.map { atom in
            var atom = atom
            atom.id = atom.id + 1 // since particle IDs was reassigned to respective indices they had in the 'atomDataSplitted' array (indices in arrays are zero-based) we should add 1 to make them one-based (Ovito data format requires us to assign particles one-based IDs)
            
            return atom
        }
    }
    
    private func reassignIDsToIndices(of atomDataSplitted: inout [Atom]) {
        // Re-assign ID numbers to respective indices the atoms have in sorted-by-chunks array
        for i in atomDataSplitted.indices {
            atomDataSplitted[i].id = i
        }
    }
}
