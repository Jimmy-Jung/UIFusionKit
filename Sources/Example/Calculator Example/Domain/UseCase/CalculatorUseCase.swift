//
//  CalculatorUseCase.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Foundation

// 계산기 비즈니스 로직을 담당하는 UseCase
public protocol CalculatorUseCaseProtocol {
    func inputNumber(_ digit: Int, currentState: CalculatorState) throws -> CalculatorState
    func setOperation(_ operation: CalculatorOperation, currentState: CalculatorState) throws -> CalculatorState
    func calculate(currentState: CalculatorState) throws -> CalculatorState
    func clear() -> CalculatorState
}

public final class CalculatorUseCase: CalculatorUseCaseProtocol {
    
    public init() {}
    
    // 숫자 입력 처리
    public func inputNumber(_ digit: Int, currentState: CalculatorState) throws -> CalculatorState {
        guard digit >= 0 && digit <= 9 else {
            throw CalculatorError.invalidInput
        }
        
        let newDisplay: String
        let newCurrentValue: Double
        let newShouldResetDisplay: Bool
        
        if currentState.shouldResetDisplay {
            newDisplay = String(digit)
            newShouldResetDisplay = false
        } else {
            if currentState.display == "0" {
                newDisplay = String(digit)
            } else {
                // 최대 자릿수 제한 (10자리)
                if currentState.display.count < 10 {
                    newDisplay = currentState.display + String(digit)
                } else {
                    newDisplay = currentState.display
                }
            }
            newShouldResetDisplay = currentState.shouldResetDisplay
        }
        
        newCurrentValue = Double(newDisplay) ?? 0
        
        return CalculatorState(
            display: newDisplay,
            currentValue: newCurrentValue,
            previousValue: currentState.previousValue,
            currentOperation: currentState.currentOperation,
            shouldResetDisplay: newShouldResetDisplay
        )
    }
    
    // 연산자 설정
    public func setOperation(_ operation: CalculatorOperation, currentState: CalculatorState) throws -> CalculatorState {
        let newPreviousValue: Double
        let newCurrentValue: Double
        let newDisplay: String
        
        if let currentOp = currentState.currentOperation {
            // 이미 연산자가 있으면 먼저 계산
            let calculatedState = try performCalculation(currentOp, currentState: currentState)
            newPreviousValue = calculatedState.currentValue
            newCurrentValue = calculatedState.currentValue
            newDisplay = calculatedState.display
        } else {
            newPreviousValue = currentState.currentValue
            newCurrentValue = currentState.currentValue
            newDisplay = currentState.display
        }
        
        return CalculatorState(
            display: newDisplay,
            currentValue: newCurrentValue,
            previousValue: newPreviousValue,
            currentOperation: operation,
            shouldResetDisplay: true
        )
    }
    
    // 계산 수행
    public func calculate(currentState: CalculatorState) throws -> CalculatorState {
        guard let operation = currentState.currentOperation else {
            return currentState
        }
        
        let calculatedState = try performCalculation(operation, currentState: currentState)
        
        return CalculatorState(
            display: calculatedState.display,
            currentValue: calculatedState.currentValue,
            previousValue: calculatedState.currentValue,
            currentOperation: nil,
            shouldResetDisplay: true
        )
    }
    
    // 모든 값 초기화
    public func clear() -> CalculatorState {
        return CalculatorState.initial
    }
    
    // MARK: - Private Methods
    
    // 실제 계산 로직
    private func performCalculation(_ operation: CalculatorOperation, currentState: CalculatorState) throws -> CalculatorState {
        let result = try operation.calculate(currentState.previousValue, currentState.currentValue)
        
        // 오버플로우 체크
        if result.isInfinite || result.isNaN {
            throw CalculatorError.overflow
        }
        
        // 결과를 적절한 형식으로 표시
        let displayResult: String
        if result == floor(result) && result < 1e10 {
            displayResult = String(format: "%.0f", result)
        } else {
            displayResult = String(format: "%.8g", result)
        }
        
        return CalculatorState(
            display: displayResult,
            currentValue: result,
            previousValue: currentState.previousValue,
            currentOperation: currentState.currentOperation,
            shouldResetDisplay: currentState.shouldResetDisplay
        )
    }
} 