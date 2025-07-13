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
    
    // 연산자 타입
    enum Operation: String, CaseIterable {
        case add = "+"
        case subtract = "-"
        case multiply = "×"
        case divide = "÷"
        
        func calculate(_ lhs: Double, _ rhs: Double) throws -> Double {
            switch self {
            case .add:
                return lhs + rhs
            case .subtract:
                return lhs - rhs
            case .multiply:
                return lhs * rhs
            case .divide:
                if rhs == 0 {
                    throw CalculatorError.divisionByZero
                }
                return lhs / rhs
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
    
    // MARK: - Private Properties
    private var calculatorState: CalculatorState = .initial
    private let calculatorUseCase: CalculatorUseCaseProtocol
    
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
        calculatorState = try calculatorUseCase.inputNumber(digit, currentState: calculatorState)
        updateDisplayFromState()
    }
    
    // 연산자 설정
    private func setOperation(_ operation: CalculatorOperation) async throws {
        calculatorState = try calculatorUseCase.setOperation(operation, currentState: calculatorState)
        updateDisplayFromState()
    }
    
    // 계산 수행
    private func calculate() async throws {
        calculatorState = try calculatorUseCase.calculate(currentState: calculatorState)
        updateDisplayFromState()
    }
    
    // 모든 값 초기화
    private func clearAll() async throws {
        calculatorState = calculatorUseCase.clear()
        updateDisplayFromState()
    }
    
    // 상태에서 디스플레이 업데이트
    private func updateDisplayFromState() {
        display = calculatorState.display
    }
} 
