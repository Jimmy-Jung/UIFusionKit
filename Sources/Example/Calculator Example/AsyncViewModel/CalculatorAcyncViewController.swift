//
//  CalculatorAsyncViewController.swift
//  UIFusionKit
//
//  Created by Assistant on 2024/12/20.
//

import UIKit
import Combine
import PinLayout

@MainActor
final class CalculatorAsyncViewController: UIViewController {
    
    // MARK: - UI Components
    private let displayLabel = UILabel()
        .font(.systemFont(ofSize: 48, weight: .light))
        .textColor(.label)
        .textAlignment(.right)
        .text("0")
        .adjustsFontSizeToFitWidth(true, 0.5)
        .accessibilityIdentifier("calculator_display_async")
    
    private let displayContainerView = UIView()
        .backgroundColor(.systemGray6)
        .cornerRadius(12)
    
    private let timerStatusLabel = UILabel()
        .font(.systemFont(ofSize: 12))
        .textColor(.systemOrange)
        .text("5초 후 자동 클리어됩니다")
        .isHidden(true)
    
    private let timerIconImageView = UIImageView(image: UIImage(systemName: "timer"))
        .tintColor(.systemOrange)
        .isHidden(true)
    
    private let buttonsStackView = UIStackView()
        .axis(.vertical)
        .spacing(12)
        .distribution(.fillEqually)
    
    // MARK: - ViewModel Properties
    private let viewModel: CalculatorAsyncViewModel
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(viewModel: CalculatorAsyncViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    // MARK: - ViewModel Binding
    private func bindViewModel() {
        // Display text 바인딩
        viewModel.$state
            .map(\.display)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] display in
                self?.displayLabel.text = display
            }
            .store(in: &cancellables)
        
