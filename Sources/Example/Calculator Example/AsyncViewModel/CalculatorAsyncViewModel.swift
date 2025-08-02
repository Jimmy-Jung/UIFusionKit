//
//  CalculatorAsyncViewModel.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import SwiftUI
import Foundation

final class CalculatorAsyncViewModel: AsyncViewModel {
    
    // 알림 타입을 정의하는 enum
    enum AlertType: Identifiable {
        case error(Error)
        
        var id: String {
            switch self {
            case .error: return "error"
            }
        }
    }
    
    enum Input {
        case number(Int)
        case operation(CalculatorOperation)
        case equals
        case clear
        case dismissAlert
    }

    enum Action {
        case inputNumber(Int)
        case setOperation(CalculatorOperation)
        case calculate
        case clearAll
        case dismissAlert
    }
    
    // MARK: - Published Properties
    @Published var display: String = "0"
    @Published var activeAlert: AlertType?
    @Published var isAutoClearTimerActive: Bool = false

    // MARK: - Private Properties
    private var calculatorState: CalculatorState = .initial
    private let calculatorUseCase: CalculatorUseCaseProtocol
    private var autoClearTask: Task<Void, Never>?
    
    // MARK: - Initialization
    init(calculatorUseCase: CalculatorUseCaseProtocol = CalculatorUseCase()) {
        self.calculatorUseCase = calculatorUseCase
        updateDisplayFromState()
    }
    
    // MARK: - AsyncViewModel Protocol
    func transform(_ input: Input) async -> [Action] {
        switch input {
        case .number(let digit):
            return [.inputNumber(digit)]
        case .operation(let op):
            return [.setOperation(op)]
        case .equals:
            return [.calculate]
        case .clear:
            return [.clearAll]
        case .dismissAlert:
            return [.dismissAlert]
        }
    }
    
    func perform(_ action: Action) async throws {
        switch action {
        case .inputNumber(let digit):
            try await inputNumber(digit)
        case .setOperation(let operation):
            try await setOperation(operation)
        case .calculate:
            try await calculate()
        case .clearAll:
            try await clearAll()
        case .dismissAlert:
            dismissAlert()
        }
    }
    
    func handleError(_ error: Error) async {
        activeAlert = .error(error)
        // 오류 발생 시 초기화
        calculatorState = calculatorUseCase.clear()
        updateDisplayFromState()
        print("계산기 오류: \(error.localizedDescription)")
    }
    
    // MARK: - Private Methods
    
    private func dismissAlert() {
        activeAlert = nil
    }
    
    // 숫자 입력 처리
    private func inputNumber(_ digit: Int) async throws {
        cancelAutoClearTimer()
        calculatorState = try calculatorUseCase.inputNumber(digit, currentState: calculatorState)
        updateDisplayFromState()
    }
    
    // 연산자 설정
    private func setOperation(_ operation: CalculatorOperation) async throws {
        cancelAutoClearTimer()
        calculatorState = try calculatorUseCase.setOperation(operation, currentState: calculatorState)
        updateDisplayFromState()
    }
    
    // 계산 수행
    private func calculate() async throws {
        calculatorState = try calculatorUseCase.calculate(currentState: calculatorState)
        updateDisplayFromState()
        startAutoClearTimer()
    }
    
    // 모든 값 초기화
    private func clearAll() async throws {
        cancelAutoClearTimer()
        calculatorState = calculatorUseCase.clear()
        updateDisplayFromState()
    }
    
    // 상태에서 디스플레이 업데이트
    private func updateDisplayFromState() {
        display = calculatorState.display
    }

    private func startAutoClearTimer() {
        cancelAutoClearTimer() // 기존 타이머가 있으면 취소
        
        isAutoClearTimerActive = true
        autoClearTask = Task {
            do {
                try await Task.sleep(for: .seconds(5))
                if !Task.isCancelled {
                    await MainActor.run {
                        self.isAutoClearTimerActive = false
                        self.calculatorState = self.calculatorUseCase.clear()
                        self.updateDisplayFromState()
                    }
                }
            } catch {
                // Task.sleep에서 취소될 때 에러가 발생하므로 여기서 처리
                print("Auto-clear timer cancelled.")
            }
        }
    }

    private func cancelAutoClearTimer() {
        autoClearTask?.cancel()
        autoClearTask = nil
        if isAutoClearTimerActive {
            isAutoClearTimerActive = false
        }
    }
}
