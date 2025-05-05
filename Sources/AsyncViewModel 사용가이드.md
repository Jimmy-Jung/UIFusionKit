# AsyncViewModel 사용 가이드

## 목차
- [소개](#소개)
- [주요 특징](#주요-특징)
- [구현 방법](#구현-방법)
- [사용 예시](#사용-예시)
- [SwiftUI와 통합](#swiftui와-통합)
- [장점 및 활용 사례](#장점-및-활용-사례)
- [주의사항](#주의사항)

## 소개
`AsyncViewModel`은 비동기 작업을 체계적으로 처리하기 위한 Swift 프로토콜입니다. 단방향 데이터 흐름 원칙을 따르며, 사용자 입력(Input)을 받아 내부적으로 액션(Action)으로 변환한 후 최종적으로 ViewModel의 상태를 업데이트하는 패턴을 제공합니다.

이 패턴의 주요 흐름은 다음과 같습니다:
```
사용자 입력(Input) → 액션 변환(transform) → 액션 수행(perform) → 상태 업데이트 → UI 반영
```

## 주요 특징
- **@MainActor 적용**: UI 관련 작업이 메인 스레드에서 실행되도록 보장
- **ObservableObject 준수**: SwiftUI와 통합을 통해 상태 변경 시 자동 UI 업데이트
- **비동기 작업 처리**: async/await을 활용한 현대적인 비동기 프로그래밍 지원
- **단방향 데이터 흐름**: 예측 가능하고 관리하기 쉬운 상태 처리 패턴
- **체계적인 에러 처리**: 비동기 작업 중 발생하는 오류를 일관된 방식으로 처리

## 구현 방법
### 1. AsyncViewModel 프로토콜 채택
```swift
final class MyViewModel: AsyncViewModel {
    // 구현 내용
}
```

### 2. Input 및 Action 열거형 정의
```swift
enum Input {
    case loadData
    case refresh
    case selectItem(id: Int)
    // 사용자 입력에 해당하는 케이스들
}

enum Action {
    case fetchData
    case updateList
    case showDetail(id: Int)
    // 실제 수행할 액션들
}
```

### 3. 필수 메서드 구현
#### transform 메서드
입력(Input)을 액션(Action)으로 변환하는 메서드입니다.

```swift
func transform(_ input: Input) async throws -> [Action] {
    switch input {
    case .loadData:
        return [.fetchData]
    case .refresh:
        return [.fetchData, .updateList]
    case .selectItem(let id):
        return [.showDetail(id: id)]
    }
}
```

#### perform 메서드
액션(Action)을 수행하여 ViewModel의 상태를 업데이트하는 메서드입니다.

```swift
func perform(_ action: Action) async throws {
    switch action {
    case .fetchData:
        // 데이터 로딩 로직
        try await loadDataFromServer()
    case .updateList:
        // 목록 업데이트 로직
        updateItemList()
    case .showDetail(let id):
        // 상세 화면 표시 로직
        selectedItemId = id
    }
}
```

#### handleError 메서드
오류를 처리하는 메서드입니다.

```swift
func handleError(_ error: Error) async {
    // 오류 처리 로직
    errorMessage = error.localizedDescription
    isErrorAlertPresented = true
}
```

## 사용 예시
### CounterAsyncViewModel 예시

```swift
final class CounterAsyncViewModel: AsyncViewModel {
    
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
    
    // 상태 관리용 프로퍼티
    @Published var value: Int = 0
    @Published var activeAlert: AlertType?
    
    // 값의 허용 범위
    private let minValue = -10
    private let maxValue = 10
    
    init() { }
    
    // Input을 Action으로 변환
    func transform(_ input: Input) async throws -> [Action] {
        switch input {
            case .increase: return [.increaseValue]
            case .decrease: return [.decreaseValue]
            case .reset: return [.resetValue]
            case .show: return [.showAlert]
            case .dismissAlert: return [.dismissAlert]
        }
    }
    
    // Action 수행
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
                activeAlert = nil
        }
    }
    
    // 비즈니스 로직 구현
    private func increaseValue() async throws {
        let newValue = value + 1
        if newValue > maxValue {
            throw CounterError.valueOutOfRange(current: newValue, min: minValue, max: maxValue)
        }
        value = newValue
    }
    
    // 에러 처리
    func handleError(_ error: Error) async {
        activeAlert = .error(error)
        print("카운터 오류: \(error.localizedDescription)")
    }
}
```

## SwiftUI와 통합
### ViewModel 초기화 및 사용

```swift
struct CounterView: View {
    @StateObject private var viewModel: CounterAsyncViewModel
    
    init(_ viewModel: CounterAsyncViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Value: \(viewModel.value)")
                .font(.system(size: 20, weight: .semibold))
            
            // 이벤트 전송 예시
            Button("증가") {
                viewModel.send(.increase)
            }
            
            Button("감소") {
                viewModel.send(.decrease)
            }
            
            Button("리셋") {
                viewModel.send(.reset)
            }
        }
        // 알림 표시 예시
        .alert(item: $viewModel.activeAlert) { alertType in
            // 알림 표시 로직
        }
    }
}
```

### 이벤트 전송 방법
사용자 액션이 발생하면 `send` 메서드를 호출하여 Input을 전달합니다.

```swift
Button("증가") {
    viewModel.send(.increase)
}
```

### 상태 관찰 방법
ViewModel의 `@Published` 프로퍼티를 View에서 참조하여 상태 변화를 관찰합니다.

```swift
Text("Value: \(viewModel.value)")
```

## 장점 및 활용 사례
- **코드 분리**: 비즈니스 로직과 UI 로직을 명확히 분리
- **테스트 용이성**: 비동기 로직을 독립적으로 테스트 가능
- **재사용성**: 동일한 ViewModel을 여러 View에서 재사용 가능
- **유지보수성**: 단방향 데이터 흐름으로 상태 관리가 예측 가능하고 디버깅이 용이
- **확장성**: 복잡한 비동기 작업을 체계적으로 처리 가능

## 주의사항
- **메모리 관리**: 클로저 내에서 `[weak self]`를 사용하여 메모리 누수 방지
- **메인 스레드 실행**: UI 업데이트는 반드시 메인 스레드에서 수행
- **에러 처리**: 모든 비동기 작업에서 발생할 수 있는 에러를 철저히 처리
- **상태 일관성**: 여러 액션이 동시에 실행될 때 상태 일관성 유지에 주의
