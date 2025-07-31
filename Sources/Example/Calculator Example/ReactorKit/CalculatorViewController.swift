//
//  CalculatorViewController.swift
//  UIFusionKit
//
//  Created by Assistant on 2024/12/19.
//

import UIKit
import ReactorKit
import RxSwift
import RxCocoa
import PinLayout

final class CalculatorViewController: UIViewController, ReactorKit.View {
    
    // MARK: - UI Components
    private let displayLabel = UILabel()
        .font(.systemFont(ofSize: 48, weight: .light))
        .textColor(.label)
        .textAlignment(.right)
        .text("0")
        .adjustsFontSizeToFitWidth(true, 0.5)
        .accessibilityIdentifier("calculator_display")
    
    private let displayContainerView = UIView()
        .backgroundColor(.systemGray6)
        .cornerRadius(12)
    
    private let buttonsStackView = UIStackView()
        .axis(.vertical)
        .spacing(12)
        .distribution(.fillEqually)
    
    // MARK: - Properties
    var disposeBag = DisposeBag()
    
    // MARK: - Initialization
    init(reactor: CalculatorReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupLayout()
    }
    
    // MARK: - ReactorKit.View
    func bind(reactor: CalculatorReactor) {
        // State 바인딩
        reactor.state
            .map { $0.display }
            .distinctUntilChanged()
            .bind(to: displayLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.activeAlert }
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] alertType in
                self?.handleAlert(alertType)
            })
            .disposed(by: disposeBag)
        
        // Action 바인딩은 setupButtons()에서 처리
        setupButtons(reactor: reactor)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor(.systemBackground)
        
        // 디스플레이 컨테이너에 라벨 추가
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
            .height(120)
        
        // 디스플레이 라벨
        displayLabel.pin
            .top(16)
            .left(16)
            .right(16)
            .bottom(16)
            .all()
        
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
                ("C", .systemOrange, "clear_button"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("÷", .systemBlue, "operation_button_divide")
            ]
        )
        
        // 두 번째 행: 7, 8, 9, ×
        let secondRow = createButtonRow(
            buttons: [
                ("7", .systemGray, "number_button_7"),
                ("8", .systemGray, "number_button_8"),
                ("9", .systemGray, "number_button_9"),
                ("×", .systemBlue, "operation_button_multiply")
            ]
        )
        
        // 세 번째 행: 4, 5, 6, -
        let thirdRow = createButtonRow(
            buttons: [
                ("4", .systemGray, "number_button_4"),
                ("5", .systemGray, "number_button_5"),
                ("6", .systemGray, "number_button_6"),
                ("-", .systemBlue, "operation_button_subtract")
            ]
        )
        
        // 네 번째 행: 1, 2, 3, +
        let fourthRow = createButtonRow(
            buttons: [
                ("1", .systemGray, "number_button_1"),
                ("2", .systemGray, "number_button_2"),
                ("3", .systemGray, "number_button_3"),
                ("+", .systemBlue, "operation_button_add")
            ]
        )
        
        // 다섯 번째 행: 0, =
        let fifthRow = createButtonRow(
            buttons: [
                ("0", .systemGray, "number_button_0"),
                ("", .clear, ""),
                ("", .clear, ""),
                ("=", .systemGreen, "equals_button")
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
    
    private func setupButtons(reactor: CalculatorReactor) {
        // 숫자 버튼들
        for i in 0...9 {
            if let button = view.viewWithAccessibilityIdentifier("number_button_\(i)") as? UIButton {
                button.rx.tap
                    .map { CalculatorReactor.Action.inputNumber(i) }
                    .bind(to: reactor.action)
                    .disposed(by: disposeBag)
            }
        }
        
        // 연산자 버튼들
        if let addButton = view.viewWithAccessibilityIdentifier("operation_button_add") as? UIButton {
            addButton.rx.tap
                .map { CalculatorReactor.Action.setOperation(.add) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        if let subtractButton = view.viewWithAccessibilityIdentifier("operation_button_subtract") as? UIButton {
            subtractButton.rx.tap
                .map { CalculatorReactor.Action.setOperation(.subtract) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        if let multiplyButton = view.viewWithAccessibilityIdentifier("operation_button_multiply") as? UIButton {
            multiplyButton.rx.tap
                .map { CalculatorReactor.Action.setOperation(.multiply) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        if let divideButton = view.viewWithAccessibilityIdentifier("operation_button_divide") as? UIButton {
            divideButton.rx.tap
                .map { CalculatorReactor.Action.setOperation(.divide) }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        // 등호 버튼
        if let equalsButton = view.viewWithAccessibilityIdentifier("equals_button") as? UIButton {
            equalsButton.rx.tap
                .map { CalculatorReactor.Action.calculate }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
        
        // 클리어 버튼
        if let clearButton = view.viewWithAccessibilityIdentifier("clear_button") as? UIButton {
            clearButton.rx.tap
                .map { CalculatorReactor.Action.clear }
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
        }
    }
    
    // MARK: - Alert Handling
    private func handleAlert(_ alertType: CalculatorReactor.AlertType?) {
        guard let alertType = alertType else { return }
        
        switch alertType {
        case .error(let error):
            let alert = UIAlertController(
                title: "오류",
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                self?.reactor?.action.onNext(.dismissAlert)
            })
            
            present(alert, animated: true)
        }
    }
}

// MARK: - UIView Extension for Accessibility
extension UIView {
    func viewWithAccessibilityIdentifier(_ identifier: String) -> UIView? {
        if self.accessibilityIdentifier == identifier {
            return self
        }
        
        for subview in subviews {
            if let found = subview.viewWithAccessibilityIdentifier(identifier) {
                return found
            }
        }
        
        return nil
    }
} 

@available(iOS 17.0, *)
#Preview {
    CalculatorViewController(reactor: CalculatorReactor())
}
