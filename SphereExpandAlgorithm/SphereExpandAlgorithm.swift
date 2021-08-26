//
//  SphereExpandAlgorithm.swift
//  SphereExpandAlgorithm
//
//  Created by Ostap Tyvonovych on 05.05.2021.
//

import Foundation

// MARK: - Extensions

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
extension Array {
    func chunk(by shouldBeCut: (Element, Element) -> Bool) -> [[Element]] {
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
fileprivate extension Array where Element == [[Atom]] {
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
fileprivate extension String {
    init(_ decimal: Decimal) {
        self.init(Double(truncating: decimal as NSNumber))
    }
}

// MARK: - Functions

fileprivate func findAtomDataRange(in dataString: String, start: String, end: String) throws -> ClosedRange<String.Index> {
    let optionalStartIndex = dataString.range(of: start)?.upperBound
    
    guard let startIndex = optionalStartIndex else {
        throw "Given start string not found in data file"
    }
    
    let optionalEndIndex = dataString.range(of: end,
                                            range: startIndex..<dataString.endIndex)? // we search for the end (terminating) string after we found the start string
        .lowerBound
    
    guard let endIndex = optionalEndIndex else {
        throw "Given start and/or end string not found in data file"
    }
    
    return startIndex...endIndex
}

fileprivate func retrieveAtomData(fromString dataString: String, start: String, end: String) throws -> String {
    let atomDataRange = try findAtomDataRange(in: dataString, start: "Atoms # atomic\n\n", end: "\n\n")
    return String(dataString[atomDataRange])
}

// MARK: - Main
func makeSphereClustersAroundGermaniumAtoms(usingDataFrom textDataFileURL: URL,
                                            count germaniumCountInCluster: UInt) throws {
    guard germaniumCountInCluster != 0 else {
        throw "⛔️ Error: You can't specify quantity of germanium atoms as zero because every germanium cluster contains at least 1 atom (itself)"
    }
    guard germaniumCountInCluster > 1 else {
        return
    }
    let germaniumCountInCluster = Int(germaniumCountInCluster)
    
    var fileTextData = ""
    
    // Read data from file
    do {
        fileTextData = try String(contentsOf: textDataFileURL, encoding: .utf8)
    } catch {
        throw "⛔️ Error when reading text data file: \(error)"
    }
    
    // Retrieve atom data out of service data
    var atomTextData: String!
    do {
        atomTextData = try retrieveAtomData(fromString: fileTextData, start: "Atoms # atomic\n\n", end: "\n\n")
    } catch {
        throw "⛔️ Error: \(error)"
    }
    
    // Cut off all floating point number up to 3 decimal places
    let cutOffRegex = #"([0-9-]+\.[0-9]{1,3})[0-9]*"#
    atomTextData = atomTextData.replacingOccurrences(of: cutOffRegex,
                                                     with: "$1",
                                                     options: .regularExpression)
    
    // Convert string data to numbers to be able to do mathematical operations on them
    var atomDataSplitted = atomTextData.components(separatedBy: "\n")
        .map { atomString -> Atom? in
            guard !atomString.isEmpty else {
                return nil
            }
            let atomStringSplitted = atomString.split(separator: " ")
            
            let atomID = Int(atomStringSplitted[0])!
            let atomType = Int(atomStringSplitted[1])!
            let atomX = Decimal(Double(atomStringSplitted[2])!)
            let atomY = Decimal(Double(atomStringSplitted[3])!)
            let atomZ = Decimal(Double(atomStringSplitted[4])!)
            
            return Atom(id: atomID, type: atomType, x: atomX, y: atomY, z: atomZ, shouldBeConverted: false)
        }
        .compactMap { $0 }
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
    
    
    // Re-assign ID numbers to respective indices the atoms have in sorted-by-chunks array
    for i in 0..<atomDataSplitted.count {
        atomDataSplitted[i].id = i
    }
    
    // Chunk atom array
    let atomDataChunked = atomDataSplitted
        .chunk { previousElement, nextElement in // chunk by Z axis
            return previousElement.z != nextElement.z
        }
        .map { zChunk in // chunk by Y axis
            return zChunk.chunk { previousElement, nextElement in
                return previousElement.y != nextElement.y
            }
        }
// --------------------------- Prints sorted array --------------------------------
//    atomDataSplitted.forEach { atomTuple in
//        print("\(atomTuple),")
//    }
// --------------------------------------------------------------------------------
    
    // Find germanium atoms indices in the array
    var germaniumIndices = [Int]()
    for (index, element) in atomDataSplitted.enumerated() {
        if element.type == 2 {
            germaniumIndices.append(index)
        }
    }
    
    let germaniumCount = germaniumIndices.count
    print("* General number of Ge atoms found: \(germaniumCount)")
    
    // Define sphere radius based on one germanium atom to use it further in the algorithm
    print("------------------ START DEFINING SPHERE RADIUS --------------------")
    var lowerRadiusBound: Decimal = 0.0
    var upperRadiusBound: Decimal = atomDataChunked.last![0][0].z - atomDataChunked.first![0][0].z
    var sphereAreaRadius: Decimal
    var currentGermaniumCountDifference = 0
    var previousGermaniumCountDifference = 0
    
    repeat {
        previousGermaniumCountDifference = currentGermaniumCountDifference
        print("Suggested sphere radius (lower): \(lowerRadiusBound)", terminator: "\n")
        print("Suggested sphere radius (upper): \(upperRadiusBound)", terminator: "\n")
        var atomsInSphereAreaCount = 0
        let middleRadius = ((upperRadiusBound - lowerRadiusBound) / 2) + lowerRadiusBound
        // FIXME: Imitate checking the central atom with coordinates (x: 0.0, y: 0.0, z: 0.0). This is made to prevent choosing germanium atom near the surface of the nanowire, because in that case radius maybe larger than it's needed. Type and ID values don't have a matter here
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
    print("------------------- END DEFINING SPHERE RADIUS ---------------------")
    
    // FIXME: Used if we need to generate cluster with specific radius; should be rewrited as a separate option of a algorithm standing together with a count defined clusters
//    sphereAreaRadius = 25.807 + 1.4 //51.614
    
    // Create cubic areas around germnaium atoms
    print("\n------------------- START GENERATING CUBE AREAS --------------------")
    var germaniumCubeAreas = [Int: [Int]]() // the key is the index of germanium atom in atom array, the value is atom indices in atom array inside the cubic area associated with the given germanium atom
    for (germaniumIndexNumber, germaniumIndex) in germaniumIndices.enumerated() {
        var cubeAreaIndices = [Int]()
        let cubeAreaEdgeHalfLength = sphereAreaRadius
        let germaniumAtom = atomDataSplitted[germaniumIndex]
        
        for zChunk in atomDataChunked {
            let z = zChunk[0][0].z
            let cubeZRange = (germaniumAtom.z - cubeAreaEdgeHalfLength...germaniumAtom.z + cubeAreaEdgeHalfLength)
            if !cubeZRange.contains(z) {
                continue
            }

            for yChunk in zChunk {
                let y = yChunk[0].y
                let cubeYRange = (germaniumAtom.y - cubeAreaEdgeHalfLength...germaniumAtom.y + cubeAreaEdgeHalfLength)
                if !cubeYRange.contains(y) {
                    continue
                }

                for element in yChunk {
                    let x = element.x
                    let cubeXRange = (germaniumAtom.x - cubeAreaEdgeHalfLength...germaniumAtom.x + cubeAreaEdgeHalfLength)

                    if cubeXRange.contains(x) {
                        cubeAreaIndices.append(element.id)
                        if germaniumAtom.id != element.id {
                            // FIXME: Debug code
//                            atomDataSplitted[element.id].type = 3
                        }
                    }
                }
            }
        }
        germaniumCubeAreas[germaniumAtom.id] = cubeAreaIndices
        print("Germanium atoms: \(germaniumIndexNumber + 1) out of \(germaniumCount); cube area count: \(germaniumCubeAreas.count)", terminator: "\n")
    }
    print("--------------------- END GENERATING CUBE AREAS ----------------------")

    // Create sphere areas around germanium atoms
    print("\n------------------- START GENERATING SPHERE AREAS --------------------")
    var germaniumSphereAreas = [Int: [Int]]() // the key is the index of germanium atom in atom array, the value is atom indices in atom array inside the spheric area associated with the given germanium atom

    for (germaniumIndexNumber, germaniumIndex) in germaniumIndices.enumerated() {
        var sphereAreaIndices = [Int]()
        let germaniumAtom = atomDataSplitted[germaniumIndex]

        for cubeAreaAtomIndex in germaniumCubeAreas[germaniumIndex]! {
            let atomElement = atomDataSplitted[cubeAreaAtomIndex]
            let xSquared = pow(atomElement.x - germaniumAtom.x, 2)
            let ySquared = pow(atomElement.y - germaniumAtom.y, 2)
            let zSquared = pow(atomElement.z - germaniumAtom.z, 2)
            let radiusSquared = pow(sphereAreaRadius, 2)

            if xSquared + ySquared + zSquared <= radiusSquared {
                sphereAreaIndices.append(atomElement.id)
            }
        }
        germaniumSphereAreas[germaniumAtom.id] = sphereAreaIndices
        print("Germanium atoms: \(germaniumIndexNumber + 1) out of \(germaniumCount); sphere area count: \(germaniumSphereAreas.count)", terminator: "\n")
    }
    print("-------------------- END GENERATING SPHERE AREAS ---------------------")

    // Calculate the distances between atoms inside spheric area and germanium center, take quantity equal to 'germaniumCountInCluster' and mark them as "should be converted"
    print("\n--------- BEGIN CALCULATING DISTANCES BETWEEN ATOMS IN SPHERES ---------")
    for (germaniumIndexNumber, element: (germaniumIndex, sphereAreaIndices)) in germaniumSphereAreas.enumerated() {
        var distances = [Int: Double]() // the key is the index of the atom and the value is the distance between the atom and the germanium center
        let germaniumCenter = atomDataSplitted[germaniumIndex]
        
        for sphereAreaIndex in sphereAreaIndices {
            let sphereAreaAtom = atomDataSplitted[sphereAreaIndex]
            if sphereAreaAtom.id == germaniumCenter.id {
                continue
            }
            
            let xDifferenceSquared = pow(germaniumCenter.x - sphereAreaAtom.x, 2)
            let yDifferenceSquared = pow(germaniumCenter.y - sphereAreaAtom.y, 2)
            let zDifferenceSquared = pow(germaniumCenter.z - sphereAreaAtom.z, 2)
            let distanceSquared =
                xDifferenceSquared + yDifferenceSquared + zDifferenceSquared
            
            distances[sphereAreaIndex] = Double(truncating: distanceSquared as NSNumber).squareRoot()
            // FIXME: Debug code
//            atomDataSplitted[sphereAreaIndex].type = 4
        }
        
        let sortedDistances = distances.sorted { currentElement, nextElement  in
            return currentElement.value < nextElement.value
        }
        
        let rangeAtomsToConvert = 0..<germaniumCountInCluster - 1 // "- 1" accounting germanium atom-center of the cube area (which will also be the member of the cluster)
        let atomsToBeConverted: [(key: Int, value: Double)]
        // FIXME: To delete
        if rangeAtomsToConvert.count <= sortedDistances.count {
            atomsToBeConverted = [(key: Int, value: Double)](sortedDistances[rangeAtomsToConvert])
        } else {
            atomsToBeConverted = sortedDistances
        }
        
        for (atomIndexToBeConverted, _) in atomsToBeConverted {
            atomDataSplitted[atomIndexToBeConverted].shouldBeConverted = true
        }
        print("Germanium atoms: \(germaniumIndexNumber + 1) out of \(germaniumCount)", terminator: "\n")
    }
    print("---------- END CALCULATING DISTANCES BETWEEN ATOMS IN SPHERES ----------")
    
    // Convert atoms to Germanium ones
    print("------------------- BEGIN CONVERTING FINAL ATOMS ---------------------")
    for (index, var atomElement) in atomDataSplitted.enumerated() {
        print("Atoms passed: \(index + 1) out of \(atomDataSplitted.count)")
        if atomElement.shouldBeConverted {
            // FIXME: Debug code
//            atomElement.type = 5
            atomElement.type = 2
            atomDataSplitted[index] = atomElement
        }
    }
    print("-------------------- END CONVERTING FINAL ATOMS ----------------------")
    
    // Calculate
    var germaniumCountAfterConverting = 0
    for atomElement in atomDataSplitted {
        if atomElement.type == 2 {
            germaniumCountAfterConverting += 1
        }
    }
    print("\nGeneral atoms count: \(atomDataSplitted.count)")
    print("Germanium atoms count before generating the cluster: \(germaniumCount)")
    print("Germanium atoms count after generating the cluster: \(germaniumCountAfterConverting)")

    // Prepare algorithm results to be written to the file
    let textAtomData = atomDataSplitted.map { atomTuple -> String in
        var resultStringArray = [String]()

        resultStringArray.append(String(atomTuple.id + 1)) // since particle IDs was reassigned to respective indices they had in the 'atomDataSplitted' array (indices in arrays are zero-based) we should add 1 to make them one-based (Ovito data format requires us to assign particles one-based IDs)
        resultStringArray.append(String(atomTuple.type))
        resultStringArray.append(String(atomTuple.x))
        resultStringArray.append(String(atomTuple.y))
        resultStringArray.append(String(atomTuple.z))

        return resultStringArray.joined(separator: " ")
    }
    .joined(separator: "\n")
    .appending("\n")

    let atomDataRange = try! findAtomDataRange(in: fileTextData, start: "Atoms # atomic\n\n", end: "\n\n")
    let modifiedTextData = fileTextData.replacingCharacters(in: atomDataRange, with: textAtomData)

    // Write data to the original file
    do {
        try modifiedTextData.write(to: textDataFileURL, atomically: true, encoding: .utf8)
    } catch {
        throw "⛔️ Error when writing to text data file: \(error)"
    }
}

//if var currentDirectoryURL = URL(string: "file://" + FileManager.default.currentDirectoryPath) {
//    
//    currentDirectoryURL.appendPathComponent("AtomPositions.data")
//    do {
//        try makeSphereAroundGermaniumAtoms(usingDataFrom: currentDirectoryURL,
//                                           distanceBetweenAtoms: 5.432 / 2, // half of 'a' parameter
//                                           sphereRadius: 20.0)
//        print("✅ Operation successful.")
//    } catch {
//        print(error.localizedDescription)
//        print("Operation aborted.")
//    }
//} else {
//    print("⛔️ Error when retrieving current directory URL. " +
//            #"Directory URL: "file://" + "\#(FileManager.default.currentDirectoryPath)""#)
//    print("Operation aborted.")
//}
