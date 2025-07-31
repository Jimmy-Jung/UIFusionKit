//
//  CalculatorTCAViewController.swift
//  UIFusionKit
//
//  Created by Assistant on 2024/12/19.
//

import UIKit
import ComposableArchitecture
import Combine
import PinLayout

final class CalculatorTCAViewController: UIViewController {
    
    // MARK: - UI Components
    private let displayLabel = UILabel()
        .font(.systemFont(ofSize: 48, weight: .light))
        .textColor(.label)
        .textAlignment(.right)
        .text("0")
        .adjustsFontSizeToFitWidth(true, 0.5)
        .accessibilityIdentifier("calculator_display_tca")
    
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
    
    // MARK: - TCA Properties
    private let store: StoreOf<CalculatorFeature>
    private let viewStore: ViewStoreOf<CalculatorFeature>
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(store: StoreOf<CalculatorFeature>) {
        self.store = store
        self.viewStore = ViewStore(store, observe: { $0 })
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindStore()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    // MARK: - Store Binding
    private func bindStore() {
        // Display text 바인딩
        viewStore.publisher.display
            .removeDuplicates()
            .sink { [weak self] display in
                self?.displayLabel.text = display
            }
            .store(in: &cancellables)
        
        // Auto clear timer 상태 바인딩
        viewStore.publisher.isAutoClearTimerActive
            .removeDuplicates()
            .sink { [weak self] isActive in
                self?.updateTimerStatus(isActive)
            }
            .store(in: &cancellables)
        
        // Alert 바인딩
        viewStore.publisher.activeAlert
            .removeDuplicates()
            .compactMap { $0 }
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
            .height(140) // 타이머 상태 표시를 위해 높이 증가
        
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
        // 첫 번째 행: C, ÷
        let firstRow = createButtonRow(
            buttons: [
                ("C", .systemOrange, "clear_button_tca"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("÷", .systemBlue, "operation_button_divide_tca")
            ]
        )
        
        // 두 번째 행: 7, 8, 9, ×
        let secondRow = createButtonRow(
            buttons: [
                ("7", .systemGray, "number_button_7_tca"),
                ("8", .systemGray, "number_button_8_tca"),
                ("9", .systemGray, "number_button_9_tca"),
                ("×", .systemBlue, "operation_button_multiply_tca")
            ]
        )
        
        // 세 번째 행: 4, 5, 6, -
        let thirdRow = createButtonRow(
            buttons: [
                ("4", .systemGray, "number_button_4_tca"),
                ("5", .systemGray, "number_button_5_tca"),
                ("6", .systemGray, "number_button_6_tca"),
                ("-", .systemBlue, "operation_button_subtract_tca")
            ]
        )
        
        // 네 번째 행: 1, 2, 3, +
        let fourthRow = createButtonRow(
            buttons: [
                ("1", .systemGray, "number_button_1_tca"),
                ("2", .systemGray, "number_button_2_tca"),
                ("3", .systemGray, "number_button_3_tca"),
                ("+", .systemBlue, "operation_button_add_tca")
            ]
        )
        
        // 다섯 번째 행: 0, =
        let fifthRow = createButtonRow(
            buttons: [
                ("0", .systemGray, "number_button_0_tca"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("=", .systemGreen, "equals_button_tca")
            ]
        )
        
        buttonsStackView.addArrangedSubview(firstRow)
        buttonsStackView.addArrangedSubview(secondRow)
        buttonsStackView.addArrangedSubview(thirdRow)
        buttonsStackView.addArrangedSubview(fourthRow)
        buttonsStackView.addArrangedSubview(fifthRow)
    }
    
    private func createButtonRow(buttons: [(title: String, color: UIColor, accessibilityId: String)]) -> UIStackView {
        let rowStack = UIStackView()
            .axis(.horizontal)
            .spacing(12)
            .distribution(.fillEqually)
        
        for (title, color, accessibilityId) in buttons {
            if title.isEmpty {
                // 빈 공간
                let spacerView = UIView()
                rowStack.addArrangedSubview(spacerView)
            } else {
                // 버튼 생성
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
        // 버튼 제목에 따라 액션 설정
        button.addAction(UIAction { [weak self] _ in
            self?.handleButtonTap(title: title)
        }, for: .touchUpInside)
    }
    
    private func handleButtonTap(title: String) {
        switch title {
        case "0"..."9":
            if let digit = Int(title) {
                viewStore.send(.numberTapped(digit))
            }
        case "+":
            viewStore.send(.operationTapped(.add))
        case "-":
            viewStore.send(.operationTapped(.subtract))
        case "×":
            viewStore.send(.operationTapped(.multiply))
        case "÷":
            viewStore.send(.operationTapped(.divide))
        case "=":
            viewStore.send(.equalsTapped)
        case "C":
            viewStore.send(.clearTapped)
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
    private func handleAlert(_ alertType: CalculatorFeature.State.AlertType) {
        switch alertType {
        case .error(let error):
            let alert = UIAlertController(
                title: "오류",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.viewStore.send(.dismissAlert)
            })
            
            present(alert, animated: true)
        }
    }
}

// MARK: - Preview
@available(iOS 17.0, *)
#Preview {
    CalculatorTCAViewController(
        store: Store(initialState: CalculatorFeature.State()) {
            CalculatorFeature()
        }
    )
} 
