//
//  ExampleViewController.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine
import CombineCocoa

final class ExampleViewController: UIViewController {
    
    private var viewModel: any ExampleViewModel
    private var cancellables = Set<AnyCancellable>()
    init(_ viewModel: any ExampleViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    private let textLabel = UILabel()
    private let textButton = UIButton(configuration: .filled())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.send(.viewDidLoad)
        
        setupUI()
        bindInput()
        bindState()
    }
    
    private func setupUI() {
        view.body {
            VStackView(alignment: .center, distribution: .fill) {
                textLabel
                    .font(.systemFont(ofSize: 20, weight: .semibold))
                SpaceView(vertical: 20)
                textButton
            }
        }
        .backgroundColor(.white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    private func bindInput() {
        textButton
            .tapPublisher
            .sink(with: self) { owner, output in
                owner.viewModel.send(.buttonTap)
            }
            .store(in: &cancellables)
    }
    
    private func bindState() {
        
        viewModel
            .state
            .$buttonText
            .bind(on: textButton, to: \.title)
            .store(in: &cancellables)
        
        viewModel
            .state
            .$buttonColor
            .sink(with: self) { owner, backgroundColor in
                owner.textButton.baseBackgroundColor(backgroundColor)
            }
            .store(in: &cancellables)
        
        viewModel
            .state
            .$buttonFrame
            .sink(with: self) { owner, frame in
                owner.textButton.snp.remakeConstraints { make in
                    make.height.equalTo(frame.height ?? 0)
                    make.width.equalTo(frame.width ?? 0)
                }
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut) {
                    self.view.layoutIfNeeded()
                }
            }
            .store(in: &cancellables)
        
        viewModel
            .state
            .$labelText
            .assign(to: \.text, on: textLabel)
            .store(in: &cancellables)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 17.0, *)
#Preview {
    ExampleViewController(DefaultExampleViewModel())
}
