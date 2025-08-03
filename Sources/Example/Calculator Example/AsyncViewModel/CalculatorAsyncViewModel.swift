//
//  CalculatorAsyncViewModel.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Foundation
import SwiftUI

extension CalculatorAsyncViewModel {

    enum Input {
        case number(Int)
        case operation(CalculatorOperation)
        case equals
        case clear
        case dismissAlert
    }

    enum Action: Equatable {
        case inputNumber(Int)
        case setOperation(CalculatorOperation)
        case calculate
        case clearAll
        case dismissAlert
        case autoClear
        case setTimerActive(Bool)
        case errorOccurred(Error)
        case stateUpdated(CalculatorState)
        case displayUpdated(String)

        static func == (lhs: Action, rhs: Action) -> Bool {
            switch (lhs, rhs) {
            case (.inputNumber(let lhsValue), .inputNumber(let rhsValue)):
                return lhsValue == rhsValue
            case (.setOperation(let lhsOp), .setOperation(let rhsOp)):
                return lhsOp == rhsOp
            case (.calculate, .calculate),
                (.clearAll, .clearAll),
                (.dismissAlert, .dismissAlert),
                (.autoClear, .autoClear):
                return true
            case (.setTimerActive(let lhsValue), .setTimerActive(let rhsValue)):
                return lhsValue == rhsValue
            case (.errorOccurred(let lhsError), .errorOccurred(let rhsError)):
                return lhsError.localizedDescription == rhsError.localizedDescription
            case (.stateUpdated(let lhsState), .stateUpdated(let rhsState)):
                return lhsState == rhsState
            case (.displayUpdated(let lhsDisplay), .displayUpdated(let rhsDisplay)):
                return lhsDisplay == rhsDisplay
            default:
                return false
            }
        }
    }
    
    public struct State: Equatable {
        var display: String = "0"
        var activeAlert: AlertType?
        var calculatorState: CalculatorState = .initial
        var isAutoClearTimerActive: Bool = false

        // 알림 타입을 정의하는 enum
        enum AlertType: Identifiable, Equatable {
            case error(Error)
            var id: String { "error" }

            static func == (lhs: AlertType, rhs: AlertType) -> Bool {
                switch (lhs, rhs) {
                case (.error(let lhsError), .error(let rhsError)):
                    return lhsError.localizedDescription == rhsError.localizedDescription
                }
            }
        }
    }

    enum CancelID: Hashable {
        case autoClearTimer
    }
}

// MARK: - Improved CalculatorAsyncViewModel
final class CalculatorAsyncViewModel: AsyncViewModel {

    // MARK: - Properties
    @Published var state: State
    var tasks: [AnyHashable: Task<Void, Never>] = [:]

    // MARK: - Dependencies
    private let calculatorUseCase: CalculatorUseCaseProtocol

    // MARK: - Computed Properties for SwiftUI Binding
    var display: String { state.display }
    var activeAlert: State.AlertType? { state.activeAlert }
    var isAutoClearTimerActive: Bool { state.isAutoClearTimerActive }

    // MARK: - Initialization
    init(
        initialState: State = State(),
        calculatorUseCase: CalculatorUseCaseProtocol = CalculatorUseCase()
    ) {
        self.state = initialState
        self.calculatorUseCase = calculatorUseCase
    }

    // MARK: - AsyncViewModel Protocol Implementation
    func transform(_ input: Input) -> [Action] {
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

    // MARK: - Reducer Implementation
    func reduce(state: inout State, action: Action) -> [AsyncEffect<
        Action
    >] {
        switch action {
        case .inputNumber(let digit):
            let currentCalculatorState = state.calculatorState
            return [
                .cancel(id: CancelID.autoClearTimer),
                .action(.setTimerActive(false)),
                .runAction(operation: { [calculatorUseCase] in
                    do {
                        let newState = try calculatorUseCase.inputNumber(
                            digit,
                            currentState: currentCalculatorState
                        )
                        return .stateUpdated(newState)
                    } catch {
                        return .errorOccurred(error)
                    }
                }),
            ]

        case .setOperation(let operation):
            return [
                .cancel(id: CancelID.autoClearTimer),
                .action(.setTimerActive(false)),
                .runAction(operation: { [calculatorUseCase, currentCalculatorState = state.calculatorState] in
                    do {
                        let newState = try calculatorUseCase.setOperation(
                            operation,
                            currentState: currentCalculatorState
                        )
                        return .stateUpdated(newState)
                    } catch {
                        return .errorOccurred(error)
                    }
                }),
            ]

        case .calculate:
            return [
                .action(.setTimerActive(true)),
                .runAction(operation: { [calculatorUseCase, currentCalculatorState = state.calculatorState] in
                    do {
                        let newState = try calculatorUseCase.calculate(
                            currentState: currentCalculatorState
                        )
                        return .stateUpdated(newState)
                    } catch {
                        return .errorOccurred(error)
                    }
                }),
                .runAction(
                    id: CancelID.autoClearTimer,
                    operation: {
                        try await Task.sleep(for: .seconds(5))
                        return .autoClear
                    }
                ),
            ]

        case .clearAll:
            let newState = calculatorUseCase.clear()
            return [
                .cancel(id: CancelID.autoClearTimer),
                .action(.setTimerActive(false)),
                .action(.stateUpdated(newState)),
            ]

        case .dismissAlert:
            state.activeAlert = nil
            return [.none]

        case .autoClear:
            let newState = calculatorUseCase.clear()
            return [
                .action(.setTimerActive(false)),
                .action(.stateUpdated(newState)),
            ]

        case .setTimerActive(let isActive):
            state.isAutoClearTimerActive = isActive
            return [.none]

        case .errorOccurred(let error):
            state.activeAlert = .error(error)
            let newState = calculatorUseCase.clear()
            state.calculatorState = newState
            state.display = newState.display
            state.isAutoClearTimerActive = false
            return [.none]

        case .stateUpdated(let newState):
            state.calculatorState = newState
            state.display = newState.display
            return [.none]

        case .displayUpdated(let newDisplay):
            state.display = newDisplay
            return [.none]
        }
    }
    
    func handleError(_ error: Error) {
        perform(.errorOccurred(error))
    }
}
