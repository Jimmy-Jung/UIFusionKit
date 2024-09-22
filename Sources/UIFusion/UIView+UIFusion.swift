//
//  UIView+Stylable.swift
//  Tablet
//
//  Created by 정준영 on 11/30/23.
//

import UIKit
import SwiftUI
import Combine

private var cancellablesKey: UInt8 = 0

public extension UIView {
    
    var cancellables: Set<AnyCancellable> {
        get {
            if let cancellables = objc_getAssociatedObject(self, &cancellablesKey) {
                return cancellables as! Set<AnyCancellable>
            } else {
                let newCancellables = Set<AnyCancellable>()
                objc_setAssociatedObject(
                    self,
                    &cancellablesKey,
                    newCancellables,
                    .OBJC_ASSOCIATION_RETAIN_NONATOMIC
                )
                return newCancellables
            }
        }
        set {
            objc_setAssociatedObject(
                self,
                &cancellablesKey,
                newValue,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
}

public protocol UIFusion {}

extension UIView: UIFusion {
    @frozen public enum Alignment {
        case center
        case leading
        case trailing
        case top
        case bottom
        case fill
        case edges
        case firstBaseline
        case lastBaseline
    }
}

public extension UIFusion where Self: UIView {
    
    @discardableResult
    func body(topSafeArea: Bool = false, _ view: UIView) -> Self {
        self.subviews.forEach { $0.removeFromSuperview() }
        self.addSubview(view)
        view.snp.makeConstraints { make in
            if topSafeArea {
                make.top.equalTo(safeAreaLayoutGuide)
            } else {
                make.top.equalToSuperview()
            }
            make.horizontalEdges.bottom.equalToSuperview()
        }
        return self
    }
    
    @discardableResult
    func body(
        alignment: Alignment = .center,
        distribution: UIStackView.Distribution = .fill,
        @UIViewBuilder _ content: () -> [UIView] = { [] }
    ) -> Self {
        self.subviews.forEach { $0.removeFromSuperview() }
        addVStackView(
            alignment: alignment,
            distribution: distribution,
            content
        )
        return self
    }
    
    @available(iOS 13.0, *)
    @discardableResult
    func body(
        alignment: Alignment = .center,
        distribution: UIStackView.Distribution = .fill,
        @ViewBuilder _ content: () -> some View
    ) -> Self {
        self.subviews.forEach { $0.removeFromSuperview() }
        if let hostView = UIHostingController(rootView: content()).view {
            addVStackView(alignment: alignment, distribution: distribution) {
                hostView
            }
        }
        return self
    }
    
    fileprivate func addVStackView(
        alignment: Alignment = .center,
        distribution: UIStackView.Distribution = .fill,
        @UIViewBuilder _ content: () -> [UIView]
    ) {
        let vStackView = VStackView(distribution: distribution, content)
        self.addSubview(vStackView)
        vStackView.snp.makeConstraints { make in
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
    
    @discardableResult
    func frame(width: CGFloat? = nil, height: CGFloat? = nil) -> Self {
        self.snp.makeConstraints { make in
            if let width {
                make.width.equalTo(width)
            }
            if let height {
                make.height.equalTo(height)
            }
        }
        return self
    }
    
    @discardableResult
    func frame(_ publisher: Published<(width: CGFloat?, height: CGFloat?)>.Publisher) -> Self {
        publisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] frame in
                guard let self = self else { return }
                self.snp.remakeConstraints { make in
                    if let width = frame.width {
                        make.width.equalTo(width)
                    }
                    if let height = frame.height {
                        make.height.equalTo(height)
                    }
                }
            }
            .store(in: &cancellables)
        print("UIView cancellables: \(cancellables)")
        return self
    }
    
    
    @discardableResult
    func padding(_ insets: UIEdgeInsets) -> Self {
        self.subviews.first?.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(insets)
        }
        return self
    }
    
    @discardableResult
    func padding(_ edges: Edges) -> Self {
        self.subviews.first?.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(edges.insets)
        }
        return self
    }
    
    @discardableResult
    func padding(_ length: CGFloat) -> Self {
        self.subviews.first?.snp.remakeConstraints { make in
            make.edges.equalToSuperview().inset(length)
        }
        return self
    }
    
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        return self
    }
    
    @discardableResult
    func isUserInteractionEnabled(_ bool: Bool) -> Self {
        self.isUserInteractionEnabled = bool
        return self
    }
    
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        self.backgroundColor = color
        return self
    }
    
    @discardableResult
    func clipsToBounds(_ bool: Bool) -> Self {
        self.clipsToBounds = bool
        return self
    }
    
    @discardableResult
    func contentMode(_ contentMode: UIView.ContentMode) -> Self {
        self.contentMode = contentMode
        return self
    }
    
    @discardableResult
    func isHidden(_ bool: Bool) -> Self {
        self.isHidden = bool
        return self
    }
    
    @discardableResult
    func addSubView(_ view: UIView) -> Self {
        self.addSubview(view)
        return self
    }
    
    @discardableResult
    func setBorder(color: UIColor, width: CGFloat) -> Self {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
        return self
    }
    
    @discardableResult
    func setBorderRadius(_ radius: CGFloat) -> Self {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        return self
    }
    
    @discardableResult
    func alpha(_ alpha: CGFloat) -> Self {
        self.alpha = alpha
        return self
    }
    
    @discardableResult
    func tag(_ value: Int) -> Self {
        self.tag = value
        return self
    }
}

