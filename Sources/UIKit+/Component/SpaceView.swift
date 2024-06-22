//
//  SpaceView.swift
//  Tablet
//
//  Created by 정준영 on 4/19/24.
//

import UIKit

open class SpaceView: UIView {
    
    init() {
        super.init(frame: .zero)
    }
    
    init(vertical: CGFloat) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.height.equalTo(vertical)
        }
    }
    
    init(horizontal: CGFloat) {
        super.init(frame: .zero)
        self.snp.makeConstraints { make in
            make.width.equalTo(horizontal)
        }
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
