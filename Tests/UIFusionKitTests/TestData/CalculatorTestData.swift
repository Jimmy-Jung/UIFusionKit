import Foundation

/// 계산기 테스트를 위한 테스트 데이터 구조체
struct CalculatorTestData {
    
    // MARK: - 기본 연산 테스트 케이스
    
    /// 기본 산술 연산 테스트 케이스
    static let basicOperations: [(first: Int, operation: String, second: Int, expected: String)] = [
        (5, "+", 3, "8"),
        (10, "-", 4, "6"),
        (7, "×", 6, "42"),
        (15, "÷", 3, "5"),
        (0, "+", 5, "5"),
        (5, "+", 0, "5"),
        (0, "×", 100, "0"),
        (100, "×", 0, "0"),
        (1, "+", 1, "2"),
        (100, "-", 50, "50")
    ]
    
    /// 큰 숫자 연산 테스트 케이스
    static let largeNumberOperations: [(first: Int, operation: String, second: Int, expected: String)] = [
        (999, "+", 1, "1000"),
        (1000, "-", 1, "999"),
        (123, "×", 456, "56088"),
        (10000, "÷", 100, "100"),
        (9999, "+", 9999, "19998")
    ]
    
    /// 소수점 결과가 예상되는 연산 테스트 케이스
    static let decimalResultOperations: [(first: Int, operation: String, second: Int, expectedContains: [String])] = [
        (10, "÷", 4, ["2.5", "2,5"]),
        (1, "÷", 3, ["0.33", "0,33"]),
        (7, "÷", 2, ["3.5", "3,5"]),
        (5, "÷", 8, ["0.625", "0,625"])
    ]
    
    // MARK: - 연속 계산 테스트 케이스
    
    /// 연속 계산 시나리오
    struct ChainedCalculation {
        let steps: [(operation: String?, number: Int)]
        let expectedIntermediateResults: [String]
        let finalResult: String
        let description: String
    }
    
    static let chainedCalculations: [ChainedCalculation] = [
        ChainedCalculation(
            steps: [(nil, 5), ("+", 3), ("×", 2)],
            expectedIntermediateResults: ["5", "8", "16"],
            finalResult: "16",
            description: "5 + 3 = 8, 그 다음 × 2 = 16"
        ),
        ChainedCalculation(
            steps: [(nil, 100), ("-", 25), ("+", 10), ("×", 2), ("÷", 5)],
            expectedIntermediateResults: ["100", "75", "85", "170", "34"],
            finalResult: "34",
            description: "100 - 25 + 10 × 2 ÷ 5 = 34"
        ),
        ChainedCalculation(
            steps: [(nil, 2), ("×", 3), ("+", 4), ("÷", 2)],
            expectedIntermediateResults: ["2", "6", "10", "5"],
            finalResult: "5",
            description: "2 × 3 + 4 ÷ 2 = 5"
        )
    ]
    
    // MARK: - 오류 케이스
    
    /// 오류가 예상되는 연산들
    static let errorCases: [(first: Int, operation: String, second: Int, expectedErrorIndicators: [String])] = [
        (10, "÷", 0, ["오류", "Error", "∞", "infinity", "Infinity"]),
        (0, "÷", 0, ["오류", "Error", "NaN", "undefined"])
    ]
    
    // MARK: - 성능 테스트 데이터
    
    /// 성능 테스트를 위한 반복 연산
    static let performanceTestOperations: [(operation: String, count: Int, expectedFinalResult: String)] = [
        ("+", 10, "10"),  // 0 + 1 + 1 + ... (10번)
        ("×", 5, "32"),   // 1 × 2 × 2 × ... (5번, 2^5 = 32)
        ("-", 5, "-5")    // 0 - 1 - 1 - ... (5번)
    ]
    
    // MARK: - 헬퍼 메서드
    
