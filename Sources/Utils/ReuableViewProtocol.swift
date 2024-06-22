//
//  ReuableViewProtocol.swift
//  
//
//  Created by 정준영 on 2023/08/30.
//

import UIKit

public protocol ReusableViewProtocol {
    static var identifier: String {get}
    var identifier: String {get}
}

public extension ReusableViewProtocol {
    static var identifier: String { return String(describing: self) }
    var identifier: String { return Self.identifier }
}

extension UIViewController: ReusableViewProtocol {}
extension UIView: ReusableViewProtocol {}
