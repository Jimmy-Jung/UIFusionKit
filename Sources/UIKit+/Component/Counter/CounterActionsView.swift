//
//  CounterActionsView.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

struct CounterActionsView: View {
    let isIncreaseLoading: Bool
    let isDecreaseLoading: Bool
    let onIncrease: () -> Void
    let onDecrease: () -> Void
    let onReset: () -> Void
    let onShow: () -> Void
    
    var body: some View {
        VStack(spacing: .DS.md) {
            ActionButton(
                title: "Increase",
                iconName: "plus",
                isLoading: isIncreaseLoading,
                action: onIncrease
            )
            
            ActionButton(
                title: "Decrease",
                iconName: "minus",
                isLoading: isDecreaseLoading,
                action: onDecrease
            )
            
            ActionButton(
                title: "Reset",
                iconName: "arrow.counterclockwise.circle",
                isLoading: false,
                action: onReset
            )
            
            ActionButton(
                title: "Show",
                iconName: "exclamationmark.circle.fill",
                isLoading: false,
                action: onShow
            )
        }
    }
}

#Preview {
    CounterActionsView(
        isIncreaseLoading: false,
        isDecreaseLoading: false,
        onIncrease: { print("Increase") },
        onDecrease: { print("Decrease") },
        onReset: { print("Reset") },
        onShow: { print("Show") }
    )
    .padding()
} 