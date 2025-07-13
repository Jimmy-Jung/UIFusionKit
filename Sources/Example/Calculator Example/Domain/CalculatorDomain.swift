//
//  CalculatorDomain.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Foundation

// MARK: - Domain Module Interface

/// Calculator Domain 모듈의 공개 인터페이스
/// 
/// 이 파일은 Calculator Domain 계층의 모든 public 타입들을 
/// 외부 계층(Presentation, Data)에서 쉽게 사용할 수 있도록 
/// 하나의 import로 접근 가능하게 만드는 역할을 합니다.
///
/// ## 역할
/// 1. **모듈 인터페이스 제공**: Domain 계층의 모든 타입을 한 곳에서 관리
/// 2. **의존성 관리**: 외부에서 접근 가능한 Domain API 명시
/// 3. **편의성 제공**: 여러 파일에 분산된 타입들을 하나의 네임스페이스로 통합
///
/// ## 사용 예시
/// ```swift
/// // Presentation Layer에서
/// let useCase: CalculatorUseCaseProtocol = CalculatorUseCase()
/// let state = CalculatorState.initial
/// let operation = CalculatorOperation.add
/// ```
///
/// ## 포함된 타입들
/// - **Entity**: CalculatorState, CalculatorOperation
/// - **UseCase**: CalculatorUseCaseProtocol, CalculatorUseCase  
/// - **Error**: CalculatorError
public enum CalculatorDomain {
    // 이 enum은 네임스페이스 역할만 하며 인스턴스를 생성할 수 없습니다.
    
    /// Domain 계층의 버전 정보
    public static let version = "1.0.0"
    
    /// Domain 계층에서 지원하는 연산자 목록
    public static let supportedOperations = CalculatorOperation.allCases
} 