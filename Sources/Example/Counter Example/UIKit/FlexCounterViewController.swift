//
//  FlexCounterViewController.swift
//
//
//  Created by 정준영 on 2024/10/23.
//

import UIKit
import Combine
import FlexLayout
import PinLayout

final class FlexCounterViewController: UIViewController {
    private let viewModel: CounterAsyncViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // 컨테이너 뷰
    private let containerView = UIView()
    
    // UI 요소들
    private let valueLabel = UILabel()
    private let rangeLabel = UILabel()
    private let increaseButton = UIButton(configuration: .gray())
    private let decreaseButton = UIButton(configuration: .gray())
    private let resetButton = UIButton(configuration: .plain())
    private let showButton = UIButton(configuration: .plain())
    
    init(_ viewModel: CounterAsyncViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
        bindInput()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // FlexLayout의 컨테이너 레이아웃 설정
        containerView.pin.all(view.safeAreaInsets)
        containerView.flex.layout()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(containerView)
        
        valueLabel
            .font(.systemFont(ofSize: 20, weight: .semibold))
            .text("Value: 0")
        
        rangeLabel
            .text("허용 범위: -10 ~ 10")
            .font(.systemFont(ofSize: 12))
            .textColor(.systemGray)
        
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
        
        // FlexLayout을 사용한 레이아웃 구성
        containerView
            .flex
            .justifyContent(.center)
            .alignItems(.center)
            .define { flex in
                flex.addItem()
                    .direction(.column)
                    .alignItems(.center)
                    .gap(20)
                    .define { flex in
                        flex.addItem(valueLabel)
                        flex.addItem(rangeLabel)
                        flex.addItem(increaseButton)
                        flex.addItem(decreaseButton)
                        flex.addItem(resetButton)
                        flex.addItem(showButton)
                    }
            }
    }
    
    private func bindState() {
        viewModel.$value
            .map { "Value: \($0)" }
            .assign(to: \.text, on: valueLabel)
            .store(in: &cancellables)
        
        viewModel.$activeAlert
            .compactMap { $0 }
            .sink { [weak self] alertType in
                guard let self = self else { return }
                
                switch alertType {
                case .info:
                    self.showInfoAlert(self.viewModel.value.description)
                case .error(let error):
                    self.showErrorAlert(error)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 로딩 상태 바인딩
        viewModel.$loadingState
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .increasing:
                    self.increaseButton.configuration?.showsActivityIndicator = true
                    self.increaseButton.isEnabled = false
                    
                case .decreasing:
                    self.decreaseButton.configuration?.showsActivityIndicator = true
                    self.decreaseButton.isEnabled = false
                    
                case .none:
                    self.increaseButton.configuration?.showsActivityIndicator = false
                    self.increaseButton.isEnabled = true
                    
                    self.decreaseButton.configuration?.showsActivityIndicator = false
                    self.decreaseButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func showInfoAlert(_ message: String) {
        let alert = UIAlertController(title: "알림", message: message, preferredStyle: .alert)
        alert.addAction(.init(title: "닫기", style: .cancel))
        present(alert, animated: true)
    }
    
    private func showErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "오류", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    private func bindInput() {
        increaseButton.addAction(self) { owner in
            owner.viewModel.send(.increase)
        }
        
        decreaseButton.addAction(self) { owner in
            owner.viewModel.send(.decrease)
        }
        
        resetButton.addAction(self) { owner in
            owner.viewModel.send(.reset)
        }
        
        showButton.addAction(self) { owner in
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
    FlexCounterViewController(CounterAsyncViewModel())
} 
