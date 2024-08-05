### UIFusionKit의 State Data Flow

![ViewModelFlow](https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17)

ReactorKit과 TCA의 단방향 플로우와 상태 기반 흐름은 유사합니다. 

하지만 차이점이 있다면 ViewModel을 사용하는 부분에 있어서 특정 라이브러리나 특정 프레임워크에 종속적이지 않도록 개발했습니다.

### ViewModelProtocol

```swift
protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Action
    associatedtype State

    var state: State { get set }
    func send(_ input: Input)
    func transform(_ input: Input) -> [Action]
    func perform(_ action: Action)
}

extension ViewModelProtocol {
    func send(_ input: Input) {
            transform(input)
                .forEach { action in
                    perform(action)
                }
    }
}
```


## **UIFusionKit 개발 및 도입**

### **문제 발견**

새로운 아키텍처 위에서 신규 기능을 개발하면서 몇 가지 불편함이 있었습니다. 그 중 하나는 UIKit에서 InterActive한 Animation을 적용하기 위해 신경 써야 할 부분이 너무 많다는 것이었습니다. 
애니메이션 효과를 많이 사용하게 되는 화면은 부분적으로 SwiftUI로 개발하기 위해 UIKit과 SwiftUI에서 상호 운영이 가능한 ViewModel이 필요했습니다.

### MVVM 조사

MVVM 아키텍처에 대해 공부를 하던 중 아래와 같은 이미지를 접하게 되었습니다.

