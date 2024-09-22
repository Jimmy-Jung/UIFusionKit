//
//  CounterViewController.swift
//
//
//  Created by 정준영 on 2024/7/24.
//

import UIKit
import Combine

final class CounterViewController: UIViewController {
    private var viewModel: any CounterViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(_ viewModel: any CounterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    private let valueLabel = UILabel()
    private let increaseButton = UIButton(configuration: .gray())
    private let decreaseButton = UIButton(configuration: .gray())
    private let resetButton = UIButton(configuration: .plain())
    private let showButton = UIButton(configuration: .plain())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
        bindInput()
    }
    
    private func setupUI() {
        view.body {
            VStackView(spacing: 20) {
                valueLabel
                    .font(.systemFont(ofSize: 20, weight: .semibold))
                    .text("Value")
                
                increaseButton
                    .image(.add)
                    .imagePadding(8)
                    .title("Increase")
                
                decreaseButton
                    .image(.remove)
                    .imagePadding(8)
                    .title("Decrease")
                
                resetButton
                    .image(.init(systemName: "arrow.counterclockwise.circle"))
                    .tintColor(.systemOrange)
                    .imagePadding(8)
                    .title("Reset")
                
                showButton
                    .image(.init(systemName: "exclamationmark.circle.fill"))
                    .tintColor(.systemYellow)
                    .imagePadding(8)
                    .title("Show")
            }
            
        }
    }
    
    private func bindState() {
        viewModel
            .state
            .$value
            .dropFirst()
            .map { "\($0)"}
            .assign(to: \.text, on: valueLabel)
            .store(in: &cancellables)
        
        viewModel
            .state
            .$showAlert
            .sink(with: self) { owner, _ in
                let alert = UIAlertController(title: "알림", message: "\(owner.viewModel.state.value)", preferredStyle: .alert)
                alert.addAction(.init(title: "닫기", style: .cancel))
                owner.present(alert, animated: true)
            }
            .store(in: &cancellables)
    }
    
    private func bindInput() {
        increaseButton
            .publisher(for: \.tapPublisher)
            .sink(with: self) { owner, output in
                owner.viewModel.send(.increase)
            }
            .store(in: &cancellables)
        
        increaseButton
            .addAction(self) { owner in
                owner.viewModel.send(.increase)
            }
        decreaseButton
            .addAction(self) { owner in
                owner.viewModel.send(.decrease)
            }
        resetButton
            .addAction(self) { owner in
                owner.viewModel.send(.reset)
            }
        showButton
            .addAction(self) { owner in
                owner.viewModel.send(.show)
            }
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@available(iOS 17.0, *)
#Preview {
    CounterViewController(DefaultCounterViewModel())
}
