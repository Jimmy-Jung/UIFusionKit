//
//  UIView+Stylable.swift
//  Tablet
//
//  Created by 정준영 on 11/30/23.
//

import UIKit
import Combine

public extension UIFusion where Self: UIButton {
    
    @discardableResult
    func isSelected(_ value: Bool) -> Self {
        self.isSelected = value
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func baseBackgroundColor(_ color: UIColor?) -> Self {
        self.configuration?.baseBackgroundColor = color
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func baseForegroundColor(_ color: UIColor) -> Self {
        self.configuration?.baseForegroundColor = color
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func title(_ text: String) -> Self {
        self.configuration?.title = text
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleLineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.configuration?.titleLineBreakMode = mode
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleWithFont(title: String, size: CGFloat, weight: UIFont.Weight) -> Self {
        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: size, weight: weight)
        self.configuration?.attributedTitle = titleAttr
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleWithFont(title: String, font: UIFont) -> Self {
        var titleAttr = AttributedString(title)
        titleAttr.font = font
        self.configuration?.attributedTitle = titleAttr
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.configuration?.attributedTitle?.font = font
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleAlignment(_ alignment: UIButton.Configuration.TitleAlignment) -> Self {
        self.configuration?.titleAlignment = alignment
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleLabelAlignment(_ alignment: NSTextAlignment) -> Self {
        self.titleLabel?.textAlignment = alignment
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titleLabelAdjustsFontSizeToFitWidth(_ value: Bool, _ minimumScaleFactor: CGFloat) -> Self {
        self.titleLabel?.adjustsFontSizeToFitWidth = value
        self.titleLabel?.minimumScaleFactor = minimumScaleFactor
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func titlePadding(_ padding: CGFloat) -> Self {
        self.configuration?.titlePadding = padding
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func subtitle(_ text: String) -> Self {
        self.configuration?.subtitle = text
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func subtitleWithFont(title: String, size: CGFloat, weight: UIFont.Weight) -> Self {
        var titleAttr = AttributedString(title)
        titleAttr.font = .systemFont(ofSize: size, weight: weight)
        self.configuration?.attributedSubtitle = titleAttr
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func image(_ image: UIImage?) -> Self {
        self.configuration?.image = image
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func setImage(_ image: UIImage?, for state: UIControl.State) -> Self {
        self.setImage(image, for: state)
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func cornerStyle(_ cornerStyle: UIButton.Configuration.CornerStyle) -> Self {
        self.configuration?.cornerStyle = cornerStyle
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func borderColor(_ color: UIColor) -> Self {
        self.configuration?.background.strokeColor = color
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func borderWidth(_ width: CGFloat) -> Self {
        self.configuration?.background.strokeWidth = width
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        self.configuration?.background.cornerRadius = radius
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func imagePadding(_ padding: CGFloat) -> Self {
        self.configuration?.imagePadding = padding
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func imagePlacement(_ placement: NSDirectionalRectEdge) -> Self {
        self.configuration?.imagePlacement = placement
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func contentInsets(_ insets: NSDirectionalEdgeInsets) -> Self {
        self.configuration?.contentInsets = insets
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func buttonSize(_ size: UIButton.Configuration.Size) -> Self {
        self.configuration?.buttonSize = size
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func showsActivityIndicator(_ bool: Bool) -> Self {
        self.configuration?.showsActivityIndicator = bool
        return self
    }
    
    @available(iOS 15.0, *)
    @discardableResult
    func addConfigurationUpdateHandler(_ action: @escaping UIButton.ConfigurationUpdateHandler) -> Self {
        self.configurationUpdateHandler = action
        return self
    }
    
    @discardableResult
    func contentHorizontalAlignment(_ alignment: UIControl.ContentHorizontalAlignment) -> Self {
        self.contentHorizontalAlignment = alignment
        return self
    }
    
    @discardableResult
    func contentVerticalAlignment(_ alignment: UIControl.ContentVerticalAlignment) -> Self {
        self.contentVerticalAlignment = alignment
        return self
    }
}
