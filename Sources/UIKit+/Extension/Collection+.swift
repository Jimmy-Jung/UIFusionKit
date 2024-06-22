//
//  Collection+Extension.swift
//  
//
//  Created by 정준영 on 2023/09/08.
//

import Foundation

public extension Collection {
    // An extension that adds a subscript to Collection
    subscript(safe index: Index) -> Element? {
        // Returns nil if the index is out of range of Collection
        return indices.contains(index) ? self[index] : nil
    }
}
