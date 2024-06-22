//
//  UIView+Stylable.swift
//  Tablet
//
//  Created by 정준영 on 11/30/23.
//

import UIKit

public extension UIFusion where Self: UIControl {

    @available(iOS 14.0, *)
    @discardableResult
    func addAction(_ action: @escaping (() -> ()), for event: UIControl.Event = .touchUpInside) -> Self {
        let identifier = UIAction.Identifier(String(describing: event.rawValue))
        let action = UIAction(identifier: identifier) { _ in
            action()
        }
        self.removeAction(identifiedBy: identifier, for: event)
        self.addAction(action, for: event)
        return self
    }
    
    @available(iOS 14.0, *)
    @discardableResult
    func addAction(_ action: @escaping ((Self) -> ()), for event: UIControl.Event = .touchUpInside) -> Self {
        let identifier = UIAction.Identifier(String(describing: event.rawValue))
        let action = UIAction(identifier: identifier) { [weak self] _ in
            guard let self else { return }
            action(self)
        }
        self.removeAction(identifiedBy: identifier, for: event)
        self.addAction(action, for: event)
        return self
    }
    
    @discardableResult
    func isEnabled(_ bool: Bool) -> Self {
        self.isEnabled = bool
        return self
    }
    
    @discardableResult
    func isUserInteractionEnabled(_ bool: Bool) -> Self {
        self.isUserInteractionEnabled = bool
        return self
    }
    
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
}
