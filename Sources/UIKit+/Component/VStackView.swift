//
//  VStackView.swift
//  Tablet
//
//  Created by 정준영 on 4/23/24.
//

import UIKit

open class VStackView: UIStackView {
    
    convenience init(
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .center,
        distribution: UIStackView.Distribution = .fill,
        @UIViewBuilder _ content: () -> [UIView]
    ) {
        self.init()
        self.alignment(alignment)
            .distribution(distribution)
            .spacing(spacing)
        
        content().forEach { self.addArrangedSubview($0) }
    }
}
