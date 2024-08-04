//
//  CounterViewModel.swift
//
//
//  Created by 정준영 on 2024/8/4.
//

import Combine

enum CounterInput {
    case increase
    case decrease
    case reset
    case show
}

enum CounterAction {
    case increaseValue
    case decreaseValue
    case resetValue
    case showAlert
}

class CounterState: ObservableObject {
    @Published var value: Int = 0
    @Published var isReset: Bool = false
    @Published var showAlert: Void = ()
}

protocol CounterViewModel: ViewModelProtocol where
Input == CounterInput,
Action == CounterAction,
State == CounterState {}

final class DefaultCounterViewModel: CounterViewModel {
    @Published var state: State = .init()
    var cancellabels: Set<AnyCancellable> = .init()
    
    
    func transform(_ input: Input) -> [Action] {
        switch input {
            case .increase:
                return [.increaseValue]
            case .decrease:
                return [.decreaseValue]
            case .reset:
                return [.resetValue]
            case .show:
                return [.showAlert]
        }
    }
    
    func perform(_ action: Action) {
        switch action {
            case .increaseValue:
                state.value += 1
                state.isReset = false
            case .decreaseValue:
                state.value -= 1
                state.isReset = false
            case .resetValue:
                state.value = 0
                state.isReset = true
            case .showAlert:
                state.showAlert = ()
        }
    }
}
