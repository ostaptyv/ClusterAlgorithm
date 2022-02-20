//
//  DataPreparer.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct DataPreparer {
    func sortAtomDataInIncreasingOrder(_ atomData: [Atom]) -> [Atom] {
        return atomData
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
    }
    
    func chunkAtomData(_ atomData: [Atom]) -> Chunk3D<Atom> {
        return atomData
            .chunk { previousElement, nextElement in // chunk by Z axis
                return previousElement.z != nextElement.z
            }
            .map { zChunk in // chunk by Y axis
                return zChunk.chunk { previousElement, nextElement in
                    return previousElement.y != nextElement.y
                }
            }
    }
    
    func shiftIDsToBaseOne(in atomsWithZeroBasedIDs: [Atom]) -> [Atom] {
        return atomsWithZeroBasedIDs
            .map { atom in
                var atom = atom
                atom.id = atom.id + 1 // since particle IDs was reassigned to respective indices they had in the 'atomData' array (indices in arrays are zero-based) we should add 1 to make them one-based (Ovito data format requires us to assign particles one-based IDs)
                
                return atom
            }
    }
    
    func reassignIDsToIndices(of atomData: [Atom]) -> [Atom] {
        // Re-assign ID numbers to respective indices the atoms have in sorted-by-chunks array
        var result = [Atom]()
        for i in atomData.indices {
            var atom = atomData[i]
            atom.id = i
            
            result.append(atom)
        }
        return result
    }
}
