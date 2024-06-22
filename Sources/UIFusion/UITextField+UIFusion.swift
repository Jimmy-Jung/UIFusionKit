//
//  UITextField+Stylable.swift
//  JimmyKiy
//
//  Created by 정준영 on 2023/08/28.
//

import UIKit.UITextField

public extension UIFusion where Self: UITextField {
    @discardableResult
    func text(_ text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    func textColor(_ color: UIColor) -> Self {
        self.textColor = color
        return self
    }
    
    @discardableResult
    func font(_ font: UIFont) -> Self {
        self.font = font
        return self
    }
    
    @discardableResult
    func textAlignment(_ alignment: NSTextAlignment) -> Self {
        self.textAlignment = alignment
        return self
    }
    
    @discardableResult
    func placeholder(_ text: String?) -> Self {
        self.placeholder = text
        return self
    }
    
    @discardableResult
    func background(_ image: UIImage?) -> Self {
        self.background = image
        return self
    }
    
    @discardableResult
    func disabledBackground(_ image: UIImage?) -> Self {
        self.disabledBackground = image
        return self
    }
    
    @discardableResult
    func clearButtonMode(_ mode: UITextField.ViewMode) -> Self {
        self.clearButtonMode = mode
        return self
    }
    
    @discardableResult
    func minimumFontSize(_ size: CGFloat) -> Self {
        self.minimumFontSize = size
        return self
    }
    
    @discardableResult
    func autocapitalizationType(_ type: UITextAutocapitalizationType) -> Self {
        self.autocapitalizationType = type
        return self
    }
    
    @discardableResult
    func autocorrectionType(_ type: UITextAutocorrectionType) -> Self {
        self.autocorrectionType = type
        return self
    }
    
    @discardableResult
    func spellCheckingType(_ type: UITextSpellCheckingType) -> Self {
        self.spellCheckingType = type
        return self
    }
    
    @discardableResult
    func keyboardType(_ type: UIKeyboardType) -> Self {
        self.keyboardType = type
        return self
    }
    
    @discardableResult
    func keyboardAppearance(_ appearance: UIKeyboardAppearance) -> Self {
        self.keyboardAppearance = appearance
        return self
    }
    
    @discardableResult
    func returnKeyType(_ type: UIReturnKeyType) -> Self {
        self.returnKeyType = type
        return self
    }
    
    @discardableResult
    func isSecureTextEntry(_ bool: Bool) -> Self {
        self.isSecureTextEntry = bool
        return self
    }
    
    @discardableResult
    func contentType(_ type: UITextContentType?) -> Self {
        self.textContentType = type
        return self
    }
    
    @discardableResult
    func delegate(_ delegator: UITextFieldDelegate) -> Self {
        self.delegate = delegator
        return self
    }
    
    @discardableResult
    func attributedPlaceholder(
        _ text: String,
        color: UIColor,
        font: UIFont
    ) -> Self {
        let attributedString = NSAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.foregroundColor: color,
                NSAttributedString.Key.font: font
            ]
        )
        self.attributedPlaceholder = attributedString
        return self
    }
    
    @discardableResult
    func leftView(_ view: UIView?) -> Self {
        self.leftView = view
        return self
    }
    
    @discardableResult
    func leftViewMode(_ mode: UITextField.ViewMode) -> Self {
        self.leftViewMode = mode
        return self
    }
    
    @discardableResult
    func rightView(_ view: UIView?) -> Self {
        self.rightView = view
        return self
    }
    
    @discardableResult
    func rightViewMode(_ mode: UITextField.ViewMode) -> Self {
        self.rightViewMode = mode
        return self
    }
    
    @discardableResult
    func inputView(_ view: UIView?) -> Self {
        self.inputView = view
        return self
    }
    
    @discardableResult
    func inputAccessoryView(_ view: UIView?) -> Self {
        self.inputAccessoryView = view
        return self
    }
    
    @discardableResult
    func clearsOnBeginEditing(_ clears: Bool) -> Self {
        self.clearsOnBeginEditing = clears
        return self
    }
    
    @discardableResult
    func clearsOnInsertion(_ clears: Bool) -> Self {
        self.clearsOnInsertion = clears
        return self
    }
    
    @discardableResult
    func allowsEditingTextAttributes(_ allows: Bool) -> Self {
        self.allowsEditingTextAttributes = allows
        return self
    }
}
