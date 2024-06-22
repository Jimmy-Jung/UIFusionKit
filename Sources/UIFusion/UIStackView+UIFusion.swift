//
//  UIStackView+Stylable.swift
//  Tablet
//
//  Created by 정준영 on 2023/08/28.
//

import UIKit.UIStackView

public extension UIFusion where Self: UIStackView {
    
    @discardableResult
    func alignment(_ alignment: UIStackView.Alignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    @discardableResult
    func distribution(_ distribution: UIStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }
    
    @discardableResult
    func axis(_ axis: NSLayoutConstraint.Axis) -> Self {
        self.axis = axis
        return self
    }
    
    @discardableResult
    func spacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }
    
    @discardableResult
    func isBaselineRelativeArrangement(_ bool: Bool) -> Self {
        self.isBaselineRelativeArrangement = bool
        return self
    }
    
    @discardableResult
    func isLayoutMarginsRelativeArrangement(_ bool: Bool) -> Self {
        self.isLayoutMarginsRelativeArrangement = bool
        return self
    }
    
    @discardableResult
    func addArrangedSubview(_ view: UIView) -> Self {
        self.addArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func addArrangedSubviews(_ views: [UIView]) -> Self {
        views.forEach { self.addArrangedSubview($0) }
        return self
    }
    
    @discardableResult
    func insertArrangedSubview(_ view: UIView, at stackIndex: Int) -> Self {
        self.insertArrangedSubview(view, at: stackIndex)
        return self
    }
    
    @discardableResult
    func removeArrangedSubview(_ view: UIView) -> Self {
        self.removeArrangedSubview(view)
        return self
    }
    
    @discardableResult
    func customSpacing(after arrangedSubview: UIView) -> CGFloat {
        return self.customSpacing(after: arrangedSubview)
    }
    
    @discardableResult
    func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) -> Self {
        self.setCustomSpacing(spacing, after: arrangedSubview)
        return self
    }
    
    @discardableResult
    func layoutMarginsDidChange() -> Self {
        self.layoutMarginsDidChange()
        return self
    }
}
