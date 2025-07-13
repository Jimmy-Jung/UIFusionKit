import XCTest

/// 계산기 UI 테스트 클래스
class CalculatorUITests: BaseUITestCase {
    
    // MARK: - 기본 산술 연산 테스트
    
    func testBasicAddition() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 5, operation: "+", second: 3)
        
        // Then
        await calculatorScreen.verifyDisplayValue("8")
    }
    
    func testBasicSubtraction() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 10, operation: "-", second: 4)
        
        // Then
        await calculatorScreen.verifyDisplayValue("6")
    }
    
    func testBasicMultiplication() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 7, operation: "×", second: 6)
        
        // Then
        await calculatorScreen.verifyDisplayValue("42")
    }
    
    func testBasicDivision() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 15, operation: "÷", second: 3)
        
        // Then
        await calculatorScreen.verifyDisplayValue("5")
    }
    
    // MARK: - 연속 계산 테스트
    
    func testChainedCalculations() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When - 5 + 3 = 8, 그 다음 × 2 = 16
        await calculatorScreen
            .clearAndStart()
            .enterNumber(5)
            .tapAdd()
            .enterNumber(3)
            .tapEquals()
        
        // 첫 번째 결과 확인
        await calculatorScreen.verifyDisplayValue("8")
        
        // 연속 계산
        await calculatorScreen
            .tapMultiply()
            .enterNumber(2)
            .tapEquals()
        
        // Then
        await calculatorScreen.verifyDisplayValue("16")
    }
    
    func testMultipleOperationsInSequence() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When - 100 - 25 + 10 × 2 ÷ 5
        await calculatorScreen
            .clearAndStart()
            .enterNumber(100)
            .tapSubtract()
            .enterNumber(25)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("75")
        
        await calculatorScreen
            .tapAdd()
            .enterNumber(10)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("85")
        
        await calculatorScreen
            .tapMultiply()
            .enterNumber(2)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("170")
        
        await calculatorScreen
            .tapDivide()
            .enterNumber(5)
            .tapEquals()
        
        // Then
        await calculatorScreen.verifyDisplayValue("34")
    }
    
    // MARK: - 클리어 기능 테스트
    
    func testClearFunction() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When - 숫자 입력 후 클리어
        await calculatorScreen
            .enterNumber(123)
            .tapClear()
        
        // Then
        await calculatorScreen.verifyDisplayValue("0")
    }
    
    func testClearDuringCalculation() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When - 계산 중간에 클리어
        await calculatorScreen
            .clearAndStart()
            .enterNumber(50)
            .tapAdd()
            .enterNumber(25)
            .tapClear()
        
        // Then
        await calculatorScreen.verifyDisplayValue("0")
    }
    
    // MARK: - 큰 숫자 테스트
    
    func testLargeNumbers() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 999, operation: "+", second: 1)
        
        // Then
        await calculatorScreen.verifyDisplayValue("1000")
    }
    
    func testVeryLargeMultiplication() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 123, operation: "×", second: 456)
        
        // Then
        await calculatorScreen.verifyDisplayValue("56088")
    }
    
    // MARK: - 소수점 및 특수 케이스 테스트
    
    func testDivisionWithDecimalResult() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 10, operation: "÷", second: 4)
        
        // Then - 결과가 2.5인지 확인 (실제 구현에 따라 다를 수 있음)
        let displayValue = await calculatorScreen.getDisplayValue()
        XCTAssertTrue(displayValue.contains("2.5") || displayValue.contains("2,5"), 
                     "나눗셈 결과가 예상과 다릅니다: \(displayValue)")
    }
    
    // MARK: - 오류 상황 테스트
    
    func testDivisionByZero() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When
        await calculatorScreen
            .clearAndStart()
            .enterNumber(10)
            .tapDivide()
            .enterNumber(0)
            .tapEquals()
        
        // Then - 오류 메시지 또는 특별한 처리 확인
        let displayValue = await calculatorScreen.getDisplayValue()
        XCTAssertTrue(displayValue.contains("오류") || displayValue.contains("Error") || displayValue == "∞", 
                     "0으로 나누기 오류가 적절히 처리되지 않았습니다: \(displayValue)")
        
        // 오류 알림이 나타나면 해제
        dismissAlertIfPresent()
    }
    
    // MARK: - 사용자 인터페이스 테스트
    
    func testAllNumberButtonsWork() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When & Then - 모든 숫자 버튼 테스트
        for number in 0...9 {
            await calculatorScreen
                .tapClear()
                .tapNumber(number)
            
            await calculatorScreen.verifyDisplayValue("\(number)")
        }
    }
    
    func testAllOperationButtonsWork() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When & Then - 모든 연산자 버튼이 탭 가능한지 확인
        await calculatorScreen
            .clearAndStart()
            .enterNumber(5)
            .tapAdd()
            .enterNumber(1)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("6")
        
        await calculatorScreen
            .tapClear()
            .enterNumber(5)
            .tapSubtract()
            .enterNumber(1)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("4")
        
        await calculatorScreen
            .tapClear()
            .enterNumber(5)
            .tapMultiply()
            .enterNumber(2)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("10")
        
        await calculatorScreen
            .tapClear()
            .enterNumber(10)
            .tapDivide()
            .enterNumber(2)
            .tapEquals()
        
        await calculatorScreen.verifyDisplayValue("5")
    }
    
    // MARK: - 디스플레이 테스트
    
    func testDisplayUpdatesCorrectly() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When & Then - 각 단계에서 디스플레이 값 확인
        await calculatorScreen.tapClear()
        await calculatorScreen.verifyDisplayValue("0")
        
        await calculatorScreen.tapNumber(1)
        await calculatorScreen.verifyDisplayValue("1")
        
        await calculatorScreen.tapNumber(2)
        await calculatorScreen.verifyDisplayValue("12")
        
        await calculatorScreen.tapNumber(3)
        await calculatorScreen.verifyDisplayValue("123")
        
        await calculatorScreen.tapAdd()
        // 연산자 입력 후에도 숫자가 유지되는지 확인
        let displayAfterOperation = await calculatorScreen.getDisplayValue()
        XCTAssertTrue(displayAfterOperation == "123" || displayAfterOperation.contains("123"), 
                     "연산자 입력 후 디스플레이가 예상과 다릅니다: \(displayAfterOperation)")
    }
    
    // MARK: - 성능 테스트
    
    func testCalculatorPerformance() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When - 빠른 연속 입력 테스트
        let startTime = Date()
        
        await calculatorScreen
            .clearAndStart()
            .enterNumber(1)
            .tapAdd()
            .enterNumber(1)
            .tapEquals()
            .tapAdd()
            .enterNumber(1)
            .tapEquals()
            .tapAdd()
            .enterNumber(1)
            .tapEquals()
            .tapAdd()
            .enterNumber(1)
            .tapEquals()
        
        let endTime = Date()
        let executionTime = endTime.timeIntervalSince(startTime)
        
        // Then
        await calculatorScreen.verifyDisplayValue("5")
        XCTAssertLessThan(executionTime, 10.0, "계산기 응답 시간이 너무 깁니다: \(executionTime)초")
    }
    
    // MARK: - 경계값 테스트
    
    func testZeroOperations() async {
        // Given
        launchApp()
        let calculatorScreen = CalculatorScreen(app: app)
        await calculatorScreen.waitForScreenToLoad()
        
        // When & Then - 0과의 연산 테스트
        await calculatorScreen
            .clearAndStart()
            .performCalculation(first: 0, operation: "+", second: 5)
        await calculatorScreen.verifyDisplayValue("5")
        
        await calculatorScreen
            .tapClear()
            .performCalculation(first: 5, operation: "+", second: 0)
        await calculatorScreen.verifyDisplayValue("5")
        
        await calculatorScreen
            .tapClear()
            .performCalculation(first: 0, operation: "×", second: 100)
        await calculatorScreen.verifyDisplayValue("0")
        
        await calculatorScreen
            .tapClear()
            .performCalculation(first: 100, operation: "×", second: 0)
        await calculatorScreen.verifyDisplayValue("0")
    }
} 