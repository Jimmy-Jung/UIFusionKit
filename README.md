## 미리보기
### UIFusionKit의 State Data Flow
<img width="831" alt="ViewModelFlow" src="https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17">

UIFusionKit의 AsyncViewModel은 단방향 데이터 흐름을 따르는 비동기 작업 처리를 위한 패턴을 제공합니다.

비동기 작업 흐름: `사용자 입력(Input) → 액션 변환(transform) → 액션 수행(perform) → 상태 업데이트 → UI 반영`

### AsyncViewModel 프로토콜

```swift
@MainActor
public protocol AsyncViewModel: ObservableObject {
    associatedtype Input
    associatedtype Action

    func send(_ input: Input)
    func transform(_ input: Input) async -> [Action]
    func perform(_ action: Action) async throws
    func handleError(_ error: Error) async
}

public extension AsyncViewModel {
    func send(_ input: Input) {
        Task { [weak self] in
            guard let self = self else { return }
            
            // Input을 Action으로 변환
            let actions = await self.transform(input)
            
            // 각 Action 순차적으로 처리
            for action in actions {
                do {
                    try await self.perform(action)
                } catch {
                    await self.handleError(error)
                }
            }
        }
    }
}
```

## AsyncViewModel 소개

AsyncViewModel은 비동기 작업을 체계적으로 처리하기 위한 Swift 프로토콜입니다. 단방향 데이터 흐름 원칙을 따르며, 사용자 입력(Input)을 받아 내부적으로 액션(Action)으로 변환한 후 최종적으로 ViewModel의 상태를 업데이트하는 패턴을 제공합니다.

### 주요 특징
- **@MainActor 적용**: UI 관련 작업이 메인 스레드에서 실행되도록 보장
- **ObservableObject 준수**: SwiftUI와 통합을 통해 상태 변경 시 자동 UI 업데이트
- **비동기 작업 처리**: async/await을 활용한 현대적인 비동기 프로그래밍 지원
- **단방향 데이터 흐름**: 예측 가능하고 관리하기 쉬운 상태 처리 패턴
- **체계적인 에러 처리**: 비동기 작업 중 발생하는 오류를 일관된 방식으로 처리

## UIFusionKit 장점
UIFusionKit은 다음과 같은 장점이 있습니다:

- **Composable MVVM**: UIKit과 SwiftUI 양쪽에서 동일한 ViewModel을 사용하여 일관된 로직과 상태 관리를 구현할 수 있습니다.
- **단방향 데이터 플로우**: 상태 관리를 명확하게 하고, 데이터의 흐름을 예측 가능하게 하여 UI 업데이트를 직관적이고 예측 가능하게 만듭니다.
- **효율적인 비동기 작업 처리**: async/await을 활용하여 복잡한 비동기 작업을 체계적으로 관리하고 처리합니다.
- **일관된 에러 처리**: 비동기 작업 중 발생하는 오류를 체계적으로 관리하고 사용자에게 적절하게 표시합니다.
- **유연성**: 두 플랫폼을 동시에 지원하여 팀원들이 점차적으로 SwiftUI에 익숙해질 수 있도록 지원합니다.
- **통합**: 기획팀, 디자인팀, 개발팀, QA팀에서 기획서를 공용해서 개발 가능합니다.
  
# **UIFusionKit 개발 및 도입**

## **문제 발견**
기존 iOS 프로젝트를 개발하면서 가장 큰 어려움 중 하나는 **비동기 작업 처리의 복잡성**이었습니다. 네트워크 요청, 데이터베이스 작업, 사용자 인증 등 비동기 작업이 증가하면서 다음과 같은 문제점이 대두되었습니다:

1. **콜백 지옥(Callback Hell)**: 중첩된 비동기 작업이 콜백 형태로 구현되어 코드 가독성과 유지보수성이 떨어짐
2. **에러 처리의 일관성 부재**: 각 비동기 작업마다 다른 방식의 에러 처리로 인한 혼란
3. **상태 관리의 어려움**: 비동기 작업의 상태(로딩, 성공, 실패)를 일관되게 관리하기 어려움
4. **UI 업데이트 동기화**: 비동기 작업 완료 후 UI 업데이트를 메인 스레드에서 처리해야 하는 번거로움

이러한 문제는 **UIKit과 SwiftUI를 혼용**해야 하는 상황에서 더욱 복잡해졌습니다. UIKit은 주로 Delegate 패턴이나 콜백을 사용하고, SwiftUI는 Combine과 Publisher를 활용하는 등 서로 다른 비동기 처리 방식을 사용했기 때문입니다.

또한 일부 화면에서는 애니메이션 효과와 인터랙티브한 UI가 중요했지만, 동시에 비동기 데이터 처리도 요구되어 두 가지를 조화롭게 구현하는 것이 어려웠습니다.

