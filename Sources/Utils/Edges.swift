//
//  Edges.swift
//  Tablet
//
//  Created by 정준영 on 4/23/24.
//

import UIKit

@frozen public enum Edges {
    case top(_ length: CGFloat)
    case bottom(_ length: CGFloat)
    case leading(_ length: CGFloat)
    case trailing(_ length: CGFloat)
    
    public var insets: UIEdgeInsets {
        switch self {
                
            case .top(let length):
                return UIEdgeInsets.init(top: length, left: 0, bottom: 0, right: 0)
            case .bottom(let length):
                return UIEdgeInsets.init(top: 0, left: 0, bottom: length, right: 0)
            case .leading(let length):
                return UIEdgeInsets.init(top: 0, left: length, bottom: 0, right: 0)
            case .trailing(let length):
                return UIEdgeInsets.init(top: 0, left: 0, bottom: 0, right: length)
                
        }
    }
}
