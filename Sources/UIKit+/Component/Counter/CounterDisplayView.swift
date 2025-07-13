//
//  CounterDisplayView.swift
//  UIFusionKit
//
//  Created by Assistant on 2024
//

import SwiftUI

struct CounterDisplayView: View {
    let value: Int
    let description: String
    
    var body: some View {
        VStack(spacing: .DS.sm) {
            Text("\(value)")
                .displayLarge()
                .multilineTextAlignment(.center)
            
            Text(description)
                .caption()
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, .DS.xl)
    }
}

#Preview {
    CounterDisplayView(
        value: 0,
        description: "허용 범위: -10 ~ 10"
    )
    .padding()
} 