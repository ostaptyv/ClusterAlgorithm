//
//  FileRepository.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 20.02.2022.
//

import Foundation

struct FileRepository: RepositoryProtocol {
    private let fileManager = FileManager.default
    
    let fileName: String
    let urlManager = URLManager()
    
    private var readURL: URL {
        get throws {
            let result: URL
            do {
                result = try urlManager.sourceURL
                    .appendingPathComponent(fileName)
            } catch {
                throw "Error when composing a URL to read the file from: \(error)"
            }
            return result
        }
    }
    private var writeURL: URL {
        get throws {
            let result: URL
            do {
                result = try urlManager.resultsURL
                    .appendingPathComponent(fileName)
            } catch {
                throw "Error when composing a URL to write the file to: \(error)"
            }
            return result
        }
    }
    
    // MARK: - Write/read methods
    
    func readData() throws -> Data {
        let readURL = try readURL
        
        return try readData(fromURL: readURL)
    }
    func writeData(_ data: Data) throws {
        let writePath = try writeURL.path
        
        try writeData(data, atPath: writePath)
    }
    func copyDataToResults() throws {
        do {
            try fileManager.copyItem(at: readURL, to: writeURL)
        } catch CocoaError.fileWriteFileExists {
            try copyDataReplacingExisting()
        } catch {
            throw "Error when copying a file into \"\(try urlManager.resultsURL)\" (couldn't recover): \(error)"
        }
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
    
    private func copyDataReplacingExisting() throws {
        do {
            try fileManager.removeItem(at: writeURL)
            try fileManager.copyItem(at: readURL, to: writeURL)
        } catch {
            throw "Error when copying a file into \"\(try urlManager.resultsURL)\" (replacing an existing file with the new one both of which share the same name): \(error)"
        }
    }
    
    // MARK: - Initializers
    
    init(fileName: String) {
        self.fileName = fileName
    }
}
