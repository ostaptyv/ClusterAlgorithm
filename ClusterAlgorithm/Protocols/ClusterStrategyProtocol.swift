//
//  ClusterStrategyProtocol.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

protocol ClusterStrategyProtocol {
    /// The file name with file extension being processed by this strategy.
    ///
    /// The property should not contain any other paths, schemes, arguments, etc.
    ///
    /// For example:
    ///
    ///     let strategy = YourStrategy()
    ///     strategy.fileNameURL = URL(string: "my_file.txt")!
    ///
    /// - Returns: `URL` instance containing a file name and its extension, and `nil` if the value wasn't set.
    var fileNameURL: URL? { get set }
    
    func execute() throws
}
