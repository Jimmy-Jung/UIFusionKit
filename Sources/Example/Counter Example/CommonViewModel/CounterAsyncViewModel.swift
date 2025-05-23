//
//  CounterAsyncViewModel.swift
//
//
//  Created by 정준영 on 2024/8/4.
//

import SwiftUI
import Foundation

// 카운터 앱에서 발생할 수 있는 에러 정의
enum CounterError: Error, LocalizedError {
    case valueOutOfRange(current: Int, min: Int, max: Int)
    case invalidOperation(description: String)
    
    var errorDescription: String? {
        switch self {
        case .valueOutOfRange(let current, let min, let max):
            return "값이 허용 범위를 벗어났습니다 (현재: \(current), 범위: \(min)~\(max))"
        case .invalidOperation(let description):
            return "잘못된 작업: \(description)"
        }
    }
}

final class CounterAsyncViewModel: AsyncViewModel {
    
    // 알림 타입을 정의하는 enum
    enum AlertType: Identifiable {
        case none
        case info
        case error(Error)
        
        var id: String {
            switch self {
            case .none: return "none"
            case .info: return "info"
            case .error: return "error"
            }
        }
    }
    
    // 버튼 로딩 상태를 추적하기 위한 enum
    enum LoadingState {
        case none
        case increasing
        case decreasing
    }
    
    enum Input {
        case increase
        case decrease
        case reset
        case show
        case dismissAlert
    }

    enum Action {
        case increaseValue
        case decreaseValue
        case resetValue
        case showAlert
        case dismissAlert
    }
    
    // 속성 정의
    @Published var value: Int = 0
    @Published var activeAlert: AlertType?
    @Published var loadingState: LoadingState = .none
    
    // 값의 허용 범위
    private let minValue = -10
    private let maxValue = 10
    
    init() {}
    
    func transform(_ input: Input) async -> [Action] {
        switch input {
            case .increase: return [.increaseValue]
            case .decrease: return [.decreaseValue]
            case .reset: return [.resetValue]
            case .show: return [.showAlert]
            case .dismissAlert: return [.dismissAlert]
        }
    }
    
    func perform(_ action: Action) async throws {
        switch action {
            case .increaseValue:
                try await increaseValue()
            case .decreaseValue:
                try await decreaseValue()
            case .resetValue:
                try await resetValue()
            case .showAlert:
                try await showAlert()
            case .dismissAlert:
                dismissAlert()
                
        }
    }
    
    private func dismissAlert() {
        activeAlert = nil
    }
    // 값을 증가시키는 메서드
    private func increaseValue() async throws {
        // 로딩 상태 설정
        loadingState = .increasing
        
        // 0.5초 딜레이
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let newValue = value + 1
        if newValue > maxValue {
            loadingState = .none
            throw CounterError.valueOutOfRange(current: newValue, min: minValue, max: maxValue)
        }
        value = newValue
        
        // 로딩 상태 초기화
        loadingState = .none
    }
    
    // 값을 감소시키는 메서드
    private func decreaseValue() async throws {
        // 로딩 상태 설정
        loadingState = .decreasing
        
        // 0.5초 딜레이
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let newValue = value - 1
        if newValue < minValue {
            loadingState = .none
            throw CounterError.valueOutOfRange(current: newValue, min: minValue, max: maxValue)
        }
        value = newValue
        
        // 로딩 상태 초기화
        loadingState = .none
    }
    
    // 값을 리셋하는 메서드
    private func resetValue() async throws {
        value = 0
    }
    
    // 알림을 표시하는 메서드
    private func showAlert() async throws {
        activeAlert = .info
    }
    
    func handleError(_ error: Error) async {
        loadingState = .none
        activeAlert = .error(error)
        print("카운터 오류: \(error.localizedDescription)")
    }
}
