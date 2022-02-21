//
//  URLManager.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 21.02.2022.
//

import Foundation

struct URLManager {
    let sourcePath = "Source/"
    let resultsPath = "Results/"
    
    var workingFolderURL: URL {
        get throws {
            var documentURL = try FileManager.default.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: false)
            documentURL.appendPathComponent("Diploma/XcodeProjects/ClusterAlgorithm/")
            
            return documentURL
        }
    }
}
