//
//  AsyncViewModel.swift
//  Shared
//
//  Created by 정준영 on 2025/4/20.
//

import Foundation

// MARK: - AsyncViewModel Protocol

/// 개선된 비동기 작업을 처리하는 ViewModel 프로토콜
///
/// 단방향 데이터 흐름을 위한 비동기 방식의 ViewModel입니다.
/// Input -> Action -> Reduce -> State 업데이트 + Effect 흐름으로 데이터가 처리됩니다.
@MainActor
public protocol AsyncViewModel: ObservableObject {
    associatedtype Input
    associatedtype Action: Equatable
    associatedtype State: Equatable
    associatedtype CancelID: Hashable
    
    /// 현재 상태
    var state: State { get set }
    
    /// 진행 중인 작업을 관리하는 딕셔너리
    var tasks: [AnyHashable: Task<Void, Never>] { get set }
    
    /// 입력 이벤트를 전송하여 처리를 시작합니다.
    func send(_ input: Input)
    
    /// 입력을 Action으로 변환합니다. (동기)
    func transform(_ input: Input) -> [Action]
    
    /// 순수 함수로 상태를 변경하고 부수 효과를 반환합니다.
    func reduce(state: inout State, action: Action) -> [AsyncEffect<Action>]
    
    /// 에러 처리를 위한 메서드
    func handleError(_ error: Error)
}

// MARK: - Improved AsyncEffect

/// ViewModel에서 반환할 수 있는 효과(Effect)를 정의합니다.
public enum AsyncEffect<Action: Equatable>: Equatable {
    /// 아무것도 하지 않습니다.
    case none
    /// 일반적인 액션을 실행합니다.
    case action(Action)
    /// 비동기 작업을 실행합니다.
    case run(id: AnyHashable? = nil, operation: AsyncOperation<Action>)
    /// 특정 ID를 가진 작업을 취소합니다.
    case cancel(id: AnyHashable)
    /// 여러 Effect를 병합합니다.
    case merge([AsyncEffect<Action>])
    
    public static func == (lhs: AsyncEffect<Action>, rhs: AsyncEffect<Action>) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.action(let lhsAction), .action(let rhsAction)):
            return lhsAction == rhsAction
        case (.run(let lhsId, _), .run(let rhsId, _)):
            return lhsId == rhsId
        case (.cancel(let lhsId), .cancel(let rhsId)):
            return lhsId == rhsId
        case (.merge(let lhsEffects), .merge(let rhsEffects)):
            return lhsEffects == rhsEffects
        default:
            return false
        }
    }
}

// MARK: - AsyncOperation

/// 비동기 작업을 감싸는 구조체
public struct AsyncOperation<Action: Equatable>: Equatable {
    public let id = UUID()
    private let _operation: @Sendable () async -> AsyncOperationResult<Action>
    
    public init(operation: @escaping @Sendable () async -> AsyncOperationResult<Action>) {
        self._operation = operation
    }
    
    public func callAsFunction() async -> AsyncOperationResult<Action> {
        await _operation()
    }
    
    public static func == (lhs: AsyncOperation<Action>, rhs: AsyncOperation<Action>) -> Bool {
        lhs.id == rhs.id
    }
}

/// 비동기 작업의 결과
public enum AsyncOperationResult<Action: Equatable>: Equatable {
    case action(Action)
    case actions([Action])
    case none
    case error(Error)
    
