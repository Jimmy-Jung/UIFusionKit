//
//  AsyncViewModelTests.swift
//  UIFusionKitTests
//
//  Created by 정준영 on 2025/4/21.
//

import Testing
import Foundation
@testable import UIFusionKit

@MainActor
struct AsyncViewModelTests {

    // MARK: - Mock ViewModel Definition
    
    /// 테스트를 위한 `AsyncViewModel`의 구체적인 구현체
    final class MockViewModel: AsyncViewModel {
        
        // MARK: - Associated Types
        enum Input {
            case setValue(Int)
            case triggerActionEffect
            case triggerAsyncEffect(shouldSucceed: Bool)
            case triggerLongRunningTask
            case cancelLongRunningTask
            case triggerMergedEffects
        }
        
        enum Action: Equatable {
            case setValue(Int)
            case subsequentAction
            case asyncTaskCompleted(String)
            case asyncTaskFailed(Error)
            case longRunningTaskStarted
            case longRunningTaskFinished
            case cancelLongRunningTask

            static func == (lhs: Action, rhs: Action) -> Bool {
                switch (lhs, rhs) {
                case (.setValue(let lhsValue), .setValue(let rhsValue)):
                    return lhsValue == rhsValue
                case (.subsequentAction, .subsequentAction):
                    return true
                case (.asyncTaskCompleted(let lhsResult), .asyncTaskCompleted(let rhsResult)):
                    return lhsResult == rhsResult
                case (.asyncTaskFailed(let lhsError), .asyncTaskFailed(let rhsError)):
                    // Note: Comparing errors can be tricky. This is a simplified comparison.
                    return (lhsError as NSError).domain == (rhsError as NSError).domain &&
                           (lhsError as NSError).code == (rhsError as NSError).code
                case (.longRunningTaskStarted, .longRunningTaskStarted):
                    return true
                case (.longRunningTaskFinished, .longRunningTaskFinished):
                    return true
                case (.cancelLongRunningTask, .cancelLongRunningTask):
                    return true
                default:
                    return false
                }
            }
        }
        
        struct State: Equatable {
            var currentValue: Int = 0
            var asyncResult: String?
            var lastError: String?
            var isLongTaskRunning: Bool = false
        }
        
        enum CancelID: Hashable {
            case longRunningTask
        }
        
        // MARK: - Properties
        @Published var state: State
        var tasks: [AnyHashable: Task<Void, Never>] = [:]
        var handleErrorCallCount = 0
        var receivedError: Error?
        
        init(initialState: State = .init()) {
            self.state = initialState
        }

        // MARK: - Transform
        func transform(_ input: Input) -> [Action] {
            switch input {
            case .setValue(let value):
                return [.setValue(value)]
            case .triggerActionEffect:
                return [.setValue(100)]
            case .triggerAsyncEffect(let shouldSucceed):
                if shouldSucceed {
                    return [.setValue(200)]
                } else {
                    return [.setValue(300)]
                }
            case .triggerLongRunningTask:
                return [.longRunningTaskStarted]
            case .cancelLongRunningTask:
                return [.cancelLongRunningTask]
            case .triggerMergedEffects:
                return [.setValue(400)]
            }
        }

        // MARK: - Reduce
        func reduce(state: inout State, action: Action) -> [AsyncEffect<Action>] {
            switch action {
            case .setValue(let value):
                state.currentValue = value
                if value == 100 { return [.action(.subsequentAction)] }
                if value == 200 { return [.runAction { return .asyncTaskCompleted("Success") }] }
                if value == 300 { return [.runAction(id: "failureEffect") { throw MockError.simulatedFailure }] }
                if value == 400 { return [.merge(.action(.subsequentAction), .runAction { return .asyncTaskCompleted("Merged Success") })] }
                return [.none]
                
            case .subsequentAction:
                state.currentValue = 999
                return [.none]
                
            case .asyncTaskCompleted(let result):
                state.asyncResult = result
                return [.none]

            case .asyncTaskFailed(let error):
                state.lastError = error.localizedDescription
                return [.none]
                
            case .longRunningTaskStarted:
                state.isLongTaskRunning = true
                return [.runAction(id: CancelID.longRunningTask) {
                    try await Task.sleep(for: .seconds(2))
                    return .longRunningTaskFinished
                }]
                
            case .longRunningTaskFinished:
                state.isLongTaskRunning = false
                return [.none]
            
            case .cancelLongRunningTask:
                return [.cancel(id: CancelID.longRunningTask)]
            }
        }
        
