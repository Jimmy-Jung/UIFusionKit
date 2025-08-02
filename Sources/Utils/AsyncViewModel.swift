//
//  AsyncViewModel.swift
//  Shared
//
//  Created by 정준영 on 2025/4/20.
//

import Foundation

/// 비동기 작업을 처리하는 ViewModel 프로토콜
///
/// 단방향 데이터 흐름을 위한 비동기 방식의 ViewModel입니다.
/// Input -> Action -> Effect -> State 업데이트 흐름으로 데이터가 처리됩니다.
@MainActor
public protocol AsyncViewModel: ObservableObject {
    associatedtype Input
    associatedtype Action: Hashable
    
    /// 진행 중인 작업을 관리하는 딕셔너리.
    var tasks: [AnyHashable: Task<Void, Never>] { get set }
    
    /// 입력 이벤트를 전송하여 처리를 시작합니다.
    func send(_ input: Input)
    
    /// 입력을 Action으로 변환합니다. (동기)
    func transform(_ input: Input) -> [Action]
    
    /// 액션을 수행하고 그 결과로 Effect를 반환합니다. (비동기)
    /// 이 메서드는 에러를 던지지 않고, 에러가 발생하면 `.action(.errorOccurred(error))`와 같은 Effect로 반환해야 합니다.
    func perform(_ action: Action) async -> [AsyncEffect<Action>]
    
    /// 최종적으로 발생한 오류를 처리합니다.
    func handleError(_ error: Error) async
}

/// ViewModel에서 반환할 수 있는 효과(Effect)를 정의합니다.
public enum AsyncEffect<Action: Hashable>: Hashable {
    /// 일반적인 액션을 실행합니다.
    case action(Action)
    /// 취소 가능한 작업을 실행합니다. 동일한 ID로 다른 작업이 실행되면 이전 작업은 취소됩니다.
    case runCancellable(action: Action, id: AnyHashable)
    /// 특정 ID를 가진 작업을 취소합니다.
    case cancel(id: AnyHashable)
}

public extension AsyncViewModel {
    /// 입력을 처리하는 기본 메서드
    func send(_ input: Input) {
        let actions = transform(input)
        
        Task { [weak self] in
            guard let self else { return }
            
            for action in actions {
                let effects = await self.perform(action)
                
                for effect in effects {
                    await self.handleEffect(effect)
                }
            }
        }
    }
    
    private func handleEffect(_ effect: AsyncEffect<Action>) async {
        switch effect {
        case .action(let action):
            let newEffects = await self.perform(action)
            for newEffect in newEffects {
                await self.handleEffect(newEffect)
            }
            
        case .runCancellable(let action, let id):
            tasks[id]?.cancel()
            
            let task = Task {
                let newEffects = await self.perform(action)
                for newEffect in newEffects {
                    await self.handleEffect(newEffect)
                }
            }
            tasks[id] = task
            
            Task {
                await task.value
                tasks[id] = nil
            }

        case .cancel(let id):
            tasks[id]?.cancel()
            tasks[id] = nil
        }
    }
    
    /// 에러 처리를 위한 기본 구현 (필요시 오버라이드)
    func handleError(_ error: Error) async {
        print("AsyncViewModel error: \(error.localizedDescription)")
    }
}
