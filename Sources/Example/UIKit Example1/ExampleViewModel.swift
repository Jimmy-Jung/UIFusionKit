//
//  ExampleViewModel.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine

// 예제 앱에서 발생할 수 있는 오류 정의
enum ExampleError: Error, LocalizedError {
    case valueOutOfRange(current: Int, min: Int, max: Int)
    case invalidOperation(description: String)
    
    var errorDescription: String? {
        switch self {
        case .valueOutOfRange(let current, let min, let max):
            return "값이 허용 범위를 벗어났습니다 (현재: \(current), 범위: \(min)~\(max))"
        case .invalidOperation(let description):
            return "잘못된 작업: \(description)"
        }
    }
}

final class ExampleViewModel: AsyncViewModel {
    
    // 알림 타입을 정의하는 enum
    enum AlertType: Identifiable {
        case none
        case info(message: String)
        case error(Error)
        
        var id: String {
            switch self {
            case .none: return "none"
            case .info: return "info"
            case .error: return "error"
            }
        }
    }
    
    enum Input {
        case viewDidLoad
        case buttonTap
    }

    enum Action {
        case changeLabelText
        case changeButtonText
        case changeButtonColor
        case increaseButtonCount
        case changeButtonHeight
    }
    
    // 상태 속성들
    @Published var buttonCount: Int = 0
    @Published var labelText: String? = "hello"
    @Published var buttonText: String? = "Button"
    @Published var buttonColor: UIColor? = .systemGray
    @Published var buttonFrame: (width: CGFloat?, height: CGFloat?) = (180, 50)
    @Published var activeAlert: AlertType?
    
    // 값의 허용 범위
    private let maxButtonCount = 10
    
    init() {}
    
    // Input을 Action으로 변환
    nonisolated func transform(_ input: Input) async -> [Action] {
        switch input {
            case .viewDidLoad:
                return [.changeLabelText, .changeButtonText]
            case .buttonTap:
                return [
                    .increaseButtonCount,
                    .changeButtonColor,
                    .changeButtonText,
                    .changeLabelText,
                    .changeButtonHeight
                ]
        }
    }
    
    // Action 수행
    func perform(_ action: Action) async throws {
        switch action {
            case .increaseButtonCount:
                try await increaseButtonCount()
                
            case .changeLabelText:
                changeLabelText()
                
            case .changeButtonText:
                changeButtonText()
                
            case .changeButtonColor:
                changeButtonColor()
                
            case .changeButtonHeight:
                changeButtonHeight()
        }
    }
    
    // 값을 증가시키는 메서드
    private func increaseButtonCount() async throws {
        let newValue = buttonCount + 1
        if newValue > maxButtonCount {
            throw ExampleError.valueOutOfRange(current: newValue, min: 0, max: maxButtonCount)
        }
        buttonCount = newValue
    }
    
    private func changeLabelText() {
        labelText = "Button tapped \(buttonCount)"
    }
    
    private func changeButtonText() {
        buttonText = "Button Tapped: \(buttonCount)"
    }
    
    private func changeButtonColor() {
        buttonColor = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink].randomElement()!
    }
    
    private func changeButtonHeight() {
        buttonFrame = buttonCount % 2 == 0 ? (180, 50) : (200, 80)
    }
    
    // 오류 처리
    func handleError(_ error: Error) async {
        if let exampleError = error as? ExampleError {
            activeAlert = .error(exampleError)
        } else {
            activeAlert = .error(ExampleError.invalidOperation(description: error.localizedDescription))
        }
        print("Example 오류: \(error.localizedDescription)")
    }
}
