//
//  CalculatorAsyncViewModel.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import SwiftUI
import Foundation

// Error를 감싸는 Hashable 구조체 정의
struct HashableError: Error, Hashable {
    let message: String

    init(_ error: Error) {
        self.message = error.localizedDescription
    }

    // Hashable 준수를 위해 Equatable 구현
    static func == (lhs: HashableError, rhs: HashableError) -> Bool {
        lhs.message == rhs.message
    }

    // Hashable 준수를 위해 hash(into:) 구현
    func hash(into hasher: inout Hasher) {
        hasher.combine(message)
    }
}


final class CalculatorAsyncViewModel: AsyncViewModel {
    
    // MARK: - Cancellation ID
    private enum CancelID: Hashable {
        case autoClearTimer
    }
    
    // 알림 타입을 정의하는 enum
    enum AlertType: Identifiable {
        case error(Error)
        var id: String { "error" }
    }
    
    enum Input {
        case number(Int)
        case operation(CalculatorOperation)
        case equals
        case clear
        case dismissAlert
    }

    // Action 열거형을 간소화
    enum Action: Hashable {
        case inputNumber(Int)
        case setOperation(CalculatorOperation)
        case calculate
        case clearAll
        case dismissAlert
        case autoClear
        case setTimerActive(Bool)
        case errorOccurred(HashableError) // Error 대신 HashableError 사용
    }
    
    var tasks: [AnyHashable: Task<Void, Never>] = [:]
    // MARK: - Published Properties
    @Published var display: String = "0"
    @Published var activeAlert: AlertType?
    @Published var isAutoClearTimerActive: Bool = false

    // MARK: - Private Properties
    private var calculatorState: CalculatorState = .initial
    private let calculatorUseCase: CalculatorUseCaseProtocol
    
    // MARK: - Initialization
    init(calculatorUseCase: CalculatorUseCaseProtocol = CalculatorUseCase()) {
        self.calculatorUseCase = calculatorUseCase
        updateDisplayFromState()
    }
    
    // MARK: - AsyncViewModel Protocol
    
    func transform(_ input: Input) -> [Action] {
        switch input {
        case .number(let digit): return [.inputNumber(digit)]
        case .operation(let op): return [.setOperation(op)]
        case .equals: return [.calculate]
        case .clear: return [.clearAll]
        case .dismissAlert: return [.dismissAlert]
        }
    }
    
    func perform(_ action: Action) async -> [AsyncEffect<Action>] {
        switch action {
        case .inputNumber(let digit):
            return await handleInputNumber(digit)
        case .setOperation(let operation):
            return await handleSetOperation(operation)
        case .calculate:
            return await handleCalculate()
        case .clearAll:
            return handleClearAll()
        case .dismissAlert:
            return handleDismissAlert()
        case .autoClear:
            return await handleAutoClear()
        case .setTimerActive(let isActive):
            return handleSetTimerActive(isActive)
        case .errorOccurred(let error):
            await handleError(error)
            return []
        }
    }
    
    func handleError(_ error: Error) async {
        activeAlert = .error(error)
        calculatorState = calculatorUseCase.clear()
        updateDisplayFromState()
        isAutoClearTimerActive = false
        print("계산기 오류: \(error.localizedDescription)")
    }

    private func updateDisplayFromState() {
        display = calculatorState.display
    }
    
    // MARK: - Action Handlers
    
    private func handleInputNumber(_ digit: Int) async -> [AsyncEffect<Action>] {
        do {
            calculatorState = try calculatorUseCase.inputNumber(digit, currentState: calculatorState)
            updateDisplayFromState()
            return [.cancel(id: CancelID.autoClearTimer), .action(.setTimerActive(false))]
        } catch {
            return [.action(.errorOccurred(HashableError(error)))]
        }
    }
    
    private func handleSetOperation(_ operation: CalculatorOperation) async -> [AsyncEffect<Action>] {
        do {
            calculatorState = try calculatorUseCase.setOperation(operation, currentState: calculatorState)
            updateDisplayFromState()
            return [.cancel(id: CancelID.autoClearTimer), .action(.setTimerActive(false))]
        } catch {
            return [.action(.errorOccurred(HashableError(error)))]
        }
    }
    
    private func handleCalculate() async -> [AsyncEffect<Action>] {
        do {
            calculatorState = try calculatorUseCase.calculate(currentState: calculatorState)
            updateDisplayFromState()
            return [.runCancellable(action: .autoClear, id: CancelID.autoClearTimer)]
        } catch {
            return [.action(.errorOccurred(HashableError(error)))]
        }
    }
    
    private func handleClearAll() -> [AsyncEffect<Action>] {
        calculatorState = calculatorUseCase.clear()
        updateDisplayFromState()
        return [.cancel(id: CancelID.autoClearTimer), .action(.setTimerActive(false))]
    }
    
    private func handleDismissAlert() -> [AsyncEffect<Action>] {
        activeAlert = nil
        return []
    }
    
    private func handleAutoClear() async -> [AsyncEffect<Action>] {
        isAutoClearTimerActive = true
        defer { isAutoClearTimerActive = false }
        
        do {
            try await Task.sleep(for: .seconds(5))
            calculatorState = calculatorUseCase.clear()
            updateDisplayFromState()
        } catch {
            // CancellationError는 무시
        }
        return []
    }
    
    private func handleSetTimerActive(_ isActive: Bool) -> [AsyncEffect<Action>] {
        isAutoClearTimerActive = isActive
        return []
    }
}