이러한 문제들을 해결하기 위해 UIKit과 SwiftUI에서 모두 사용할 수 있으면서, 현대적인 비동기 처리 패턴을 지원하는 ViewModel 아키텍처가 필요했습니다.

## MVVM 조사

이 문제를 해결하기 위해 MVVM 아키텍처를 다시 살펴보았습니다. 
일반적으로 MVVM은 View 로직과 비즈니스 로직을 분리하는 데 활용되지만, 비동기 작업 처리에 대한 명확한 가이드라인이 부족했습니다.

<img width="631" alt="mvvm조사" src="https://github.com/user-attachments/assets/9d717d7c-ba72-4d21-a0fb-de67227db3e4">

특히 SwiftUI 환경에서는 비동기 작업에 대한 상태 관리가 더욱 복잡해집니다. SwiftUI는 이미 View가 ViewModel 역할을 일정 부분 수행하고 있어 'ViewModel on ViewModel'이라는 비효율 논란이 있었습니다.

왜 논란이 되었을까 고민해보니, 전통적인 MVVM에서 ViewModel이 담당해야 할 상태 관리와 로직을 SwiftUI가 자체적으로 'View에서' 대부분 처리하기 때문에,
별도의 ViewModel을 추가로 두는 경우 "중복 구조" 혹은 "이중 관리"가 발생할 가능성이 높습니다. 

이는 코드 규모가 불필요하게 커지거나, 이벤트 흐름이 View와 ViewModel 사이에서 중첩되어 추적이 어려워지는 문제로 이어질 수 있습니다.

<img width="631" alt="스유데이터플로우" src="https://github.com/user-attachments/assets/313ed2b4-952c-4d9b-8e5f-190624872ec3">

SwiftUI에서의 State Data Flow

하지만 SwiftUI가 제공하는 단방향 상태 관리(State Data Flow)를 살펴보면,
이는 기존 MVVM에서 강조하던 '단방향 데이터 흐름'을 SwiftUI 문법에 맞춰 재해석해 이미 내장해두었다고 볼 수 있습니다. 

결국, 굳이 별도의 ViewModel 계층을 두지 않고도 View가 @State, @Binding, @ObservedObject(또는 @StateObject) 등을 통해 상태를 관찰하고, 
상태 변화 시 UI를 자동 갱신하도록 하는 구조가 마련되어 있습니다.

하지만 이런 접근 방식도 **복잡한 비동기 작업**을 처리하는 데는 한계가 있었습니다. 특히:

1. 여러 비동기 작업의 순차적/병렬적 처리
2. 오류 상황에서의 복구 및 대체 흐름 처리
3. UIKit과 SwiftUI 사이의 일관된 비동기 패턴 적용

다만 대규모 프로젝트나 복잡한 비즈니스 로직을 처리해야 할 경우에는,
TCA(The Composable Architecture)나 Clean Architecture 등을 통해 아키텍처적 계층 분리를 더 선명히 가져가기도 합니다. 

이때 SwiftUI가 제공하는 단방향 상태 관리와 자동 UI 갱신 기능을 그대로 활용하면서, 
비즈니스 로직을 담은 별도 계층(Model이나 Domain 레이어 등)을 분리해 "ViewModel on ViewModel" 문제가 다시 불거지지 않도록 할 수 있습니다.

결국 'ViewModel on ViewModel' 논란은 SwiftUI가 원래 MVVM-like 구조를 갖춘 상태에서, 개발자가 추가로 ViewModel 계층을 과도하게 만들면 생기는 중복이라는 결론을 얻었습니다.
SwiftUI만의 State Data Flow를 충분히 이해하고 활용한다면, 효율적인 상태 관리가 가능하고, 필요 시 다른 아키텍처 기법(Clean Architecture, TCA 등)을 조합해 유연하게 확장할 수도 있습니다.


SwiftUI만으로 앱을 구성한다면, View가 일부 ViewModel 역할을 흡수하여 'ViewModel on ViewModel' 문제를 크게 줄일 수 있습니다. 

하지만 기존 프로젝트나 UIKit과 병행 사용해야 하는 상황이라면, SwiftUI의 단방향 상태 관리만으로는 **비동기 작업 처리**에 일부 한계가 있을 수 있습니다.

<img width="631" alt="ReactorKit의 State Data Flow" src="https://github.com/user-attachments/assets/c9cc6eaf-3481-4a38-85ea-18f60693684e">

ReactorKit의 State Data Flow

특히 기존 UIKit 프로젝트에서 MVVM을 적용할 때는 ReactorKit과 같은 라이브러리를 자주 사용하는데, 
이는 사용 규칙이 명확하고 단방향 데이터 플로우를 통해 뷰와 모델 간 상태 변화를 쉽게 추적할 수 있기 때문입니다.

