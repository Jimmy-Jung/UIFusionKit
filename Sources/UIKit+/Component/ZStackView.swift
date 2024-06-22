//
//  ZStackView.swift
//  Tablet
//
//  Created by 정준영 on 4/23/24.
//

import UIKit

public class ZStackView: UIView {
    public init(
        alignment: Alignment = .center,
        @UIViewBuilder _ content: () -> [UIView]
    ) {
        super.init(frame: .zero)
        content().forEach {
            self.addSubview($0)
            $0.snp.makeConstraints { make in
                switch alignment {
                    case .center:
                        make.center.equalToSuperview()
                    case .fill:
                        make.horizontalEdges.equalToSuperview()
                        make.centerY.equalToSuperview()
                    case .edges:
                        make.edges.equalToSuperview()
                    case .leading:
                        make.leading.equalToSuperview()
                        make.centerY.equalToSuperview()
                    case .trailing:
                        make.trailing.equalToSuperview()
                        make.centerY.equalToSuperview()
                    case .top:
                        make.top.equalToSuperview()
                        make.centerX.equalToSuperview()
                    case .bottom:
                        make.bottom.equalToSuperview()
                        make.centerX.equalToSuperview()
                    case .firstBaseline:
                        make.firstBaseline.equalToSuperview()
                        make.centerX.equalToSuperview()
                    case .lastBaseline:
                        make.lastBaseline.equalToSuperview()
                        make.centerX.equalToSuperview()
                }
            }
        }
    }
    
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
