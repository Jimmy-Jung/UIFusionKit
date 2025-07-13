//
//  CalculatorUseCaseTests.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Testing
@testable import UIFusionKit

// MARK: - Test Suite
struct CalculatorUseCaseTests {
    
    // MARK: - Properties
    let useCase = CalculatorUseCase()
    let initialState = CalculatorState.initial
    
    // MARK: - Number Input Tests
    
    @Test("숫자 입력 - 초기 상태에서 숫자 입력 시 디스플레이 업데이트")
    func inputNumberFromInitialState() throws {
        // Given
        let digit = 5
        
        // When
        let result = try useCase.inputNumber(digit, currentState: initialState)
        
        // Then
        #expect(result.display == "5")
        #expect(result.currentValue == 5.0)
        #expect(result.shouldResetDisplay == false)
    }
    
    @Test("숫자 입력 - 여러 자릿수 입력 시 연결되어 표시")
    func inputMultipleDigits() throws {
        // Given
        var state = try useCase.inputNumber(1, currentState: initialState)
        state = try useCase.inputNumber(2, currentState: state)
        
        // When
        let result = try useCase.inputNumber(3, currentState: state)
        
        // Then
        #expect(result.display == "123")
        #expect(result.currentValue == 123.0)
    }
    
    @Test("숫자 입력 - 잘못된 숫자 입력 시 에러 발생", arguments: [-1, 10, 15])
    func inputInvalidDigit(invalidDigit: Int) {
        // Given & When & Then
        #expect(throws: CalculatorError.invalidInput) {
            try useCase.inputNumber(invalidDigit, currentState: initialState)
        }
    }
    
    // MARK: - Operation Tests
    
    @Test("연산자 설정 - 덧셈 연산자 설정")
    func setAdditionOperation() throws {
        // Given
        let state = try useCase.inputNumber(5, currentState: initialState)
        
        // When
        let result = try useCase.setOperation(.add, currentState: state)
        
        // Then
        #expect(result.currentOperation == .add)
        #expect(result.previousValue == 5.0)
        #expect(result.shouldResetDisplay == true)
    }
    
    @Test("연산자 설정 - 연속 연산 시 먼저 계산 수행")
    func setChainedOperations() throws {
        // Given
        var state = try useCase.inputNumber(5, currentState: initialState)
        state = try useCase.setOperation(.add, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        
        // When
        let result = try useCase.setOperation(.multiply, currentState: state)
        
        // Then
        #expect(result.display == "8")
        #expect(result.currentValue == 8.0)
        #expect(result.currentOperation == .multiply)
    }
    
    // MARK: - Calculation Tests
    
    @Test("계산 수행 - 덧셈 계산 결과 확인")
    func calculateAddition() throws {
        // Given
        var state = try useCase.inputNumber(5, currentState: initialState)
        state = try useCase.setOperation(.add, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.display == "8")
        #expect(result.currentValue == 8.0)
        #expect(result.currentOperation == nil)
        #expect(result.shouldResetDisplay == true)
    }
    
    @Test("계산 수행 - 뺄셈 계산 결과 확인")
    func calculateSubtraction() throws {
        // Given
        var state = try useCase.inputNumber(1, currentState: initialState)
        state = try useCase.inputNumber(0, currentState: state)
        state = try useCase.setOperation(.subtract, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.display == "7")
        #expect(result.currentValue == 7.0)
    }
    
    @Test("계산 수행 - 곱셈 계산 결과 확인")
    func calculateMultiplication() throws {
        // Given
        var state = try useCase.inputNumber(6, currentState: initialState)
        state = try useCase.setOperation(.multiply, currentState: state)
        state = try useCase.inputNumber(7, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.display == "42")
        #expect(result.currentValue == 42.0)
    }
    
    @Test("계산 수행 - 나눗셈 계산 결과 확인")
    func calculateDivision() throws {
        // Given
        var state = try useCase.inputNumber(1, currentState: initialState)
        state = try useCase.inputNumber(5, currentState: state)
        state = try useCase.setOperation(.divide, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.display == "5")
        #expect(result.currentValue == 5.0)
    }
    
    @Test("계산 수행 - 0으로 나누기 시 에러 발생")
    func calculateDivisionByZero() throws {
        // Given
        var state = try useCase.inputNumber(5, currentState: initialState)
        state = try useCase.setOperation(.divide, currentState: state)
        state = try useCase.inputNumber(0, currentState: state)
        
        // When & Then
        #expect(throws: CalculatorError.divisionByZero) {
            try useCase.calculate(currentState: state)
        }
    }
    
    // MARK: - Parameterized Calculation Tests
    
    @Test("사칙연산 검증", arguments: [
        (5, CalculatorOperation.add, 3, 8.0, "8"),
        (9, CalculatorOperation.subtract, 4, 5.0, "5"),
        (7, CalculatorOperation.multiply, 6, 42.0, "42"),
        (8, CalculatorOperation.divide, 4, 2.0, "2")
    ])
    func validateBasicOperations(
        firstNumber: Int,
        operation: CalculatorOperation,
        secondNumber: Int,
        expectedValue: Double,
        expectedDisplay: String
    ) throws {
        // Given
        var state = try useCase.inputNumber(firstNumber, currentState: initialState)
        state = try useCase.setOperation(operation, currentState: state)
        state = try useCase.inputNumber(secondNumber, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.currentValue == expectedValue)
        #expect(result.display == expectedDisplay)
        #expect(result.currentOperation == nil)
        #expect(result.shouldResetDisplay == true)
    }
    
    @Test("두 자리 숫자 사칙연산 검증")
    func validateTwoDigitOperations() throws {
        // Given - 12 + 8 = 20
        var state = try useCase.inputNumber(1, currentState: initialState)
        state = try useCase.inputNumber(2, currentState: state)
        state = try useCase.setOperation(.add, currentState: state)
        state = try useCase.inputNumber(8, currentState: state)
        
        // When
        let result = try useCase.calculate(currentState: state)
        
        // Then
        #expect(result.currentValue == 20.0)
        #expect(result.display == "20")
        #expect(result.currentOperation == nil)
        #expect(result.shouldResetDisplay == true)
    }
    
    // MARK: - Clear Tests
    
    @Test("초기화 - 모든 상태가 초기값으로 복원")
    func clearAllStates() throws {
        // Given
        var state = try useCase.inputNumber(5, currentState: initialState)
        state = try useCase.setOperation(.add, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        
        // When
        let result = useCase.clear()
        
        // Then
        #expect(result == CalculatorState.initial)
    }
    
    // MARK: - Edge Case Tests
    
    @Test("경계값 테스트 - 최대 자릿수 입력")
    func inputMaximumDigits() throws {
        // Given
        var state = initialState
        
        // When - 10자리 숫자 입력
        for digit in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] {
            state = try useCase.inputNumber(digit, currentState: state)
        }
        
        // Then
        #expect(state.display == "1234567890")
        #expect(state.currentValue == 1234567890.0)
    }
    
    @Test("경계값 테스트 - 최대 자릿수 초과 시 무시")
    func inputExceedsMaximumDigits() throws {
        // Given
        var state = initialState
        
        // 10자리 숫자 입력
        for digit in [1, 2, 3, 4, 5, 6, 7, 8, 9, 0] {
            state = try useCase.inputNumber(digit, currentState: state)
        }
        
        // When - 11번째 자릿수 입력 시도
        let result = try useCase.inputNumber(1, currentState: state)
        
        // Then - 변화 없음
        #expect(result.display == "1234567890")
        #expect(result.currentValue == 1234567890.0)
    }
    
    @Test("상태 전환 테스트 - 연산 후 새로운 숫자 입력")
    func inputAfterCalculation() throws {
        // Given
        var state = try useCase.inputNumber(5, currentState: initialState)
        state = try useCase.setOperation(.add, currentState: state)
        state = try useCase.inputNumber(3, currentState: state)
        state = try useCase.calculate(currentState: state)
        
        // When - 계산 후 새로운 숫자 입력
        let result = try useCase.inputNumber(9, currentState: state)
        
        // Then - 디스플레이가 새로운 숫자로 교체됨
        #expect(result.display == "9")
        #expect(result.currentValue == 9.0)
        #expect(result.shouldResetDisplay == false)
    }
} 