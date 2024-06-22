//
//  ReactorViewModel.swift
//
//
//  Created by 정준영 on 2024/6/21.
//

import UIKit
import Combine

public enum ReactorViewModelInput {
    case viewDidLoad
    case buttonTap
}

public enum ReactorViewModelMutation {
    case changeLabelText
    case changeButtonText
    case changeButtonColor
    case increaseButtonCount
    case changeButtonHeight
}

public class ReactorViewModelOutput {
    @Published var buttonCount: Int
    @Published var labelText: String
    @Published var buttonText: String
    @Published var buttonColor: UIColor
    @Published var buttonFrame: (width: CGFloat?, height: CGFloat?)
    
    init() {
        self.buttonCount = 0
        self.labelText = "hello"
        self.buttonText = "Button"
        self.buttonColor = .systemGray
        self.buttonFrame = (nil, 50)
    }
}

public protocol ReactorViewModel: ViewModelProtocol where
    Input == ReactorViewModelInput,
    Mutation == ReactorViewModelMutation,
    Output == ReactorViewModelOutput {}

public final class DefaultReactorViewModel: ReactorViewModel {
    public let input: PassthroughSubject<Input, Never> = .init()
    public var output: Output = Output()
    public var cancellables: Set<AnyCancellable> = .init()
    public init() {
        bind()
    }
    
    public func input(_ send: Input) {
        self.input.send(send)
    }
    
    public func mutate(input: Input) -> AnyPublisher<Mutation, Never> {
        switch input {
            case .viewDidLoad:
                return Just(Mutation.changeLabelText)
                    .append(Mutation.changeButtonText)
                    .eraseToAnyPublisher()
            case .buttonTap:
                return Just(Mutation.increaseButtonCount)
                    .append(Just(Mutation.changeButtonColor))
                    .append(Just(Mutation.changeButtonText))
                    .append(Just(Mutation.changeLabelText))
                    .append(Just(Mutation.changeButtonHeight))
                    .eraseToAnyPublisher()
        }
    }
    
    public func transform(output: Output, mutation: Mutation) -> ReactorViewModelOutput {
        switch mutation {
            case .increaseButtonCount:
                output.buttonCount += 1
                return output
                
            case .changeLabelText:
                output.labelText = "Button tapped \(output.buttonCount)"
                return output
                
            case .changeButtonText:
                output.buttonText = "Button Tapped: \(output.buttonCount)"
                return output
            
            case .changeButtonColor:
                output.buttonColor = [.systemRed, .systemBlue, .systemGreen, .systemYellow, .systemPink].randomElement()!
                return output
                
            case .changeButtonHeight:
                output.buttonFrame = output.buttonCount % 2 == 0 ? (nil, 50) : (nil, 100)
                return output
                
        }
    }
}
