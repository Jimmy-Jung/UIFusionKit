//
//  UIImageVIew+Stylable.swift
//  
//
//  Created by 정준영 on 2023/08/30.
//
import UIKit

public extension UIFusion where Self: UIImageView {
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        self.image = image
        return self
    }
    
    @discardableResult
    func highlightedImage(_ image: UIImage?) -> Self {
        self.highlightedImage = image
        return self
    }
    
    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }
    
    @discardableResult
    func animationImages(_ images: [UIImage]?) -> Self {
        self.animationImages = images
        return self
    }
    
    @discardableResult
    func highlightedAnimationImages(_ images: [UIImage]?) -> Self {
        self.highlightedAnimationImages = images
        return self
    }
    
    @discardableResult
    func animationDuration(_ duration: TimeInterval) -> Self {
        self.animationDuration = duration
        return self
    }
    
    @discardableResult
    func animationRepeatCount(_ count: Int) -> Self {
        self.animationRepeatCount = count
        return self
    }
    
    @discardableResult
    func tintColor(_ color: UIColor) -> Self {
        self.tintColor = color
        return self
    }
  
}
