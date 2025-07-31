//
//  CalculatorFeature.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import ComposableArchitecture
import Foundation

// MARK: - Calculator Feature

@Reducer
struct CalculatorFeature {
    
    // MARK: - State
    @ObservableState
    struct State: Equatable {
        var display: String = "0"
        var activeAlert: AlertType?
        var calculatorState: CalculatorState = .initial
        var isAutoClearTimerActive: Bool = false
        
        // 알림 타입을 정의하는 enum
        enum AlertType: Identifiable, Equatable {
            case error(Error)
            
            var id: String {
                switch self {
                case .error: return "error"
                }
            }
            
            static func == (lhs: AlertType, rhs: AlertType) -> Bool {
                switch (lhs, rhs) {
                case (.error(let lhsError), .error(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Action
    enum Action: Equatable {
        case numberTapped(Int)
        case operationTapped(CalculatorOperation)
        case equalsTapped
        case clearTapped
        case dismissAlert
        
        // Auto clear actions
        case startAutoClearTimer
        case cancelAutoClearTimer
        case autoClearTriggered
        
        // Internal actions
        case displayUpdated(String)
        case errorOccurred(Error)
        case stateUpdated(CalculatorState)
        
        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.numberTapped(let lhsValue), .numberTapped(let rhsValue)):
                return lhsValue == rhsValue
            case (.operationTapped(let lhsOp), .operationTapped(let rhsOp)):
                return lhsOp == rhsOp
            case (.equalsTapped, .equalsTapped),
                 (.clearTapped, .clearTapped),
                 (.dismissAlert, .dismissAlert),
                 (.startAutoClearTimer, .startAutoClearTimer),
                 (.cancelAutoClearTimer, .cancelAutoClearTimer),
                 (.autoClearTriggered, .autoClearTriggered):
                return true
            case (.displayUpdated(let lhsDisplay), .displayUpdated(let rhsDisplay)):
                return lhsDisplay == rhsDisplay
            case (.errorOccurred(let lhsError), .errorOccurred(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.stateUpdated(let lhsState), .stateUpdated(let rhsState)):
                return lhsState == rhsState
            default:
                return false
            }
        }
    }
    
    // MARK: - Dependencies
    @Dependency(\.calculatorUseCase) var calculatorUseCase
    
    // MARK: - Cancellation IDs
    private enum CancelID: Hashable {
        case autoClearTimer
    }
    
    // MARK: - Reducer
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .numberTapped(let digit):
                return handleNumberTapped(digit: digit, state: &state)
                
            case .operationTapped(let operation):
                return handleOperationTapped(operation: operation, state: &state)
                
            case .equalsTapped:
                return handleEqualsTapped(state: &state)
                
            case .clearTapped:
                return handleClearTapped(state: &state)
                
            case .dismissAlert:
                return handleDismissAlert(state: &state)
                
            case .displayUpdated(let newDisplay):
                return handleDisplayUpdated(newDisplay: newDisplay, state: &state)
                
            case .errorOccurred(let error):
                return handleErrorOccurred(error: error, state: &state)
                
            case .stateUpdated(let newState):
                return handleStateUpdated(newState: newState, state: &state)
                
            case .startAutoClearTimer:
                return handleStartAutoClearTimer(state: &state)
                
            case .cancelAutoClearTimer:
                return handleCancelAutoClearTimer(state: &state)
                
            case .autoClearTriggered:
                return handleAutoClearTriggered(state: &state)
            }
        }
    }
    
    // MARK: - Action Handlers
    
    /// 숫자 입력 처리
    private func handleNumberTapped(digit: Int, state: inout State) -> Effect<Action> {
        .run { [currentState = state.calculatorState] send in
            // 자동 클리어 타이머 취소 (새로운 입력이 들어왔으므로)
            await send(.cancelAutoClearTimer)
            
            do {
                let newState = try calculatorUseCase.inputNumber(digit, currentState: currentState)
                await send(.stateUpdated(newState))
            } catch {
                await send(.errorOccurred(error))
            }
        }
    }
    
    /// 연산자 입력 처리
    private func handleOperationTapped(operation: CalculatorOperation, state: inout State) -> Effect<Action> {
        .run { [currentState = state.calculatorState] send in
            // 자동 클리어 타이머 취소 (새로운 연산이 들어왔으므로)
            await send(.cancelAutoClearTimer)
            
            do {
                let newState = try calculatorUseCase.setOperation(operation, currentState: currentState)
                await send(.stateUpdated(newState))
            } catch {
                await send(.errorOccurred(error))
            }
        }
    }
    
    /// 계산 실행 처리
    private func handleEqualsTapped(state: inout State) -> Effect<Action> {
        .run { [currentState = state.calculatorState] send in
            do {
                let newState = try calculatorUseCase.calculate(currentState: currentState)
                await send(.stateUpdated(newState))
                // 계산 완료 후 자동 클리어 타이머 시작
                await send(.startAutoClearTimer)
            } catch {
                await send(.errorOccurred(error))
            }
        }
    }
    
    /// 수동 클리어 처리
    private func handleClearTapped(state: inout State) -> Effect<Action> {
        .run { send in
            // 수동 클리어 시 자동 클리어 타이머 취소
            await send(.cancelAutoClearTimer)
            
            let newState = calculatorUseCase.clear()
            await send(.stateUpdated(newState))
        }
    }
    
    /// 알림 닫기 처리
    private func handleDismissAlert(state: inout State) -> Effect<Action> {
        state.activeAlert = nil
        return .none
    }
    
    /// 디스플레이 업데이트 처리
    private func handleDisplayUpdated(newDisplay: String, state: inout State) -> Effect<Action> {
        state.display = newDisplay
        return .none
    }
    
    /// 에러 발생 처리
    private func handleErrorOccurred(error: Error, state: inout State) -> Effect<Action> {
        state.activeAlert = .error(error)
        // 오류 발생 시 초기화
        let clearedState = calculatorUseCase.clear()
        state.calculatorState = clearedState
        state.display = clearedState.display
        return .none
    }
    
    /// 계산기 상태 업데이트 처리
    private func handleStateUpdated(newState: CalculatorState, state: inout State) -> Effect<Action> {
        state.calculatorState = newState
        state.display = newState.display
        return .none
    }
    
    /// 자동 클리어 타이머 시작 처리
    private func handleStartAutoClearTimer(state: inout State) -> Effect<Action> {
        state.isAutoClearTimerActive = true
        return .run { send in
            // 5초 후에 자동 클리어 실행
            try await Task.sleep(for: .seconds(5))
            await send(.autoClearTriggered)
        }
        .cancellable(id: CancelID.autoClearTimer)
    }
    
    /// 자동 클리어 타이머 취소 처리
    private func handleCancelAutoClearTimer(state: inout State) -> Effect<Action> {
        state.isAutoClearTimerActive = false
        return .cancel(id: CancelID.autoClearTimer)
    }
    
    /// 자동 클리어 실행 처리
    private func handleAutoClearTriggered(state: inout State) -> Effect<Action> {
        state.isAutoClearTimerActive = false
        let newState = calculatorUseCase.clear()
        state.calculatorState = newState
        state.display = newState.display
        return .none
    }
}

// MARK: - Dependencies

private enum CalculatorUseCaseKey: DependencyKey {
    static let liveValue: CalculatorUseCaseProtocol = CalculatorUseCase()
}

extension DependencyValues {
    var calculatorUseCase: CalculatorUseCaseProtocol {
        get { self[CalculatorUseCaseKey.self] }
        set { self[CalculatorUseCaseKey.self] = newValue }
    }
} 