        func handleError(_ error: Error) {
            handleErrorCallCount += 1
            receivedError = error
            perform(.asyncTaskFailed(error))
        }
    }
    
    enum MockError: Error, LocalizedError {
        case simulatedFailure
        var errorDescription: String? { "Simulated Failure" }
    }

    // MARK: - Test Cases
    @Test("send 호출 시 state가 동기적으로 변경되어야 한다")
    func testSend_updatesStateSynchronously() {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // When
        testStore.send(MockViewModel.Input.setValue(10))
        
        // Then
        #expect(testStore.state.currentValue == 10)
    }
    
    @Test("Action Effect가 올바르게 처리되어야 한다")
    func testActionEffect_triggersSubsequentAction() async throws {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // When
        testStore.send(MockViewModel.Input.triggerActionEffect)
        
        // Then
        try await testStore.wait(for: { $0.currentValue == 999 })
        #expect(testStore.state.currentValue == 999)
    }
    
    @Test("성공적인 비동기 작업 후 state가 변경되어야 한다")
    func testRunEffect_succeedsAndUpdatesState() async throws {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // When
        testStore.send(MockViewModel.Input.triggerAsyncEffect(shouldSucceed: true))
        
        // Then
        try await testStore.wait(for: { $0.asyncResult == "Success" })
        #expect(testStore.state.currentValue == 200)
        #expect(testStore.state.asyncResult == "Success")
    }
    
    @Test("실패하는 비동기 작업 시 handleError가 호출되어야 한다")
    func testRunEffect_failsAndCallsHandleError() async throws {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // 초기 상태 확인
        #expect(testStore.viewModel.handleErrorCallCount == 0)
        #expect(testStore.viewModel.receivedError == nil)
        #expect(testStore.state.lastError == nil)
        
        // When
        testStore.send(MockViewModel.Input.triggerAsyncEffect(shouldSucceed: false))
        
        // Then
        // 동기적으로 state.currentValue가 300으로 변경됨
        #expect(testStore.state.currentValue == 300)
        
        // 비동기 작업이 실패하고 handleError가 호출될 때까지 기다림
        try await testStore.wait(for: { $0.lastError == "Simulated Failure" })
        
        // handleError가 호출되었는지 확인
        #expect(testStore.viewModel.handleErrorCallCount == 1)
        
        // 올바른 에러가 전달되었는지 확인
        let receivedError = testStore.viewModel.receivedError as? MockError
        #expect(receivedError == .simulatedFailure)
        
        // state.lastError가 올바르게 설정되었는지 확인
        #expect(testStore.state.lastError == "Simulated Failure")
    }
    
    @Test("실행 중인 작업을 취소할 수 있어야 한다")
    func testCancelEffect_cancelsRunningTask() async throws {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // When
        testStore.send(MockViewModel.Input.triggerLongRunningTask)
        
        // Then
        // 상태가 변경되고 작업이 시작될 때까지 기다림
        try await testStore.wait(for: { $0.isLongTaskRunning == true })
        #expect(testStore.state.isLongTaskRunning == true)
        
        // 작업이 tasks 딕셔너리에 저장될 때까지 기다림
        try await testStore.wait(for: { _ in 
            testStore.viewModel.tasks[MockViewModel.CancelID.longRunningTask] != nil 
        }, timeout: 1.0)
        #expect(testStore.viewModel.tasks[MockViewModel.CancelID.longRunningTask] != nil)
        
        // When
        testStore.send(MockViewModel.Input.cancelLongRunningTask)
        
        // Then
        try await testStore.wait(for: { _ in testStore.viewModel.tasks[MockViewModel.CancelID.longRunningTask] == nil })
        #expect(testStore.viewModel.tasks[MockViewModel.CancelID.longRunningTask] == nil)
    }
    
    @Test("Merge Effect가 모든 내부 Effect를 실행해야 한다")
    func testMergeEffect_executesAllEffects() async throws {
        // Given
        let testStore = AsyncTestStore(viewModel: MockViewModel())
        
        // When
        testStore.send(MockViewModel.Input.triggerMergedEffects)
        
        // Then
        try await testStore.wait(for: { $0.asyncResult == "Merged Success" })
        #expect(testStore.state.currentValue == 999)
        #expect(testStore.state.asyncResult == "Merged Success")
    }
}
