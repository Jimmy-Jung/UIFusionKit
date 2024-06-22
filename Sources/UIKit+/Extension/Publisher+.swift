//
//  Publisher + Extension.swift
//  Tablet
//
//  Created by 정준영 on 3/27/24.
//

import Combine

@available(iOS 13.0, *)
public extension Publisher {
    func withUnretained<T: AnyObject>(_ object: T) -> Publishers.CompactMap<Self, (T, Self.Output)> {
        compactMap { [weak object] output in
            guard let object else { return nil }
            return (object, output)
        }
    }
}