![mvvm조사](https://github.com/user-attachments/assets/9d717d7c-ba72-4d21-a0fb-de67227db3e4)

SwiftUI에서 View는 이미 ViewModel의 역할을 하고 있기 때문에 ViewModel on ViewModel이라는 비효율이 발생한다는 의견이 많았습니다. Apple이 이야기하는 SwiftUI에서의 State Data Flow도 비슷한 문제를 제기했습니다.

![스유데이터플로우](https://github.com/user-attachments/assets/313ed2b4-952c-4d9b-8e5f-190624872ec3)

SwiftUI에서의 State Data Flow

위 이미지를 보니 어디선가 많이 본 그림이라는 생각이 들었습니다. 아래는 ReactorKit과 TCA의 State Data Flow입니다.

![리액터킷](https://github.com/user-attachments/assets/c9cc6eaf-3481-4a38-85ea-18f60693684e)

ReactorKit의 State Data Flow

![tca](https://github.com/user-attachments/assets/3a58b5bd-c93a-489f-8919-f148844357af)

TCA의 State Data Flow

위 세 가지 구조의 공통점은 다음과 같습니다:

1. 단방향 흐름
2. State
3. Mutation

기존 UIKit에서 많은 사람들이 MVVM 아키텍처를 사용할 때 ReactorKit을 많이 사용하는 이유를 조사했습니다. MVVM 아키텍처는 구현 방법에 대한 규칙이 없어서 통일성과 데이터 흐름에 대한 추적이 어려운 문제가 있었습니다. 이에 반해 ReactorKit은 사용해야 하는 규칙이 정해져 있고, 단방향 데이터 흐름으로 뷰와 모델의 상태 변화를 추적하기 용이하다는 장점이 있습니다.

이러한 이유들로 인해 MVVM 하면 단방향 흐름과 Composable Architecture를 많이 사용하는 것 같았고, 자연스럽게 SwiftUI에서도 비슷한 구조를 가지게 된 것 같습니다.

### Composable Architecture 구상

그렇다면 SwiftUI에서 View가 이미 ViewModel의 역할을 하고 있다면 왜 TCA를 사용하게 되는 것인지 고민해봤습니다. 이는 ReactorKit을 사용하는 것과 마찬가지로 사용해야 하는 규칙을 정하기 위해서 사용하는 것이라고 생각했습니다.

하지만 SwiftUI에서는 ReactorKit을 사용할 수 없고, UIKit에서는 TCA를 사용할 수 없는 문제가 있었습니다. ReactorKit은 View라는 프로토콜을 채택하고 RxSwift를 사용하기 때문에 SwiftUI와 함께 사용할 수 없고, TCA는 View의 상태 기반을 사용하기 때문에 UIKit에서 사용할 수 없습니다.

저희 회사 프로젝트에서는 기존 기능은 UIKit으로 유지하고, 신규 기능은 SwiftUI로 개발해야 하는 상황에서 어떤 디자인 아키텍처 라이브러리를 사용해야 할지 혼란스러웠습니다. 

그래서 Combine을 사용하여 Composable Architecture를 만들어 UIKit과 SwiftUI의 통합을 위해 UIFusionKit이라는 라이브러리를 개발했습니다.

### UIFusionKit의 State Data Flow

![ViewModelFlow](https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17)

ReactorKit과 TCA의 단방향 플로우와 상태 기반 흐름은 유사합니다. 

하지만 차이점이 있다면 ViewModel을 사용하는 부분에 있어서 특정 라이브러리나 특정 프레임워크에 종속적이지 않도록 개발했습니다.

### ViewModelProtocol

```swift
protocol ViewModelProtocol: AnyObject {
    associatedtype Input
    associatedtype Action
    associatedtype State

    var state: State { get set }
    func send(_ input: Input)
    func transform(_ input: Input) -> [Action]
    func perform(_ action: Action)
}

extension ViewModelProtocol {
    func send(_ input: Input) {
            transform(input)
                .forEach { action in
                    perform(action)
                }
    }
}
```

viewModel의 send(_ input:) 메서드를 통해 Input Event를 전달합니다.

 send(_ input:) 메서드는 input을 받아 transform(_ input:) 메서드를 실행하고 Input → Action으로 이벤트를 변형시킵니다. 

transform(_ input:) 메서드는 여러 Action 이벤트를 발생시킬 수 있습니다. 

perform(_ action:) 메서드는 특정 로직을 수행하고 State 상태를 변경시킬 수 있고, SideEffect를 발생시킬 수 있습니다.

이로써 RxSwift, Combine에 종속적이지 않고, UIKit과 SwiftUI에 종속적이지 않은 독립적인 디자인 아키텍처를 적용할 수 있습니다.

ViewModel이 Input, Action, State 세 가지 상태를 가지고 있는 이유는, 기획팀, 디자인팀, 개발팀, QA팀에서 ViewModel을 공통적으로 개발하고 사용하기 위합입니다.

### ViewModel 기획서 예시

<img width="231" alt="예시화면" src="https://github.com/user-attachments/assets/f08a878a-c23c-40fc-b8f9-42cdc25b9373">


위 화면에서는 Increase, Decrease, Reset, Show 버튼이 있습니다. 

각 버튼을 눌렀을 때 화면의 상태를 변경시켜야 합니다. 

이 화면을 만들기 위해 각 버튼을 눌렀을 때 어떤 변화를 발생시켜야 하는지 기획서가 필요합니다. 

기획서에서 어떤 Input이 입력됐을 때 어떤 Action을 취하고 어떤 화면의 State가 바뀌어야 하는지 요구사항이 필요합니다. 

아래와 같은 방법으로 간단하게 기획서를 작성해볼 수 있습니다.

### 입력&출력

**Input:** 🟩

**Action:** ✴️

**State:** 🟦

---

**주요 기능**

**❇🟩: increase** 버튼 선택

- **✴️:** increaseValue
    - **🟦:** value 값이 1 증가합니다.
    - 🟦: isReset 값이 false로 설정됩니다.

**❇🟩:** decrease 버튼 선택

- **✴️**: decreaseValue
    - **🟦:** value 값이 1 감소합니다.
    - 🟦: isReset 값이 false로 설정됩니다.

**🟩** reset 버튼 선택

- **✴️**: resetValue
    - **🟦:** value 값이 0으로 초기화됩니다.
    - **🟦:** isReset 값이 true로 설정됩니다.

**🟩**: show 버튼 선택

- **✴️**: showAlert
    - **🟦:** showAlert 값이 트리거됩니다.

위와 같은 방식으로 ViewModel 기획서를 작성하게 되면

개발팀에서는 1:1대응되는 ViewModel을 다음과 같이 개발할 수 있습니다.

```swift
enum CounterInput {
    case increase
    case decrease
    case reset
    case show
}

enum CounterAction {
    case increaseValue
    case decreaseValue
    case resetValue
    case showAlert
}

class CounterState: ObservableObject {
    @Published var value: Int = 0
    @Published var isReset: Bool = false
    @Published var showAlert: Void = ()
}

protocol CounterViewModel: ViewModelProtocol where
Input == CounterInput,
Action == CounterAction,
State == CounterState {}

final class DefaultCounterViewModel: CounterViewModel {
    @Published var state: State = .init()
    var cancellabels: Set<AnyCancellable> = .init()
    
    
    func transform(_ input: Input) -> [Action] {
        switch input {
            case .increase:
                return [.increaseValue]
            case .decrease:
                return [.decreaseValue]
            case .reset:
                return [.resetValue]
            case .show:
                return [.showAlert]
        }
    }
    
    func perform(_ action: Action) {
        switch action {
            case .increaseValue:
                state.value += 1
                state.isReset = false
            case .decreaseValue:
                state.value -= 1
                state.isReset = false
            case .resetValue:
                state.value = 0
                state.isReset = true
            case .showAlert:
                state.showAlert = ()
        }
    }
}
```

UIFusionKit은 다음과 같은 장점이 있습니다:

- **Composable MVVM**: UIKit과 SwiftUI 양쪽에서 동일한 ViewModel을 사용하여 일관된 로직과 상태 관리를 구현할 수 있습니다.
- **단방향 데이터 플로우**: 상태 관리를 명확하게 하고, 데이터의 흐름을 예측 가능하게 하여 UI 업데이트를 직관적이고 예측 가능하게 만듭니다.
- **유연성**: 두 플랫폼을 동시에 지원하여 팀원들이 점차적으로 SwiftUI에 익숙해질 수 있도록 지원합니다.
- 통합: 기획팀, 디자인팀, 개발팀, QA팀에서 기획서를 공용해서 개발 가능합니다.

### 결론

이로써 기존 코드의 재사용성을 높이고, 새로운 기능을 더 쉽게 개발할 수 있게 되었습니다.


