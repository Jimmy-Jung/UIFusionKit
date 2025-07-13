import XCTest

/// 계산기 화면을 위한 Page Object 클래스
struct CalculatorScreen {
    let app: XCUIApplication
    
    // MARK: - UI Elements
    private var displayLabel: XCUIElement {
        app.staticTexts["calculator_display"]
    }
    
    // 숫자 버튼들
    private func numberButton(_ number: Int) -> XCUIElement {
        app.buttons["number_button_\(number)"]
    }
    
    // 연산자 버튼들
    private var addButton: XCUIElement {
        app.buttons["operation_button_add"]
    }
    
    private var subtractButton: XCUIElement {
        app.buttons["operation_button_subtract"]
    }
    
    private var multiplyButton: XCUIElement {
        app.buttons["operation_button_multiply"]
    }
    
    private var divideButton: XCUIElement {
        app.buttons["operation_button_divide"]
    }
    
    private var equalsButton: XCUIElement {
        app.buttons["equals_button"]
    }
    
    private var clearButton: XCUIElement {
        app.buttons["clear_button"]
    }
    
    // MARK: - Initializer
    init(app: XCUIApplication) {
        self.app = app
    }
    
    // MARK: - Actions (Chainable pattern)
    @discardableResult
    func tapNumber(_ number: Int) async -> Self {
        let button = numberButton(number)
        let isHittable = await button.waitForHittableAsync()
        XCTAssertTrue(isHittable, "숫자 버튼 \(number)이 탭 가능하지 않습니다")
        await button.tapAsync()
        return self
    }
    
    @discardableResult
    func tapAdd() async -> Self {
        let isHittable = await addButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "더하기 버튼이 탭 가능하지 않습니다")
        await addButton.tapAsync()
        return self
    }
    
    @discardableResult
    func tapSubtract() async -> Self {
        let isHittable = await subtractButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "빼기 버튼이 탭 가능하지 않습니다")
        await subtractButton.tapAsync()
        return self
    }
    
    @discardableResult
    func tapMultiply() async -> Self {
        let isHittable = await multiplyButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "곱하기 버튼이 탭 가능하지 않습니다")
        await multiplyButton.tapAsync()
        return self
    }
    
    @discardableResult
    func tapDivide() async -> Self {
        let isHittable = await divideButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "나누기 버튼이 탭 가능하지 않습니다")
        await divideButton.tapAsync()
        return self
    }
    
    @discardableResult
    func tapEquals() async -> Self {
        let isHittable = await equalsButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "등호 버튼이 탭 가능하지 않습니다")
        await equalsButton.tapAsync()
        return self
    }
    
    @discardableResult
    func tapClear() async -> Self {
        let isHittable = await clearButton.waitForHittableAsync()
        XCTAssertTrue(isHittable, "클리어 버튼이 탭 가능하지 않습니다")
        await clearButton.tapAsync()
        return self
    }
    
    // MARK: - Convenience Methods
    @discardableResult
    func enterNumber(_ number: Int) async -> Self {
        let digits = String(number).compactMap { Int(String($0)) }
        for digit in digits {
            await tapNumber(digit)
        }
        return self
    }
    
    @discardableResult
    func performOperation(_ operation: String) async -> Self {
        switch operation {
        case "+":
            await tapAdd()
        case "-":
            await tapSubtract()
        case "×", "*":
            await tapMultiply()
        case "÷", "/":
            await tapDivide()
        default:
            XCTFail("지원하지 않는 연산자입니다: \(operation)")
        }
        return self
    }
    
    @discardableResult
    func performCalculation(first: Int, operation: String, second: Int) async -> Self {
        await enterNumber(first)
        await performOperation(operation)
        await enterNumber(second)
        await tapEquals()
        return self
    }
    
    @discardableResult
    func clearAndStart() async -> Self {
        await tapClear()
        return self
    }
    
    // MARK: - Verifications
    func getDisplayValue() async -> String {
        let exists = await displayLabel.waitForExistenceAsync()
        XCTAssertTrue(exists, "디스플레이가 존재하지 않습니다")
        return displayLabel.label
    }
    
    func isDisplayShowing(_ expectedValue: String) async -> Bool {
        let actualValue = await getDisplayValue()
        return actualValue == expectedValue
    }
    
    func verifyDisplayValue(_ expectedValue: String, file: StaticString = #file, line: UInt = #line) async {
        let actualValue = await getDisplayValue()
        XCTAssertEqual(actualValue, expectedValue, "디스플레이 값이 예상과 다릅니다", file: file, line: line)
    }
    
    // MARK: - Waits
    func waitForScreenToLoad() async {
        let displayExists = await displayLabel.waitForExistenceAsync()
        XCTAssertTrue(displayExists, "계산기 화면이 로드되지 않았습니다")
        
        let numberButtonExists = await numberButton(0).waitForExistenceAsync()
        XCTAssertTrue(numberButtonExists, "숫자 버튼들이 로드되지 않았습니다")
        
        let addButtonExists = await addButton.waitForExistenceAsync()
        XCTAssertTrue(addButtonExists, "연산자 버튼들이 로드되지 않았습니다")
    }
    
    func isScreenLoaded() async -> Bool {
        let displayLoaded = await displayLabel.waitForExistenceAsync(timeout: 5.0)
        let numberButtonLoaded = await numberButton(0).waitForExistenceAsync(timeout: 1.0)
        let addButtonLoaded = await addButton.waitForExistenceAsync(timeout: 1.0)
        
        return displayLoaded && numberButtonLoaded && addButtonLoaded
    }
}

// MARK: - Screen Protocol Conformance
extension CalculatorScreen: Screen {}

// MARK: - Screen Protocol
protocol Screen {
    var app: XCUIApplication { get }
    func waitForScreenToLoad() async
    func isScreenLoaded() async -> Bool
}

extension Screen {
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10.0) async {
        let predicate = NSPredicate(format: "exists == true && isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = await XCTWaiter().fulfillment(of: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "요소가 예상 시간 내에 나타나지 않았습니다")
    }
} 