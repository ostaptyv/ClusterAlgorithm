//
//  String+LocalizedError.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
