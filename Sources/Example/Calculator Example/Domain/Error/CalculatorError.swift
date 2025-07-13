//
//  CalculatorError.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Foundation

// 계산기 도메인에서 발생할 수 있는 에러 정의
public enum CalculatorError: Error, LocalizedError, Equatable {
    case divisionByZero
    case invalidOperation
    case overflow
    case invalidInput
    
    public var errorDescription: String? {
        switch self {
        case .divisionByZero:
            return "0으로 나눌 수 없습니다"
        case .invalidOperation:
            return "잘못된 연산입니다"
        case .overflow:
            return "계산 결과가 너무 큽니다"
        case .invalidInput:
            return "잘못된 입력입니다"
        }
    }
} 