        // Auto clear timer 상태 바인딩
        viewModel.$state
            .map(\.isAutoClearTimerActive)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isActive in
                self?.updateTimerStatus(isActive)
            }
            .store(in: &cancellables)
        
        // Alert 바인딩
        viewModel.$state
            .map(\.activeAlert)
            .removeDuplicates()
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] alertType in
                self?.handleAlert(alertType)
            }
            .store(in: &cancellables)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor(.systemBackground)
        
        // 타이머 상태 표시 스택뷰
        let timerStackView = UIStackView()
            .axis(.horizontal)
            .spacing(8)
            .alignment(.center)
        
        timerStackView.addArrangedSubview(timerIconImageView)
        timerStackView.addArrangedSubview(timerStatusLabel)
        timerStackView.addArrangedSubview(UIView()) // Spacer
        
        // 디스플레이 컨테이너에 컴포넌트들 추가
        displayContainerView.addSubview(timerStackView)
        displayContainerView.addSubview(displayLabel)
        
        // 메인 뷰에 컴포넌트들 추가
        view.addSubview(displayContainerView)
        view.addSubview(buttonsStackView)
        
        // 버튼 그리드 생성
        createButtonGrid()
    }
    
    private func setupLayout() {
        let safeArea = view.safeAreaInsets
        let padding: CGFloat = 20
        
        // 디스플레이 컨테이너
        displayContainerView.pin
            .top(safeArea.top + padding)
            .left(padding)
            .right(padding)
            .height(140)
        
        // 타이머 상태 스택뷰
        if let timerStack = displayContainerView.subviews.first(where: { $0 is UIStackView }) {
            timerStack.pin
                .top(12)
                .left(16)
                .right(16)
                .height(20)
        }
        
        // 디스플레이 라벨
        displayLabel.pin
            .below(of: displayContainerView.subviews.first(where: { $0 is UIStackView }) ?? displayContainerView)
            .marginTop(8)
            .left(16)
            .right(16)
            .bottom(16)
        
        // 버튼 스택뷰
        buttonsStackView.pin
            .below(of: displayContainerView)
            .marginTop(padding)
            .left(padding)
            .right(padding)
            .bottom(safeArea.bottom + padding)
    }
    
    // MARK: - Button Setup
    private func createButtonGrid() {
        let buttonRows: [[(title: String, color: UIColor, accessibilityId: String)]] = [
            [
                ("C", .systemOrange, "clear_button_async"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("÷", .systemBlue, "operation_button_divide_async")
            ],
            [
                ("7", .systemGray, "number_button_7_async"),
                ("8", .systemGray, "number_button_8_async"),
                ("9", .systemGray, "number_button_9_async"),
                ("×", .systemBlue, "operation_button_multiply_async")
            ],
            [
                ("4", .systemGray, "number_button_4_async"),
                ("5", .systemGray, "number_button_5_async"),
                ("6", .systemGray, "number_button_6_async"),
                ("-", .systemBlue, "operation_button_subtract_async")
            ],
            [
                ("1", .systemGray, "number_button_1_async"),
                ("2", .systemGray, "number_button_2_async"),
                ("3", .systemGray, "number_button_3_async"),
                ("+", .systemBlue, "operation_button_add_async")
            ],
            [
                ("0", .systemGray, "number_button_0_async"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("=", .systemGreen, "equals_button_async")
            ]
        ]

        buttonRows.forEach {
            buttonsStackView.addArrangedSubview(createButtonRow(buttons: $0))
        }
    }
    
    private func createButtonRow(buttons: [(title: String, color: UIColor, accessibilityId: String)]) -> UIStackView {
        let rowStack = UIStackView()
            .axis(.horizontal)
            .spacing(12)
            .distribution(.fillEqually)
        
        for (title, color, accessibilityId) in buttons {
            if title.isEmpty {
                rowStack.addArrangedSubview(UIView())
            } else {
                let button = createCalculatorButton(title: title, color: color, accessibilityId: accessibilityId)
                setupButtonAction(button: button, title: title)
                rowStack.addArrangedSubview(button)
            }
        }
        
        return rowStack
    }
    
    private func createCalculatorButton(title: String, color: UIColor, accessibilityId: String) -> UIButton {
        let button = UIButton(configuration: .filled())
            .title(title)
            .baseForegroundColor(.white)
            .baseBackgroundColor(color)
            .cornerStyle(.medium)
            .accessibilityIdentifier(accessibilityId)
            .frame(height: 60)
        
        return button
    }
    
    private func setupButtonAction(button: UIButton, title: String) {
        button.addAction(UIAction { [weak self] _ in
            self?.handleButtonTap(title: title)
        }, for: .touchUpInside)
    }
    
    private func handleButtonTap(title: String) {
        switch title {
        case "0"..."9":
            if let digit = Int(title) {
                viewModel.send(.number(digit))
            }
        case "+":
            viewModel.send(.operation(.add))
        case "-":
            viewModel.send(.operation(.subtract))
        case "×":
            viewModel.send(.operation(.multiply))
        case "÷":
            viewModel.send(.operation(.divide))
        case "=":
            viewModel.send(.equals)
        case "C":
            viewModel.send(.clear)
        default:
            break
        }
    }
    
    // MARK: - Timer Status Update
    private func updateTimerStatus(_ isActive: Bool) {
        UIView.animate(withDuration: 0.3) {
            self.timerIconImageView.isHidden = !isActive
            self.timerStatusLabel.isHidden = !isActive
            
            if isActive {
                self.displayContainerView.layer.borderColor = UIColor.systemOrange.withAlphaComponent(0.6).cgColor
                self.displayContainerView.layer.borderWidth = 2
            } else {
                self.displayContainerView.layer.borderWidth = 0
            }
        }
    }
    
    // MARK: - Alert Handling
    private func handleAlert(_ alertType: CalculatorAsyncViewModel.State.AlertType) {
        switch alertType {
        case .error(let error):
            let alert = UIAlertController(
                title: "오류",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.viewModel.send(.dismissAlert)
            })
            
            present(alert, animated: true)
        }
    }
}

// MARK: - Preview
@available(iOS 17.0, *)
#Preview {
    CalculatorAsyncViewController(viewModel: CalculatorAsyncViewModel())
}
