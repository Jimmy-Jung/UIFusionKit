import XCTest

extension XCUIElement {
    /// 요소가 존재할 때까지 비동기적으로 대기
    func waitForExistenceAsync(timeout: TimeInterval = 10.0) async -> Bool {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let result = self.waitForExistence(timeout: timeout)
                continuation.resume(returning: result)
            }
        }
    }
    
    /// 비동기적으로 탭 수행
    func tapAsync() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.tap()
                continuation.resume()
            }
        }
    }
    
    /// 비동기적으로 텍스트 입력
    func typeTextAsync(_ text: String) async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                self.typeText(text)
                continuation.resume()
            }
        }
    }
    
    /// 요소가 활성화될 때까지 대기
    func waitForHittableAsync(timeout: TimeInterval = 10.0) async -> Bool {
        let predicate = NSPredicate(format: "exists == true && isHittable == true")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: self)
        
        return await withCheckedContinuation { continuation in
            Task {
                let result = await XCTWaiter().fulfillment(of: [expectation], timeout: timeout)
                continuation.resume(returning: result == .completed)
            }
        }
    }
}

extension XCTWaiter {
    /// async/await를 지원하는 fulfillment 메서드
    func fulfillment(of expectations: [XCTestExpectation], timeout: TimeInterval) async -> XCTWaiter.Result {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global().async {
                let result = self.wait(for: expectations, timeout: timeout)
                continuation.resume(returning: result)
            }
        }
    }
} 