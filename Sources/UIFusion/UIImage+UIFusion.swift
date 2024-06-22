//
//  UIImage.swift
//  
//
//  Created by 정준영 on 2023/09/02.
//

import UIKit

extension UIImage: UIFusion {
    /// SFImage rendering options.
    public enum Rendering {
        case monochrome
        case hierarchicalColor(_ color: UIColor)
        case paletteColors(_ colors: [UIColor])
        case multicolor
    }
}

@available(iOS 13.0, *)
public extension UIFusion where Self: UIImage {
    
    typealias SFConfig = UIImage.SymbolConfiguration
    
    /// Resize image with specified point size.
    /// - Parameter size: The point size to resize the image to.
    /// - Returns: The `UIImage` instance for function chaining.
    @discardableResult
    func pointSize(_ size: CGFloat) -> UIImage {
        if let image = self.applyingSymbolConfiguration(SFConfig(pointSize: size)) {
            return image
        } else {
            fatalError("Cannot resize image with specified point size.")
        }
    }
    
    /// Resize image with specified font.
    /// - Parameter font: The font to resize the image to.
    /// - Returns: The `UIImage` instance for function chaining.
    @discardableResult
    func font(_ font: UIFont) -> UIImage {
        if let image = self.applyingSymbolConfiguration(SFConfig(font: font)) {
            return image
        } else {
            fatalError("Cannot resize image with specified font.")
        }
    }
    
    /// Resize image with specified text style.
    /// - Parameter style: The text style to resize the image to.
    /// - Returns: The `UIImage` instance for function chaining.
    @discardableResult
    func textStyle(_ style: UIFont.TextStyle) -> UIImage {
        if let image = self.applyingSymbolConfiguration(SFConfig(textStyle: style)) {
            return image
        } else {
            fatalError("Cannot resize image with specified text style.")
        }
    }
    
    /// Resize image with specified symbol weight.
    /// - Parameter weight: The symbol weight to resize the image to.
    /// - Returns: The `UIImage` instance for function chaining.
    @discardableResult
    func weight(_ weight: UIImage.SymbolWeight) -> UIImage {
        if let image = self.applyingSymbolConfiguration(SFConfig(weight: weight)) {
            return image
        } else {
            fatalError("Cannot resize image with specified symbol weight.")
        }
    }
    
    /// Resize image with specified symbol scale.
    /// - Parameter scale: The symbol scale to resize the image to.
    /// - Returns: The `UIImage` instance for function chaining.
    @discardableResult
    func scale(_ scale: UIImage.SymbolScale) -> UIImage {
        if let image = self.applyingSymbolConfiguration(SFConfig(scale: scale)) {
            return image
        } else {
            fatalError("Cannot resize image with specified symbol scale.")
        }
        
    }
    
    /// Set image rendering mode.
    /// - Parameter config: The image rendering option to apply.
    /// - Returns: The `UIImage` instance for function chaining.
    @available(iOS 15.0, *)
    @discardableResult
    func renderingColor(_ config: Rendering) -> UIImage {
        switch config {
        case .monochrome:
            if #available(iOS 16.0, *) {
                if let image = self.applyingSymbolConfiguration(SFConfig.preferringMonochrome()) {
                    return image
                } else {
                    fatalError("Cannot set image rendering mode to monochrome.")
                }
            } else {
                fatalError("iOS version is lower than 16.")
            }
        case .hierarchicalColor(let color):
            if let image = self.applyingSymbolConfiguration(SFConfig(hierarchicalColor: color)) {
                return image
            } else {
                fatalError("Cannot set image rendering mode to hierarchical color.")
            }
        case .paletteColors(let colors):
            if let image = self.applyingSymbolConfiguration(SFConfig(paletteColors: colors)) {
                return image
            } else {
                fatalError("Cannot set image rendering mode to palette colors.")
            }
        case .multicolor:
            if let image = self.applyingSymbolConfiguration(SFConfig.preferringMulticolor()) {
                return image
            } else {
                fatalError("Cannot set image rendering mode to multicolor.")
            }
        }
    }
}
