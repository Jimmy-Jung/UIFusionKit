//
//  HStackView.swift
//  Tablet
//
//  Created by 정준영 on 4/23/24.
//

import UIKit

public class HStackView: UIStackView {
    
    init(
        spacing: CGFloat = 0,
        alignment: UIStackView.Alignment = .center,
        distribution: UIStackView.Distribution = .fill,
        @UIViewBuilder _ content: () -> [UIView]
    ) {
        super.init(frame: .zero)
        self.axis(.horizontal)
            .alignment(alignment)
            .distribution(distribution)
            .spacing(spacing)
        content().forEach { self.addArrangedSubview($0) }
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