    public static func == (lhs: AsyncOperationResult<Action>, rhs: AsyncOperationResult<Action>) -> Bool {
        switch (lhs, rhs) {
        case (.action(let lhsAction), .action(let rhsAction)):
            return lhsAction == rhsAction
        case (.actions(let lhsActions), .actions(let rhsActions)):
            return lhsActions == rhsActions
        case (.none, .none):
            return true
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

// MARK: - Default Implementation

public extension AsyncViewModel {
    /// 입력을 처리하는 개선된 메서드
    func send(_ input: Input) {
        let actions = transform(input)
        
        for action in actions {
            perform(action)
        }
    }
    
    /// 액션을 직접 처리하는 메서드
    func perform(_ action: Action) {
        let effects = reduce(state: &state, action: action)
        
        for effect in effects {
            Task { [weak self] in
                await self?.handleEffect(effect)
            }
        }
    }
    
    private func handleEffect(_ effect: AsyncEffect<Action>) async {
        switch effect {
        case .none:
            break
            
        case .action(let action):
            await MainActor.run {
                perform(action)
            }
            
        case .run(let id, let operation):
            // 기존 작업이 있다면 취소
            if let id = id {
                tasks[id]?.cancel()
            }
            
            let task = Task {
                let result = await operation()
                
                await MainActor.run { [weak self] in
                    switch result {
                    case .action(let action):
                        self?.perform(action)
                    case .actions(let actions):
                        actions.forEach { self?.perform($0) }
                    case .none:
                        break
                    case .error(let error):
                        self?.handleError(error)
                    }
                }
            }
            
            if let id = id {
                tasks[id] = task
                
                Task {
                    await task.value
                    await MainActor.run { [weak self] in
                        self?.tasks[id] = nil
                    }
                }
            }
            
        case .cancel(let id):
            tasks[id]?.cancel()
            tasks[id] = nil
            
        case .merge(let effects):
            for effect in effects {
                await handleEffect(effect)
            }
        }
    }
    
    /// 에러 처리를 위한 기본 구현
    func handleError(_ error: Error) {
        print("AsyncViewModel error: \(error.localizedDescription)")
    }
}

// MARK: - Convenience Extensions

public extension AsyncEffect {
    /// 여러 Effect를 병합하는 편의 메서드
    static func merge(_ effects: AsyncEffect<Action>...) -> AsyncEffect<Action> {
        return .merge(effects)
    }
    
    /// 단일 액션을 반환하는 비동기 작업을 실행하는 편의 메서드
    static func runAction(
        id: AnyHashable? = nil,
        operation: @escaping @Sendable () async throws -> Action
    ) -> AsyncEffect<Action> {
        return .run(id: id, operation: AsyncOperation { () async -> AsyncOperationResult<Action> in
            do {
                let action = try await operation()
                return .action(action)
            } catch {
                return .error(error)
            }
        })
    }
    
    /// 여러 액션을 반환하는 비동기 작업을 실행하는 편의 메서드
    static func runActions(
        id: AnyHashable? = nil,
        operation: @escaping @Sendable () async throws -> [Action]
    ) -> AsyncEffect<Action> {
        return .run(id: id, operation: AsyncOperation { () async -> AsyncOperationResult<Action> in
            do {
                let actions = try await operation()
                return .actions(actions)
            } catch {
                return .error(error)
            }
        })
    }
}

// MARK: - Test Support

/// 테스트를 위한 AsyncViewModel 스토어
@MainActor
public class AsyncTestStore<ViewModel: AsyncViewModel> {
    public let viewModel: ViewModel
    private var receivedActions: [ViewModel.Action] = []
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    /// 액션을 ViewModel에 직접 전달합니다.
    public func perform(_ action: ViewModel.Action) {
        receivedActions.append(action)
        viewModel.perform(action)
    }
    
    /// 입력을 ViewModel에 직접 전달합니다.
    public func send(_ input: ViewModel.Input) {
        viewModel.send(input)
    }
    
    /// 현재 상태를 반환합니다.
    public var state: ViewModel.State {
        viewModel.state
    }
    
    /// 직접 perform을 통해 전달된 액션들을 반환합니다.
    public var actions: [ViewModel.Action] {
        receivedActions
    }
    
    /// 특정 상태가 되기를 기다립니다.
    public func wait(for predicate: @escaping (ViewModel.State) -> Bool, timeout: TimeInterval = 1.0) async throws {
        let startTime = Date()
        
        while !predicate(state) {
            if Date().timeIntervalSince(startTime) > timeout {
                throw TestError.timeout
            }
            try await Task.sleep(for: .milliseconds(10))
        }
    }
    
    public enum TestError: Error {
        case timeout
        case unexpectedState
        case unexpectedAction
    }
}

// MARK: - Mock Helper

/// 테스트용 Mock을 쉽게 만들기 위한 헬퍼
public protocol MockSupport {
    static var mock: Self { get }
}
