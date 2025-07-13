//
//  Colors.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

extension Color {
    struct DS {
        // MARK: - Background Colors
        static let background = Color.white
        static let surface = Color.gray.opacity(0.1)
        
        // MARK: - Button Colors
        static let buttonBackground = Color.gray.opacity(0.15)
        static let buttonBackgroundPressed = Color.gray.opacity(0.25)
        
        // MARK: - Text Colors
        static let primaryText = Color.black
        static let secondaryText = Color.gray
        static let tertiaryText = Color.gray.opacity(0.7)
        
        // MARK: - Action Colors
        static let destructive = Color.red.opacity(0.2)
        static let warning = Color.orange.opacity(0.2)
        static let accent = Color.blue.opacity(0.2)
    }
} 