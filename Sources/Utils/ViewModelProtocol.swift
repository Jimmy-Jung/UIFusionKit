//
//  ViewModelProtocol.swift
//
//
//  Created by 정준영 on 2024/6/22.
//

import Combine
import Foundation

public protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Mutation = Input
    associatedtype Output
    
    var input: PassthroughSubject<Input, Never> { get }
    var output: Output { get set }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func mutate(input: Input) -> AnyPublisher<Mutation, Never>
    func transform(output: Output, mutation: Mutation) -> Output
}

public extension ViewModelProtocol {
    
    func bind() {
        input
            .flatMap { [weak self] input -> AnyPublisher<Mutation, Never> in
                guard let self else { return Empty().eraseToAnyPublisher() }
                return self.mutate(input: input)
                    .eraseToAnyPublisher()
            }
            .scan(output) { [weak self] output, mutation -> Output in
                guard let self else { return output }
                return self.transform(output: output, mutation: mutation)
            }
            .withUnretained(self)
            .sink { owner, output in
                owner.output = output
            }
            .store(in: &cancellables)
    }
    
    func mutate(input: Input) -> AnyPublisher<Mutation, Never> {
        return Empty().eraseToAnyPublisher()
    }
    
    func transform(output: Output, mutation: Mutation) -> Output {
        return output
    }
}
