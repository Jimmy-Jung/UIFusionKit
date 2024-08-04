//
//  ExampleViewModel.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine

enum ExampleViewModelInput {
    case viewDidLoad
    case buttonTap
}

enum ExampleViewModelAction {
    case changeLabelText
    case changeButtonText
    case changeButtonColor
    case increaseButtonCount
    case changeButtonHeight
}

final class ExampleViewModelState {
    @Published var buttonCount: Int
    @Published var labelText: String?
    @Published var buttonText: String?
    @Published var buttonColor: UIColor?
    @Published var buttonFrame: (width: CGFloat?, height: CGFloat?)
    
    init() {
        self.buttonCount = 0
        self.labelText = "hello"
        self.buttonText = "Button"
        self.buttonColor = .systemGray
        self.buttonFrame = (180, 50)
    }
}

protocol ExampleViewModel: ViewModelProtocol where
    Input == ExampleViewModelInput,
    Action == ExampleViewModelAction,
    State == ExampleViewModelState {}

final class DefaultExampleViewModel: ExampleViewModel {
    var state: State = .init()
    var cancellables: Set<AnyCancellable> = .init()
    
    func transform(_ input: Input) -> [Action] {
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
    
    func perform(_ action: Action) {
        switch action {
            case .increaseButtonCount:
                state.buttonCount += 1
                
            case .changeLabelText:
                state.labelText = "Button tapped \(state.buttonCount)"
                
            case .changeButtonText:
                state.buttonText = "Button Tapped: \(state.buttonCount)"
            
            case .changeButtonColor:
                state.buttonColor = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink].randomElement()!
                
            case .changeButtonHeight:
                state.buttonFrame = state.buttonCount % 2 == 0 ? (180, 50) : (200, 80)
        }
    }
}
