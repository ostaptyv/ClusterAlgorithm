//
//  RepositoryProtocol.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 20.02.2022.
//

import Foundation

protocol RepositoryProtocol {
    func readData() throws -> Data
    func writeData(_ data: Data) throws
    
    /// Creates a new instance of the repository.
    ///
    ///  - Parameters:
    ///     - fileName: The file name with the file extension.
    init(fileName: String)
}