그러나 ReactorKit은 RxSwift 기반의 View 프로토콜을 사용하기 때문에 SwiftUI와 바로 호환하기 어려운 문제가 있고, 
또한 async/await과 같은 Swift의 최신 비동기 기능을 활용하기 어렵다는 한계가 있었습니다.

<img width="631" alt="tca" src="https://github.com/user-attachments/assets/3a58b5bd-c93a-489f-8919-f148844357af">

TCA의 State Data Flow

TCA는 SwiftUI에 특화된 구조를 기반으로 하므로 UIKit에 적용하기 힘든 부분이 존재합니다.
또한 학습 곡선이 가파르고 보일러플레이트 코드가 많아 간단한 기능 구현에도 적지 않은 코드가 필요했습니다.

다시 말해, SwiftUI와 UIKit을 동시에 쓰거나, 기존의 UIKit 코드를 단계적으로 SwiftUI로 전환하려는 팀은 
ReactorKit이나 TCA 단독으로는 대응하기 어려운 지점이 발생하게 됩니다.

따라서 이러한 문제를 해결하고자, **현대적인 Swift 비동기 처리(async/await)** 를 중심으로,
SwiftUI와 UIKit 모두에서 동일하게 사용할 수 있는 ViewModel 패턴인 **AsyncViewModel**을 개발하게 되었습니다.


## AsyncViewModel의 State Data Flow

<img width="631" alt="ViewModelFlow" src="https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17">

ReactorKit과 TCA의 단방향 플로우, 상태 기반 흐름과 유사하지만, 특정 라이브러리나 특정 프레임워크에 종속적이지 않도록 구현한 점이 핵심입니다. 또한 async/await을 활용한 현대적인 비동기 패턴을 적용하여 비동기 작업을 효율적으로 처리합니다.

## AsyncViewModel 구현 예시

다음은 카운터 앱을 구현한 AsyncViewModel 예시입니다:

```swift
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
    
    // 상태 관리용 프로퍼티
    @Published var value: Int = 0
    @Published var activeAlert: AlertType?
    @Published var loadingState: LoadingState = .none
    
    // 값의 허용 범위
    private let minValue = -10
    private let maxValue = 10
    
    init() {}
    
    // Input을 Action으로 변환
    func transform(_ input: Input) async -> [Action] {
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
    
    // 에러 처리
    func handleError(_ error: Error) async {
        loadingState = .none
        activeAlert = .error(error)
        print("카운터 오류: \(error.localizedDescription)")
    }
}
```

## SwiftUI와 UIKit 통합

### SwiftUI에서 AsyncViewModel 사용

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
            
            Text("허용 범위: -10 ~ 10")
                .font(.caption)
                .foregroundColor(.gray)
            
            ButtonView(
                title: "Increase",
                icon: "plus",
                backgroundColor: .gray.opacity(0.2),
                isLoading: viewModel.loadingState == .increasing
            ) {
                viewModel.send(.increase)
            }
            
            ButtonView(
                title: "Decrease",
                icon: "minus",
                backgroundColor: .gray.opacity(0.2),
                isLoading: viewModel.loadingState == .decreasing
            ) {
                viewModel.send(.decrease)
            }
            
            ButtonView(
                title: "Reset",
                icon: "arrow.counterclockwise.circle",
                backgroundColor: .orange.opacity(0.2),
                isLoading: false
            ) {
                viewModel.send(.reset)
            }
            
            ButtonView(
                title: "Show",
                icon: "exclamationmark.circle.fill",
                backgroundColor: .yellow.opacity(0.2),
                isLoading: false
            ) {
                viewModel.send(.show)
            }
        }
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .info:
                return Alert(
                    title: Text("알림"), 
                    message: Text("\(viewModel.value)"), 
                    dismissButton: .default(Text("닫기")) {
                        viewModel.send(.dismissAlert)
                    }
                )
            case .error(let error):
                return Alert(
                    title: Text("오류"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("확인")) {
                        viewModel.send(.dismissAlert)
                    }
                )
            case .none:
                // 이 케이스는 발생하지 않음
                return Alert(title: Text(""))
            }
        }
    }
}

struct ButtonView: View {
    let title: String
    let icon: String
    let backgroundColor: Color
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label {
                Text(title)
            } icon: {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: icon)
                }
            }
            .padding(8)
            .background(backgroundColor)
            .cornerRadius(8)
        }
        .disabled(isLoading)
    }
}
```

### UIKit에서 AsyncViewModel 사용

UIKit에서는 Combine을 활용하여 ViewModel의 상태 변화를 구독하고 UI를 업데이트할 수 있습니다:

```swift
final class CounterViewController: UIViewController {
    private let viewModel: CounterAsyncViewModel
    private var cancellables = Set<AnyCancellable>()
    
