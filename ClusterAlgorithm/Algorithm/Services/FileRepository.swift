//
//  FileRepository.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 20.02.2022.
//

import Foundation

struct FileRepository: RepositoryProtocol {
    private let fileManager = FileManager.default
    
    internal let fileName: String
    private var workingFolderURL: URL {
        get throws {
            var documentURL = try fileManager.url(for: .documentDirectory,
                                                     in: .userDomainMask,
                                                     appropriateFor: nil,
                                                     create: false)
            documentURL.appendPathComponent("Diploma/XcodeProjects/ClusterAlgorithm/")
            
            return documentURL
        }
    }
    private let sourcePath = "Source/"
    private let resultsPath = "Results/"
    
    // MARK: - Write/read methods
    
    func readData() throws -> Data {
        let readURL: URL
        do {
            readURL = try workingFolderURL
                .appendingPathComponent(sourcePath)
                .appendingPathComponent(fileName)
        } catch {
            throw "Error when composing a URL to read the file from: \(error)"
        }
        
        return try readData(fromURL: readURL)
    }
    
    func writeData(_ data: Data) throws {
        let writePath: String
        do {
            writePath = try workingFolderURL
                .appendingPathComponent(resultsPath)
                .appendingPathComponent(fileName)
                .path
        } catch {
            throw "Error when composing a URL to write the file to: \(error)"
        }
        
        try writeData(data, atPath: writePath)
    }
    
    // MARK: - Private methods
    
    // These methods may be declared as 'internal' for debug purposes:
    private func readData(fromURL readURL: URL) throws -> Data {
        let data: Data
        do {
            data = try Data(contentsOf: readURL)
        } catch {
            throw "Error when reading a file: \(error)"
        }
        
        return data
    }
    private func writeData(_ data: Data, atPath writePath: String) throws {
        let isSuccess = fileManager.createFile(atPath: writePath, contents: data)
        guard isSuccess else {
            throw "Error when writing a file"
        }
    }
    
    // MARK: - Initializers
    
    init(fileName: String) {
        self.fileName = fileName
    }
}
