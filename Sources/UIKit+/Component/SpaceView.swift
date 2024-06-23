//
//  SpaceView.swift
//  Tablet
//
//  Created by 정준영 on 4/19/24.
//

import UIKit

public class SpaceView: UIView {
    
    public init(
        vertical: CGFloat? = nil,
        horizontal: CGFloat? = nil
    ) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            if let vertical {
                make.height.equalTo(vertical)
            }
            if let horizontal {
                make.width.equalTo(horizontal)
            }
        }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
