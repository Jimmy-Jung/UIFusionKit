//
//  CalculatorOperation.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import Foundation

// 계산기 연산자를 나타내는 Entity
public enum CalculatorOperation: String, CaseIterable, Equatable {
    case add = "+"
    case subtract = "-"
    case multiply = "×"
    case divide = "÷"
    
    // 연산 수행
    public func calculate(_ lhs: Double, _ rhs: Double) throws -> Double {
        switch self {
        case .add:
            return lhs + rhs
        case .subtract:
            return lhs - rhs
        case .multiply:
            return lhs * rhs
        case .divide:
            if rhs == 0 {
                throw CalculatorError.divisionByZero
            }
            return lhs / rhs
        }
    }
    
    // 연산자 우선순위 (향후 확장을 위해)
    public var precedence: Int {
        switch self {
        case .add, .subtract:
            return 1
        case .multiply, .divide:
            return 2
        }
    }
} 