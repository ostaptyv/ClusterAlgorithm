//
//  URLManager.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 21.02.2022.
//

import Foundation

struct URLManager {
    var sourceURL: URL {
        get throws {
            return try workingFolderURL.appendingPathComponent("Source/")
        }
    }
    var resultsURL: URL {
        get throws {
            return try workingFolderURL.appendingPathComponent("Results/")
        }
    }
    
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
