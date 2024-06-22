//
//  UIViewBuilder.swift
//  Tablet
//
//  Created by 정준영 on 4/23/24.
//

import SwiftUI

@resultBuilder
struct UIViewBuilder {
    public static func buildBlock(_ components: UIView...) -> [UIView] {
        components
    }
    
    @available(iOS 13.0, *)
    public static func buildBlock<Content>(_ content: Content) -> Content where Content : View {
        content
    }
}
