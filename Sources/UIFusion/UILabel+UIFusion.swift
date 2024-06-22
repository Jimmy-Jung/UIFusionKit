//
//  UILabel+Stylable.swift
//  JimmyKiy
//
//  Created by 정준영 on 2023/08/28.
//

import UIKit
import Combine

public extension UIFusion where Self: UILabel {

    @discardableResult
    func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func text(
        _ publisher: Published<String>.Publisher
    ) -> Self {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newText in
                self?.text = newText
            }
            .store(in: &cancellables)
        print("UILabel cancellables: \(cancellables)")
        return self
    }
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult
    func highlightedTextColor(_ color: UIColor) -> Self {
        self.highlightedTextColor = color
        return self
    }
    
    @discardableResult
    func shadowColor(_ color: UIColor?) -> Self {
        self.shadowColor = color
        return self
    }
    
    @discardableResult
    func shadowOffset(_ offset: CGSize) -> Self {
        self.shadowOffset = offset
        return self
    }
    
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    @discardableResult
    func lineBreakMode(_ mode: NSLineBreakMode) -> Self {
        self.lineBreakMode = mode
        return self
    }

    @discardableResult
    func attributedText(_ attributedText: NSAttributedString?) -> Self {
        self.attributedText = attributedText
        return self
    }

    @discardableResult
    func isHighlighted(_ isHighlighted: Bool) -> Self {
        self.isHighlighted = isHighlighted
        return self
    }

    @discardableResult
    func isEnabled(_ isEnabled: Bool) -> Self {
        self.isEnabled = isEnabled
        return self
    }

    @discardableResult
    func numberOfLines(_ numberOfLines: Int) -> Self {
        self.numberOfLines = numberOfLines
        return self
    }
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ value: Bool, _ minimumScaleFactor: CGFloat) -> Self {
        self.adjustsFontSizeToFitWidth = value
        self.minimumScaleFactor = minimumScaleFactor
        return self
    }

    @discardableResult
    func adjustsFontSizeToFitWidth(_ bool: Bool) -> Self {
        self.adjustsFontSizeToFitWidth = bool
        return self
    }

    @discardableResult
    func minimumScaleFactor(_ minimumScaleFactor: CGFloat) -> Self {
        self.minimumScaleFactor = minimumScaleFactor
        return self
    }

    @discardableResult
    func allowsDefaultTighteningForTruncation(_ bool: Bool) -> Self {
        self.allowsDefaultTighteningForTruncation = bool
        return self
    }

    @discardableResult
    func preferredMaxLayoutWidth(_ preferredMaxLayoutWidth: CGFloat) -> Self {
        self.preferredMaxLayoutWidth = preferredMaxLayoutWidth
        return self
    }

    @discardableResult
    func baselineAdjustment(_ baselineAdjustment: UIBaselineAdjustment) -> Self {
        self.baselineAdjustment = baselineAdjustment
        return self
    }

    @discardableResult
    func adjustsFontForContentSizeCategory(_ bool: Bool) -> Self {
        self.adjustsFontForContentSizeCategory = bool
        return self
    }
    
    @discardableResult
    func asColor(targetString: String, color: UIColor) -> Self {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        attributedText = attributedString
        return self
    }
    
    @discardableResult
    func asColor(targetString: String, color: UIColor, font: UIFont) -> Self {
        let fullText = text ?? ""
        let attributedString = NSMutableAttributedString(string: fullText)
        let range = (fullText as NSString).range(of: targetString)
        attributedString.addAttribute(.foregroundColor, value: color, range: range)
        attributedString.addAttribute(.font, value: font, range: range)
        attributedText = attributedString
        return self
    }
}
