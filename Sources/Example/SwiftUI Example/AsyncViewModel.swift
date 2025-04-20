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
/// Input -> Action -> ViewModel 속성 업데이트 흐름으로 데이터가 처리됩니다.
/// ViewModel은 ObservableObject를 준수하여 속성 변경 시 View에 자동으로 알림을 전달합니다.
@MainActor
protocol AsyncViewModel: ObservableObject {
    associatedtype Input
    associatedtype Action

    /// 입력 이벤트를 전송하여 처리를 시작합니다.
    /// - Parameter input: 처리할 입력 이벤트
    func send(_ input: Input)
    
    /// 입력을 액션으로 변환합니다.
    /// - Parameter input: 변환할 입력 이벤트
    /// - Returns: 수행할 액션 배열
    /// - Note: nonisolated로 표시되어 메인 스레드가 아닌 백그라운드 스레드에서 실행될 수 있습니다.
    ///         이는 성능 최적화를 위한 것으로, UI를 직접 업데이트하지 않는 순수 변환 작업이기 때문입니다.
    nonisolated func transform(_ input: Input) async -> [Action]
    
    /// 액션을 수행하여 ViewModel의 상태를 업데이트합니다.
    /// - Parameter action: 수행할 액션
    /// - Throws: 액션 수행 중 발생할 수 있는 오류
    /// - Note: 메인 스레드에서 실행되어 UI 상태를 안전하게 업데이트합니다.
    func perform(_ action: Action) async throws
    
    /// 오류를 처리합니다.
    /// - Parameter error: 처리할 오류
    /// - Note: 메인 스레드에서 실행되어 UI 관련 오류 처리를 안전하게 수행합니다.
    func handleError(_ error: Error) async
}

extension AsyncViewModel {
    /// 입력을 처리하는 기본 메서드
    /// - Parameter input: 처리할 입력 이벤트
    func send(_ input: Input) {
        Task { [weak self] in
            guard let self = self else { return }
            
            // Input을 Action으로 변환
            let actions = await self.transform(input)
            
            // 각 Action 순차적으로 처리
            for action in actions {
                do {
                    try await self.perform(action)
                } catch {
                    await self.handleError(error)
                }
            }
        }
    }
    
    /// 에러 처리를 위한 기본 구현 (필요시 오버라이드)
    /// - Parameter error: 처리할 오류
    func handleError(_ error: Error) async {
        print("AsyncViewModel error: \(error.localizedDescription)")
    }
}
