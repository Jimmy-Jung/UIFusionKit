//
//  ActionButton.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

struct ActionButton: View {
    let title: String
    let iconName: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: .DS.sm) {
                // Icon
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .DS.primaryText))
                        .scaleEffect(0.8)
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: iconName)
                        .font(.DS.bodyMedium)
                        .foregroundColor(.DS.primaryText)
                        .frame(width: 16, height: 16)
                }
                
                // Title
                Text(title)
                    .bodyMedium()
                
                Spacer()
            }
            .padding(.horizontal, .DS.md)
            .padding(.vertical, .DS.buttonPadding)
            .background(
                RoundedRectangle(cornerRadius: .DS.buttonRadius)
                    .fill(Color.DS.buttonBackground)
            )
        }
        .disabled(isLoading)
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: .DS.md) {
        ActionButton(
            title: "Increase",
            iconName: "plus",
            isLoading: false
        ) {
            print("Increase tapped")
        }
        
        ActionButton(
            title: "Loading...",
            iconName: "minus",
            isLoading: true
        ) {
            print("Loading tapped")
        }
    }
    .padding()
} 