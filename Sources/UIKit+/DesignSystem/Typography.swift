//
//  Typography.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

extension Font {
    struct DS {
        // MARK: - Display
        static let displayLarge = Font.system(size: 64, weight: .bold, design: .default)
        static let displayMedium = Font.system(size: 48, weight: .bold, design: .default)
        static let displaySmall = Font.system(size: 36, weight: .bold, design: .default)
        
        // MARK: - Headline
        static let headlineLarge = Font.system(size: 24, weight: .semibold, design: .default)
        static let headlineMedium = Font.system(size: 20, weight: .semibold, design: .default)
        static let headlineSmall = Font.system(size: 18, weight: .semibold, design: .default)
        
        // MARK: - Body
        static let bodyLarge = Font.system(size: 16, weight: .medium, design: .default)
        static let bodyMedium = Font.system(size: 14, weight: .medium, design: .default)
        static let bodySmall = Font.system(size: 12, weight: .medium, design: .default)
        
        // MARK: - Label
        static let labelLarge = Font.system(size: 14, weight: .medium, design: .default)
        static let labelMedium = Font.system(size: 12, weight: .medium, design: .default)
        static let labelSmall = Font.system(size: 10, weight: .medium, design: .default)
    }
}

extension Text {
    // MARK: - Display Styles
    func displayLarge() -> some View {
        self.font(.DS.displayLarge)
            .foregroundColor(.DS.primaryText)
    }
    
    func displayMedium() -> some View {
        self.font(.DS.displayMedium)
            .foregroundColor(.DS.primaryText)
    }
    
    // MARK: - Body Styles
    func bodyMedium() -> some View {
        self.font(.DS.bodyMedium)
            .foregroundColor(.DS.primaryText)
    }
    
    func bodySecondary() -> some View {
        self.font(.DS.bodyMedium)
            .foregroundColor(.DS.secondaryText)
    }
    
    func caption() -> some View {
        self.font(.DS.labelMedium)
            .foregroundColor(.DS.tertiaryText)
    }
} 