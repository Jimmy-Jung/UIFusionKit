//
//  CalculatorAsyncViewModelTests.swift
//  UIFusionKitTests
//
//  Created by 정준영 on 2025/4/21.
//

import Testing
import Foundation
@testable import UIFusionKit

@MainActor
struct CalculatorAsyncViewModelTests {
    
    // MARK: - Test Cases
    
    @Test("숫자 버튼을 누르면 화면에 표시되어야 한다")
    func testDigitInput_updatesDisplayValue() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // When
        testStore.send(.number(7))
        
        // Then
        try await testStore.wait(for: { $0.display == "7" })
        #expect(testStore.state.display == "7")
    }

    @Test("연속적인 숫자 입력이 올바르게 처리되어야 한다")
    func testMultipleDigitInputs_areAppendedCorrectly() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // When
        testStore.send(.number(1))
        try await testStore.wait(for: { $0.display == "1" })
        
        testStore.send(.number(2))
        try await testStore.wait(for: { $0.display == "12" })
        
        testStore.send(.number(3))
        try await testStore.wait(for: { $0.display == "123" })
        
        // Then
        #expect(testStore.state.display == "123")
    }
    
    @Test("연산 수행 시 UseCase를 호출하고 결과를 표시해야 한다")
    func testCalculation_callsUseCaseAndDisplaysResult() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // When
        testStore.send(.number(8))
        try await testStore.wait(for: { $0.display == "8" })
        
        testStore.send(.operation(.add))
        try await testStore.wait(for: { $0.calculatorState.currentOperation == .add })
        
        testStore.send(.number(7))
        try await testStore.wait(for: { $0.display == "7" })
        
        testStore.send(.equals)
        try await testStore.wait(for: { $0.display == "15" })
        
        // Then
        #expect(testStore.state.display == "15")
    }
    
    @Test("Clear 버튼을 누르면 상태가 초기화되어야 한다")
    func testClearButton_resetsTheState() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // When
        testStore.send(.number(1))
        testStore.send(.operation(.add))
        testStore.send(.clear)
        
        // Then
        try await testStore.wait(for: { $0.display == "0" && $0.calculatorState.currentOperation == nil })
        
        let initialState = CalculatorAsyncViewModel.State()
        #expect(testStore.state.display == initialState.display)
        #expect(testStore.state.calculatorState == initialState.calculatorState)
    }
    
    @Test("0으로 나누기 에러 시 에러 알림이 표시되어야 한다")
    func testDivisionByZero_displaysErrorAlert() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // When
        testStore.send(.number(9))
        try await testStore.wait(for: { $0.display == "9" })
        
        testStore.send(.operation(.divide))
        try await testStore.wait(for: { $0.calculatorState.currentOperation == .divide })
        
        testStore.send(.number(0))
        try await testStore.wait(for: { $0.display == "0" })
        
        testStore.send(.equals)
        try await testStore.wait(for: { $0.activeAlert != nil })
        
        // Then
        #expect(testStore.state.activeAlert != nil)
        #expect(testStore.state.display == "0") // 에러 후 state가 clear()로 초기화됨
    }
    
    @Test("연산 후 새로운 숫자를 입력하면 새 계산이 시작되어야 한다")
    func testNewNumberInputAfterCalculation_startsNewCalculation() async throws {
        // Given
        let useCase = CalculatorUseCase()
        let testStore = AsyncTestStore(viewModel: CalculatorAsyncViewModel(calculatorUseCase: useCase))
        
        // 5 + 5 = 10 계산
        testStore.send(.number(5))
        try await testStore.wait(for: { $0.display == "5" })
        
        testStore.send(.operation(.add))
        try await testStore.wait(for: { $0.calculatorState.currentOperation == .add })
        
        testStore.send(.number(5))
        try await testStore.wait(for: { $0.display == "5" })
        
        testStore.send(.equals)
        try await testStore.wait(for: { $0.display == "10" && $0.calculatorState.shouldResetDisplay == true })
        
        // When
        // 계산 완료 후 새로운 숫자 '3'을 입력
        testStore.send(.number(3))
        
        // Then
        try await testStore.wait(for: { $0.display == "3" && $0.calculatorState.shouldResetDisplay == false })
        
        #expect(testStore.state.display == "3")
        #expect(testStore.state.calculatorState.currentOperation == nil) // 새 계산 시작
        #expect(testStore.state.calculatorState.shouldResetDisplay == false)
    }
}