    /// 랜덤한 기본 연산 테스트 케이스 생성
    static func generateRandomBasicOperation() -> (first: Int, operation: String, second: Int, expected: String) {
        let operations = ["+", "-", "×", "÷"]
        let operation = operations.randomElement()!
        let first = Int.random(in: 1...100)
        let second = Int.random(in: 1...100)
        
        let expected: String
        switch operation {
        case "+":
            expected = "\(first + second)"
        case "-":
            expected = "\(first - second)"
        case "×":
            expected = "\(first * second)"
        case "÷":
            expected = "\(first / second)"
        default:
            expected = "0"
        }
        
        return (first, operation, second, expected)
    }
    
    /// 특정 자릿수의 랜덤 숫자 생성
    static func generateRandomNumber(digits: Int) -> Int {
        let min = Int(pow(10.0, Double(digits - 1)))
        let max = Int(pow(10.0, Double(digits))) - 1
        return Int.random(in: min...max)
    }
    
    /// 테스트 케이스 설명 생성
    static func generateTestDescription(first: Int, operation: String, second: Int, expected: String) -> String {
        return "\(first) \(operation) \(second) = \(expected)"
    }
    
    // MARK: - 검증 헬퍼
    
    /// 소수점 결과 검증
    static func isDecimalResultValid(_ actualResult: String, expectedContains: [String]) -> Bool {
        return expectedContains.contains { actualResult.contains($0) }
    }
    
    /// 오류 결과 검증
    static func isErrorResultValid(_ actualResult: String, expectedErrorIndicators: [String]) -> Bool {
        return expectedErrorIndicators.contains { actualResult.contains($0) }
    }
    
    /// 숫자 결과 검증 (문자열 비교)
    static func isNumericResultValid(_ actualResult: String, expected: String) -> Bool {
        // 공백 제거 후 비교
        let cleanActual = actualResult.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanExpected = expected.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleanActual == cleanExpected
    }
}

// MARK: - 테스트 실행 헬퍼

/// 테스트 실행을 위한 헬퍼 구조체
struct CalculatorTestRunner {
    
    /// 기본 연산 테스트 실행
    static func runBasicOperationTest(
        _ testCase: (first: Int, operation: String, second: Int, expected: String),
        using calculatorScreen: CalculatorScreen
    ) async {
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: testCase.first, operation: testCase.operation, second: testCase.second)
        
        await calculatorScreen.verifyDisplayValue(testCase.expected)
    }
    
    /// 연속 계산 테스트 실행
    static func runChainedCalculationTest(
        _ testCase: CalculatorTestData.ChainedCalculation,
        using calculatorScreen: CalculatorScreen
    ) async {
        await calculatorScreen.clearAndStart()
        
        for (index, step) in testCase.steps.enumerated() {
            if let operation = step.operation {
                await calculatorScreen.performOperation(operation)
                await calculatorScreen.enterNumber(step.number)
                await calculatorScreen.tapEquals()
            } else {
                await calculatorScreen.enterNumber(step.number)
            }
            
            // 중간 결과 검증
            if index < testCase.expectedIntermediateResults.count {
                await calculatorScreen.verifyDisplayValue(testCase.expectedIntermediateResults[index])
            }
        }
        
        // 최종 결과 검증
        await calculatorScreen.verifyDisplayValue(testCase.finalResult)
    }
    
    /// 오류 케이스 테스트 실행
    static func runErrorCaseTest(
        _ testCase: (first: Int, operation: String, second: Int, expectedErrorIndicators: [String]),
        using calculatorScreen: CalculatorScreen
    ) async {
        await calculatorScreen
            .clearAndStart()
            .enterNumber(testCase.first)
            .performOperation(testCase.operation)
            .enterNumber(testCase.second)
            .tapEquals()
        
        let displayValue = await calculatorScreen.getDisplayValue()
        let isValidError = CalculatorTestData.isErrorResultValid(displayValue, expectedErrorIndicators: testCase.expectedErrorIndicators)
        
        XCTAssertTrue(isValidError, "오류 처리가 적절하지 않습니다. 실제 값: \(displayValue)")
    }
}

// MARK: - XCTest Import
import XCTest 