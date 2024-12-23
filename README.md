## 미리보기
### UIFusionKit의 State Data Flow
<img width="831" alt="ViewModelFlow" src="https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17">

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
## UIFusionKit 장점
UIFusionKit은 다음과 같은 장점이 있습니다:

- **Composable MVVM**: UIKit과 SwiftUI 양쪽에서 동일한 ViewModel을 사용하여 일관된 로직과 상태 관리를 구현할 수 있습니다.
- **단방향 데이터 플로우**: 상태 관리를 명확하게 하고, 데이터의 흐름을 예측 가능하게 하여 UI 업데이트를 직관적이고 예측 가능하게 만듭니다.
- **유연성**: 두 플랫폼을 동시에 지원하여 팀원들이 점차적으로 SwiftUI에 익숙해질 수 있도록 지원합니다.
- 통합: 기획팀, 디자인팀, 개발팀, QA팀에서 기획서를 공용해서 개발 가능합니다.
  
# **UIFusionKit 개발 및 도입**

## **문제 발견**
[새로운 아키텍처](https://github.com/Jimmy-Jung/ReadeMe/tree/main/CleanArchitecture) 위에서 신규 기능을 개발하면서 가장 크게 느낀 문제는, 
 
UIKit에서 인터랙티브한 애니메이션을 적용하기 위해 신경 쓸 부분이 너무 많다는 것이었습니다. 
 
일부 화면에서는 애니메이션 효과가 중요했지만, 동시에 SwiftUI의 장점을 활용하고자 UIKit과 SwiftUI를 혼용해야 했습니다. 

자연스럽게 UIKit과 SwiftUI에서 동일하게 동작할 수 있는 ViewModel이 필요해졌습니다.

## MVVM 조사

이 문제를 해결하기 위해 MVVM 아키텍처를 다시 살펴보았습니다. 
일반적으로 MVVM은 퍼블리셔나 디자이너와 협업하기 위해 View 로직과 비즈니스 로직을 분리하는 데 활용됩니다. 

<img width="631" alt="mvvm조사" src="https://github.com/user-attachments/assets/9d717d7c-ba72-4d21-a0fb-de67227db3e4">

하지만 SwiftUI는 이미 View가 ViewModel 역할을 일정 부분 수행하고 있어 ‘ViewModel on ViewModel’이라는 비효율 논란이 있었습니다.
SwiftUI는 이미 View가 ViewModel 역할을 일정 부분 수행하고 있어 ‘ViewModel on ViewModel’이라는 비효율 논란이 있었습니다.

왜 논란이 되었을까 고민해보니, 전통적인 MVVM에서 ViewModel이 담당해야 할 상태 관리와 로직을 SwiftUI가 자체적으로 ‘View에서’ 대부분 처리하기 때문에,
별도의 ViewModel을 추가로 두는 경우 “중복 구조” 혹은 “이중 관리”가 발생할 가능성이 높습니다. 

이는 코드 규모가 불필요하게 커지거나, 이벤트 흐름이 View와 ViewModel 사이에서 중첩되어 추적이 어려워지는 문제로 이어질 수 있습니다.

<img width="631" alt="스유데이터플로우" src="https://github.com/user-attachments/assets/313ed2b4-952c-4d9b-8e5f-190624872ec3">

SwiftUI에서의 State Data Flow

하지만 SwiftUI가 제공하는 단방향 상태 관리(State Data Flow)를 살펴보면,
이는 기존 MVVM에서 강조하던 ‘단방향 데이터 흐름’을 SwiftUI 문법에 맞춰 재해석해 이미 내장해두었다고 볼 수 있습니다. 

결국, 굳이 별도의 ViewModel 계층을 두지 않고도 View가 @State, @Binding, @ObservedObject(또는 @StateObject) 등을 통해 상태를 관찰하고, 
상태 변화 시 UI를 자동 갱신하도록 하는 구조가 마련되어 있습니다.

즉, SwiftUI만 단독으로 사용한다면 전통적인 “ViewModel on ViewModel” 문제를 크게 걱정하지 않아도 되는 것이죠.
View가 이미 상태와 로직 일부를 책임져 불필요한 중복을 줄여 주기 때문입니다.

다만 대규모 프로젝트나 복잡한 비즈니스 로직을 처리해야 할 경우에는,
TCA(The Composable Architecture)나 Clean Architecture 등을 통해 아키텍처적 계층 분리를 더 선명히 가져가기도 합니다. 

이때 SwiftUI가 제공하는 단방향 상태 관리와 자동 UI 갱신 기능을 그대로 활용하면서, 
비즈니스 로직을 담은 별도 계층(Model이나 Domain 레이어 등)을 분리해 “ViewModel on ViewModel” 문제가 다시 불거지지 않도록 할 수 있습니다.

결국 ‘ViewModel on ViewModel’ 논란은 SwiftUI가 원래 MVVM-like 구조를 갖춘 상태에서, 개발자가 추가로 ViewModel 계층을 과도하게 만들면 생기는 중복이라는 결론을 얻었습니다.
SwiftUI만의 State Data Flow를 충분히 이해하고 활용한다면, 효율적인 상태 관리가 가능하고, 필요 시 다른 아키텍처 기법(Clean Architecture, TCA 등)을 조합해 유연하게 확장할 수도 있습니다.


SwiftUI만으로 앱을 구성한다면, View가 일부 ViewModel 역할을 흡수하여 ‘ViewModel on ViewModel’ 문제를 크게 줄일 수 있습니다. 

하지만 기존 프로젝트나 UIKit과 병행 사용해야 하는 상황이라면, SwiftUI의 단방향 상태 관리만으로는 일부 한계가 있을 수 있습니다.

<img width="631" alt="ReactorKit의 State Data Flow" src="https://github.com/user-attachments/assets/c9cc6eaf-3481-4a38-85ea-18f60693684e">

ReactorKit의 State Data Flow

특히 기존 UIKit 프로젝트에서 MVVM을 적용할 때는 ReactorKit과 같은 라이브러리를 자주 사용하는데, 
이는 사용 규칙이 명확하고 단방향 데이터 플로우를 통해 뷰와 모델 간 상태 변화를 쉽게 추적할 수 있기 때문입니다.

그러나 ReactorKit은 RxSwift 기반의 View 프로토콜을 사용하기 때문에 SwiftUI와 바로 호환하기 어려운 문제가 있고, 

<img width="631" alt="tca" src="https://github.com/user-attachments/assets/3a58b5bd-c93a-489f-8919-f148844357af">

TCA의 State Data Flow

TCA는 SwiftUI에 특화된 구조를 기반으로 하므로 UIKit에 적용하기 힘든 부분이 존재합니다.

다시 말해, SwiftUI와 UIKit을 동시에 쓰거나, 기존의 UIKit 코드를 단계적으로 SwiftUI로 전환하려는 팀은 ReactorKit이나 TCA 단독으로는 대응하기 어려운 지점이 발생하게 됩니다. 
따라서 이러한 문제를 해결하고자, SwiftUI와 UIKit 모두에서 동일한 ViewModel을 사용하고 단방향 흐름을 유지하기 위한 별도의 접근법이 필요해졌습니다.


## UIFusionKit의 State Data Flow

<img width="631" alt="ViewModelFlow" src="https://github.com/user-attachments/assets/6affddb7-bd58-4b6f-b203-f201336cad17">

### ViewModelFlow

ReactorKit과 TCA의 단방향 플로우, 상태 기반 흐름과 유사하지만, 특정 라이브러리나 특정 프레임워크에 종속적이지 않도록 구현한 점이 핵심입니다.

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

## ViewModel 사용 방법

1.	viewModel.send(_ input:) 메서드를 통해 Input Event를 전달합니다.
2.	transform(_ input:) 메서드를 통해 Input → Action으로 변환합니다. (하나의 Input이 여러 Action으로 분기 가능)
3.	perform(_ action:) 메서드에서 State를 변경하거나 SideEffect를 발생시킵니다.

이를 통해 RxSwift, Combine 등 특정 라이브러리나 UIKit, SwiftUI에 구애받지 않는 독립적인 디자인 아키텍처를 유지할 수 있습니다.

### ViewModel이 Input, Action, State 세 가지 상태를 가지는 이유

기획팀·디자인팀·개발팀·QA팀이 공통 기획서를 기준으로 각자 역할에 맞춰 협업하기 위함입니다. 
예컨대 기획서는 입력(Input)과 상태(State)에 대한 정의를 중심으로 잡고, 그에 맞춰 Action(구현 로직)을 설계·개발·테스트할 수 있습니다.

## ViewModel 기획서 예시

<img width="331" alt="예시화면" src="https://github.com/user-attachments/assets/f08a878a-c23c-40fc-b8f9-42cdc25b9373">

예시 화면: Increase, Decrease, Reset, Show 버튼

### 입력&상태

**Input:** 🟩 ㅤㅤ**Action:** ✴️ ㅤㅤ **State:** 🟦


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

이를 바탕으로 개발팀은 아래와 같은 ViewModel을 작성할 수 있습니다.

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

---

## 기획서 활용

1.	기획팀은 화면에서 발생하는 입력(Input)과 이에 따른 상태(State)를 정의합니다.
2.	개발팀은 해당 기획서의 액션(Action)을 구체화하여 ViewModel에 로직을 구현합니다.
3.	QA팀은 상태(State)를 기준으로 테스트 시나리오를 작성합니다.
4.	디자인팀은 요구사항에 맞춰 UI를 설계합니다.

이로서 하나의 기획서를 모든 부서가 공통으로 사용하면서 협력해서 기획서를 발전시켜나갈 수 있게됩니다.
입력(Input) & 상태(State) 기획서를 인터페이스 형태로 작성함으로써 다음과 같은 효과를 누릴 수 있게 되었습니다.

### SOLID 원칙과 입력(Input) & 상태(State) 기획서
 1.	SRP(단일 책임 원칙)
    - 각 부서가 Input/State 구조에 맞춰 자신만의 책임에 집중할 수 있습니다.
 5.	OCP(개방 폐쇄 원칙)
    - 기능 추가·제거 시에도 기존 기획서를 크게 수정하지 않고 확장·추가가 가능합니다.
 6.	LSP(리스코프 치환 원칙)
    - 기존 ViewModel을 유지하면서도 하위 타입으로 확장하거나 교체하기 쉽습니다.
 7.	ISP(인터페이스 분리 원칙)
    - 기획팀, 디자인팀, 개발팀, QA팀이 필요로 하는 인터페이스에만 집중할 수 있습니다.
 9.	DIP(의존성 역전 원칙)
    - ViewModel은 추상화된 Input/State 구조에 의존하므로, UI나 구체적인 라이브러리에 종속되지 않습니다.


### 결론

UIFusionKit은 기존 코드 재사용성을 높이고, 기획·디자인·개발·QA 각 부서가 명확한 역할 분담을 통해 협력할 수 있도록 돕습니다. 
또한 MVVM + Clean Architecture를 결합해 TDD를 가능케 하고, 공통 ‘Input/State 기획서’를 기반으로 빠르고 정확하게 요구사항을 구현할 수 있습니다. 
결과적으로, 프로젝트 전반의 효율과 생산성을 한층 끌어올렸습니다.


