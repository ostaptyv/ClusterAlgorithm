//
//  LAMMPSSerializer.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

struct LAMMPSSerializer {
    private let startString = "Atoms # atomic\n\n"
    private let endString = "\n\n"
    
    func encode(from atomData: [Atom], originalTextData: String) throws -> String {
        // Prepare algorithm results to be written to the file
        let textAtomData = atomData.map { atom -> String in
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
        let atomDataRange = try findAtomDataRange(in: originalTextData, start: startString, end: endString)
        let modifiedTextData = originalTextData.replacingCharacters(in: atomDataRange, with: textAtomData)
        
        return modifiedTextData
    }
    
    func decode(from fileTextData: String) throws -> [Atom] {
        // Separate atom data away from service data
        var atomTextData: String!
        do {
            atomTextData = try retrieveAtomData(fromString: fileTextData, start: startString, end: endString)
        } catch {
            throw "Error: \(error)"
        }
        
//        // Cut off all floating point number up to 3 decimal places
//        let cutOffRegex = #"([0-9-]+\.[0-9]{1,3})[0-9]*"#
//        atomTextData = atomTextData.replacingOccurrences(of: cutOffRegex,
//                                                         with: "$1",
//                                                         options: .regularExpression)
        
        let atomDataSplitted = atomTextData.components(separatedBy: "\n")
            .map { atomString -> Atom? in
                guard !atomString.isEmpty else {
                    return nil
                }
                let atomStringSplitted = atomString.split(separator: " ")
                
                let id = Int(atomStringSplitted[0])!
                let type = Int(atomStringSplitted[1])!
                let x = Double(atomStringSplitted[2])!
                let y = Double(atomStringSplitted[3])!
                let z = Double(atomStringSplitted[4])!
                
                return Atom(id: id,
                            type: type,
                            x: x,
                            y: y,
                            z: z)
            }
            .compactMap { $0 }
        
        return atomDataSplitted
    }
    
    
    private func findAtomDataRange(in dataString: String, start: String, end: String) throws -> ClosedRange<String.Index> {
        let optionalStartIndex = dataString.range(of: start)?.upperBound
        
        guard let startIndex = optionalStartIndex else {
            throw "Error: Given start string not found in the data file"
        }
        
        let optionalEndIndex = dataString.range(of: end,
                                                range: startIndex..<dataString.endIndex)? // we search for the end (terminating) string after we found the start string
            .lowerBound
        
        guard let endIndex = optionalEndIndex else {
            throw "Error: Given end string not found in the data file"
        }
        
        return startIndex...endIndex
    }

    private func retrieveAtomData(fromString dataString: String, start: String, end: String) throws -> String {
        let atomDataRange = try findAtomDataRange(in: dataString, start: start, end: end)
        return String(dataString[atomDataRange])
    }
}
