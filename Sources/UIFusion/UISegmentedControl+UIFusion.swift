//
//  UISegmentedControl+Styleable.swift
//
//
//  Created by 정준영 on 1/8/24.
//

import UIKit

public extension UIFusion where Self: UISegmentedControl {
    
    @discardableResult
    func setImage(_ image: UIImage?, forSegmentAt segment: Int) -> Self {
        self.setImage(image, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func selectedSegmentIndex(_ selectedSegmentIndex: Int) -> Self {
        self.selectedSegmentIndex = selectedSegmentIndex
        return self
    }
    
    @discardableResult
    func imageForSegment(at segment: Int) -> Self {
        self.imageForSegment(at: segment)
        return self
    }
    
    @discardableResult
    func setTitle(_ title: String?, forSegmentAt segment: Int) -> Self {
        self.setTitle(title, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func titleForSegment(at segment: Int) -> Self {
        self.titleForSegment(at: segment)
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func setAction(_ action: UIAction, forSegmentAt segment: Int) -> Self {
        self.setAction(action, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func insertSegment(withTitle title: String?, at segment: Int, animated: Bool) -> Self {
        self.insertSegment(withTitle: title, at: segment, animated: animated)
        return self
    }
    
    @discardableResult
    func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) -> Self {
        self.insertSegment(with: image, at: segment, animated: animated)
        return self
    }
    
    @discardableResult
    func removeSegment(at segment: Int, animated: Bool) -> Self {
        self.removeSegment(at: segment, animated: animated)
        return self
    }
    
    @discardableResult
    func removeAllSegments() -> Self {
        self.removeAllSegments()
        return self
    }
    
    @discardableResult
    func setEnabled(_ enabled: Bool, forSegmentAt segment: Int) -> Self {
        self.setEnabled(enabled, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func isEnabledForSegment(at segment: Int) -> Self {
        self.isEnabledForSegment(at: segment)
        return self
    }
    
    @discardableResult
    func isMomentary(_ momentary: Bool) -> Self {
        self.isMomentary = momentary
        return self
    }
    
    @discardableResult
    func setContentOffset(_ offset: CGSize, forSegmentAt segment: Int) -> Self {
        self.setContentOffset(offset, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func contentOffsetForSegment(at segment: Int) -> Self {
        self.contentOffsetForSegment(at: segment)
        return self
    }
    
    @discardableResult
    func setWidth(_ width: CGFloat, forSegmentAt segment: Int) -> Self {
        self.setWidth(width, forSegmentAt: segment)
        return self
    }
    
    @discardableResult
    func widthForSegment(at segment: Int) -> Self {
        self.widthForSegment(at: segment)
        return self
    }
    
    @discardableResult
    func apportionsSegmentWidthsByContent(_ apportionsSegmentWidthsByContent: Bool) -> Self {
        self.apportionsSegmentWidthsByContent = apportionsSegmentWidthsByContent
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func selectedSegmentTintColor(_ selectedSegmentTintColor: UIColor?) -> Self {
        self.selectedSegmentTintColor = selectedSegmentTintColor
        return self
    }
    
    @discardableResult
    func backgroundImage(_ backgroundImage: UIImage?, for state: UIControl.State, barMetrics: UIBarMetrics) -> Self {
        self.setBackgroundImage(backgroundImage, for: state, barMetrics: barMetrics)
        return self
    }
    
    @discardableResult
    func contentPositionAdjustment(_ adjustment: UIOffset, forSegmentType leftCenterRightOrAlone: UISegmentedControl.Segment, barMetrics: UIBarMetrics) -> Self {
        self.setContentPositionAdjustment(adjustment, forSegmentType: leftCenterRightOrAlone, barMetrics: barMetrics)
        return self
    }
    
    @discardableResult
    func dividerImage(_ dividerImage: UIImage?, forLeftSegmentState leftState: UIControl.State, rightSegmentState rightState: UIControl.State, barMetrics: UIBarMetrics) -> Self {
        self.setDividerImage(dividerImage, forLeftSegmentState: leftState, rightSegmentState: rightState, barMetrics: barMetrics)
        return self
    }
    
    @discardableResult
    func titleTextAttributes(_ attributes: [NSAttributedString.Key : Any]?, for state: UIControl.State) -> Self {
        self.setTitleTextAttributes(attributes, for: state)
        return self
    }
    
}

