//
//  String+initDecimal.swift
//  ClusterAlgorithm
//
//  Created by Ostap Tyvonovych on 14.02.2022.
//

import Foundation

extension String {
    init(_ decimal: Decimal) {
        self.init(Double(truncating: decimal as NSNumber))
    }
}
