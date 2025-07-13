import XCTest

/// 모든 UI 테스트의 기본 클래스
class BaseUITestCase: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        
        // 테스트 실행 중단 비활성화
        continueAfterFailure = false
        
        // 앱 초기화
        app = XCUIApplication()
        
        // 테스트용 실행 인수 설정
        app.launchArguments = [
            "--uitesting",
            "--reset-user-defaults",
            "--disable-animations"
        ]
        
        // 테스트용 환경 변수 설정
        app.launchEnvironment = [
            "DISABLE_ANIMATIONS": "1",
            "UI_TESTING": "1",
            "RESET_STATE": "1"
        ]
    }
    
    override func tearDown() {
        // 테스트 실패 시 스크린샷 첨부
        if let testRun = testRun, testRun.hasSucceeded == false {
            let screenshot = app.screenshot()
            let attachment = XCTAttachment(screenshot: screenshot)
            attachment.name = "실패한 테스트 스크린샷 - \(name)"
            attachment.lifetime = .keepAlways
            add(attachment)
        }
        
        // 앱 종료
        app.terminate()
        app = nil
        
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    /// 앱을 실행하고 기본 대기 시간을 둡니다
    func launchApp() {
        app.launch()
        // 앱 실행 후 안정화 대기
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    /// 특정 요소가 나타날 때까지 대기
    func waitForElement(_ element: XCUIElement, timeout: TimeInterval = 10.0, file: StaticString = #file, line: UInt = #line) {
        let predicate = NSPredicate(format: "exists == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(result, .completed, "요소가 \(timeout)초 내에 나타나지 않았습니다", file: file, line: line)
    }
    
    /// 특정 요소가 탭 가능해질 때까지 대기
    func waitForElementToBeHittable(_ element: XCUIElement, timeout: TimeInterval = 10.0, file: StaticString = #file, line: UInt = #line) {
        let predicate = NSPredicate(format: "exists == true && isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)
        
        XCTAssertEqual(result, .completed, "요소가 \(timeout)초 내에 탭 가능해지지 않았습니다", file: file, line: line)
    }
    
    /// 알림이 나타나면 자동으로 해제
    func dismissAlertIfPresent() {
        let alert = app.alerts.firstMatch
        if alert.waitForExistence(timeout: 2.0) {
            if alert.buttons["확인"].exists {
                alert.buttons["확인"].tap()
            } else if alert.buttons["OK"].exists {
                alert.buttons["OK"].tap()
            } else if alert.buttons.count > 0 {
                alert.buttons.firstMatch.tap()
            }
        }
    }
    
    /// 테스트 데이터 정리
    func resetAppState() {
        // 앱을 종료하고 다시 시작하여 상태 초기화
        app.terminate()
        app.launch()
        Thread.sleep(forTimeInterval: 1.0)
    }
}

// MARK: - Timeout Constants
struct TimeoutConstants {
    static let elementAppearance: TimeInterval = 5.0      // 일반 UI 요소
    static let pageLoad: TimeInterval = 10.0             // 페이지 로딩
    static let networkRequest: TimeInterval = 15.0       // 네트워크 요청
    static let animation: TimeInterval = 2.0             // 애니메이션 완료
    static let longRunningTask: TimeInterval = 30.0      // 장시간 작업
} 