//
//  Publisher + Extension.swift
//  Tablet
//
//  Created by 정준영 on 3/27/24.
//

import Combine
import UIKit

extension Publisher {
    func withUnretained<T: AnyObject>(_ object: T) -> Publishers.CompactMap<Self, (T, Self.Output)> {
        compactMap { [weak object] output in
            guard let object else { return nil }
            return (object, output)
        }
    }
    
    func sink<T: AnyObject>(
        with owner: T,
        receiveCompletion: @escaping (_ owner: T, _ error: Subscribers.Completion<Self.Failure>) -> Void,
        receiveValue: @escaping (_ owner: T, _ output: Self.Output) -> Void
    ) -> AnyCancellable {
        return self.sink(
            receiveCompletion: { [weak owner] completion in
                guard let owner = owner else { return }
                receiveCompletion(owner, completion)
            },
            receiveValue: { [weak owner] value in
                guard let owner = owner else { return }
                receiveValue(owner, value)
            }
        )
    }
}

extension Publisher where Self.Failure == Never {
    func sink<T: AnyObject>(
        with owner: T,
        _ receiveValue: @escaping (_ owner: T, _ output: Self.Output) -> Void
    ) -> AnyCancellable {
        return self.sink { [weak owner] value in
            guard let owner = owner else { return }
            receiveValue(owner, value)
        }
    }
}

extension Publisher where Failure == Never {
    
    func bind(on object: UIButton, to keyPath: WritableKeyPath<UIButton.Configuration, Output?>) -> AnyCancellable {
        sink { [weak object] value in
            object?.configuration?[keyPath: keyPath] = value
        }
    }
    
    func bind(on object: UIButton, to keyPath: WritableKeyPath<UIButton.Configuration, Output>) -> AnyCancellable {
        sink { [weak object] value in
            object?.configuration?[keyPath: keyPath] = value
        }
    }
    
    func bind<Root: AnyObject>(on object: Root, to keyPath: ReferenceWritableKeyPath<Root, Output?>) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
    
    func bind<Root: AnyObject>( on object: Root, to keyPath: ReferenceWritableKeyPath<Root, Output>) -> AnyCancellable {
        sink { [weak object] value in
            object?[keyPath: keyPath] = value
        }
    }
}
