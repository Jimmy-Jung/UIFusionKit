//
//  UIScrollView+.swift
//
//
//  Created by 정준영 on 2024/6/22.
//

import UIKit

extension UIScrollView {
    public enum ScrollDirection {
        case top
        case center
        case bottom
    }
}

public extension UIFusion where Self: UIScrollView {
    func scroll(to direction: ScrollDirection) {
        DispatchQueue.main.async {
            switch direction {
                case .top:
                    self.scrollToTop()
                case .center:
                    self.scrollToCenter()
                case .bottom:
                    self.scrollToBottom()
            }
        }
    }
    
    private func scrollToTop() {
        setContentOffset(.zero, animated: true)
    }
    
    private func scrollToCenter() {
        let centerOffset = CGPoint(x: 0, y: (contentSize.height - bounds.size.height) / 2)
        setContentOffset(centerOffset, animated: true)
    }
    
    private func scrollToBottom() {
        let bottomOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height + contentInset.bottom)
        if(bottomOffset.y > 0) {
            setContentOffset(bottomOffset, animated: true)
        }
    }
}