    private let valueLabel = UILabel()
    private let rangeLabel = UILabel()
    private let increaseButton = UIButton(configuration: .gray())
    private let decreaseButton = UIButton(configuration: .gray())
    private let resetButton = UIButton(configuration: .plain())
    private let showButton = UIButton(configuration: .plain())
    
    init(_ viewModel: CounterAsyncViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindState()
        bindInput()
    }
    
    private func bindState() {
        viewModel.$value
            .map { "Value: \($0)" }
            .assign(to: \.text, on: valueLabel)
            .store(in: &cancellables)
        
        viewModel.$activeAlert
            .compactMap { $0 }
            .sink { [weak self] alertType in
                guard let self = self else { return }
                
                switch alertType {
                case .info:
                    self.showInfoAlert(self.viewModel.value.description)
                case .error(let error):
                    self.showErrorAlert(error)
                case .none:
                    break
                }
            }
            .store(in: &cancellables)
        
        // 로딩 상태 바인딩
        viewModel.$loadingState
            .sink { [weak self] state in
                guard let self = self else { return }
                
                switch state {
                case .increasing:
                    self.increaseButton.configuration?.showsActivityIndicator = true
                    self.increaseButton.isEnabled = false
                    
                case .decreasing:
                    self.decreaseButton.configuration?.showsActivityIndicator = true
                    self.decreaseButton.isEnabled = false
                    
                case .none:
                    self.increaseButton.configuration?.showsActivityIndicator = false
                    self.increaseButton.isEnabled = true
                    
                    self.decreaseButton.configuration?.showsActivityIndicator = false
                    self.decreaseButton.isEnabled = true
                }
            }
            .store(in: &cancellables)
    }
    
    private func bindInput() {
        increaseButton.addAction(self) { owner in
            owner.viewModel.send(.increase)
        }
        
        decreaseButton.addAction(self) { owner in
            owner.viewModel.send(.decrease)
        }
        
        resetButton.addAction(self) { owner in
            owner.viewModel.send(.reset)
        }
        
        showButton.addAction(self) { owner in
            owner.viewModel.send(.show)
        }
    }
}
```

## AsyncViewModel 사용 방법

1. `viewModel.send(_ input:)` 메서드를 통해 Input Event를 전달합니다.
2. `transform(_ input:)` 메서드를 통해 Input → Action으로 변환합니다. (하나의 Input이 여러 Action으로 분기 가능)
3. `perform(_ action:)` 메서드에서 State를 변경하거나 SideEffect를 발생시킵니다.
4. 에러가 발생하면 `handleError(_ error:)` 메서드에서 처리합니다.

이를 통해 async/await, Combine 등 현대적인 Swift 기능을 활용하면서 UIKit, SwiftUI에 구애받지 않는 독립적인 디자인 아키텍처를 유지할 수 있습니다.

## 입력에 따른 flow 예시


https://github.com/user-attachments/assets/b87f2b9c-c782-4104-b333-802600af8f1d

예시 화면: Increase, Decrease, Reset, Show 버튼

### 입력&상태

**Input:** 🟩 ㅤㅤ**Action:** ✴️ ㅤㅤ **State:** 🟦


**주요 기능**

**🟩: increase** 버튼 선택

- **✴️:** increaseValue
    - **🟦:** value 값이 1 증가합니다 (최대 10까지).
    - 범위를 벗어나면 에러 발생 및 알림 표시

**🟩:** decrease 버튼 선택

- **✴️**: decreaseValue
    - **🟦:** value 값이 1 감소합니다 (최소 -10까지).
    - 범위를 벗어나면 에러 발생 및 알림 표시

**🟩** reset 버튼 선택

- **✴️**: resetValue
    - **🟦:** value 값이 0으로 초기화됩니다.

**🟩**: show 버튼 선택

- **✴️**: showAlert
    - **🟦:** activeAlert 값이 설정되어 알림이 표시됩니다.

에러 처리:
- 값이 범위를 벗어나면 에러 발생
- handleError 메서드에서 에러 알림 표시

### 결론

UIFusionKit의 AsyncViewModel은 비동기 작업을 체계적으로 처리하고 코드 재사용성을 높입니다. 
async/await을 활용한 현대적인 비동기 프로그래밍 방식을 도입하여 복잡한 비동기 작업도 명확하게 처리할 수 있습니다.
또한 MVVM + Clean Architecture를 결합해 TDD를 가능케 합니다.
결과적으로, 프로젝트 전반의 효율과 생산성을 한층 끌어올렸습니다.


