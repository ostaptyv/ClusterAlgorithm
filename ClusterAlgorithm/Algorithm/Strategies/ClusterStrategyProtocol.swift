//
//  ClusterStrategyProtocol.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 16.02.2022.
//

import Foundation

protocol ClusterStrategyProtocol {
    var fileURL: URL? { get set }
    
    func execute() throws
}
