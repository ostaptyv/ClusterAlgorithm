//
//  LAMMPSSerializer.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct LAMMPSSerializer {
    
    func encode(from atomDataSplitted: [Atom], originalTextData: String) throws -> String {
        // Prepare algorithm results to be written to the file
        let textAtomData = atomDataSplitted.map { atom -> String in
            var resultStringArray = [String]()

            resultStringArray.append(String(atom.id)) 
            resultStringArray.append(String(atom.type))
            resultStringArray.append(String(atom.x))
            resultStringArray.append(String(atom.y))
            resultStringArray.append(String(atom.z))

            return resultStringArray.joined(separator: " ")
        }
        .joined(separator: "\n")
        .appending("\n")

        // FIXME: FIXME: Implement non-mutating original data file feature, then delete this code:
        let atomDataRange = try findAtomDataRange(in: originalTextData, start: "Atoms # atomic\n\n", end: "\n\n")
        let modifiedTextData = originalTextData.replacingCharacters(in: atomDataRange, with: textAtomData)
        
        return modifiedTextData
    }
    
    func decode(from fileTextData: String) throws -> [Atom] {
        // Separate atom data away from service data
        var atomTextData: String!
        do {
            atomTextData = try retrieveAtomData(fromString: fileTextData, start: "Atoms # atomic\n\n", end: "\n\n")
        } catch {
            throw "Error: \(error)"
        }
        
        // Cut off all floating point number up to 3 decimal places
        let cutOffRegex = #"([0-9-]+\.[0-9]{1,3})[0-9]*"#
        atomTextData = atomTextData.replacingOccurrences(of: cutOffRegex,
                                                         with: "$1",
                                                         options: .regularExpression)
        
        let atomDataSplitted = atomTextData.components(separatedBy: "\n")
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
        
        return atomDataSplitted
    }
    
    
    private func findAtomDataRange(in dataString: String, start: String, end: String) throws -> ClosedRange<String.Index> {
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

    private func retrieveAtomData(fromString dataString: String, start: String, end: String) throws -> String {
        let atomDataRange = try findAtomDataRange(in: dataString, start: "Atoms # atomic\n\n", end: "\n\n")
        return String(dataString[atomDataRange])
    }
}
