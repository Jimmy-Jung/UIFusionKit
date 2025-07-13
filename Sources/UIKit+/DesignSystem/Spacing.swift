//
//  Spacing.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

extension CGFloat {
    struct DS {
        // MARK: - Spacing Scale
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
        
        // MARK: - Component Specific
        static let buttonPadding: CGFloat = 16
        static let buttonRadius: CGFloat = 12
        static let cardPadding: CGFloat = 20
        static let sectionSpacing: CGFloat = 32
    }
}

extension EdgeInsets {
    struct DS {
        static let buttonPadding = EdgeInsets(
            top: .DS.sm,
            leading: .DS.md,
            bottom: .DS.sm,
            trailing: .DS.md
        )
        
        static let cardPadding = EdgeInsets(
            top: .DS.cardPadding,
            leading: .DS.cardPadding,
            bottom: .DS.cardPadding,
            trailing: .DS.cardPadding
        )
    }
} 