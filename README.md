# 서론

저는 iOS 신입 개발자로 현재 8개월째 iPad앱을 개발하며 근무 중입니다. 처음 회사에 입사했을 때 제게 주어진 미션은 기존 Objective-C 프로젝트를 Swift로 리팩토링하는 것이었습니다. 이 과정에서 많은 도전과 문제들을 마주하게 되었고, 이를 해결하기 위해 다양한 접근 방식을 시도했습니다. 이 글에서는 프로젝트 리팩토링 과정에서 직면한 문제와 이를 해결하기 위한 노력, 그리고 최종적으로 도입한 아키텍처에 대해 이야기하고자 합니다.

## **아키텍처 개선**

### **문제 발견**

프로젝트를 분석한 결과, 기존에는 아키텍처가 전혀 적용되어 있지 않았고, 팀장님 혼자서 개발을 진행하고 있었습니다. 이는 작은 팀에서는 가능한 방법이지만, 협업과 유지보수를 위해서는 체계적인 아키텍처가 필요하다고 판단했습니다. 

특히, 다음과 같은 이유로 아키텍처 도입이 필요했습니다:

- **협업 효율성 향상**: 체계적인 아키텍처는 코드의 구조를 명확하게 하여 팀원 간의 역할 분담을 쉽게 하고, 협업 시 충돌을 최소화할 수 있습니다.
- **유지보수성 향상**: 아키텍처가 적용된 프로젝트는 코드의 가독성과 재사용성이 높아져, 새로운 기능을 추가하거나 버그를 수정할 때 더 효율적으로 작업할 수 있습니다.
- **미래 대비**: 프로젝트의 규모가 커지고 팀원이 늘어나더라도 아키텍처가 잘 적용된 프로젝트는 확장성이 뛰어나기 때문에, 미래의 변화에 유연하게 대응할 수 있습니다.

백엔드 아키텍처는 도메인 주도 설계(DDD)를 기반으로 하고 있었습니다. 이를 참고하여 iOS 프로젝트에서도 DDD를 적용하고, 클린아키텍처와 단방향 흐름 MVVM 아키텍처를 도입하기로 결정했습니다.

### **아키텍처 연구 및 선택**

우선, 다양한 아키텍처 패턴에 대해 연구했습니다. 특히 클린아키텍처, VIPER, MVC, MVVM, RIBs 등을 검토했습니다. 

그 중에서 클린아키텍처를 선택한 이유는 다음과 같습니다:

1. **클린아키텍처의 장점**:
    - **의존성 역전 원칙**: 클린아키텍처는 의존성 역전을 통해 비즈니스 로직과 UI를 분리하여, 코드의 재사용성과 테스트 가능성을 높여줍니다.
    - **계층 구조**: 데이터, 도메인, 프레젠테이션 계층으로 나뉘어 있어 각 계층이 독립적으로 변경될 수 있습니다.
    - **유연성**: 새로운 요구사항이나 변경 사항이 생겼을 때, 특정 계층에만 영향을 미치므로, 전체 시스템의 안정성을 유지하면서 변경할 수 있습니다.
2. **단방향 흐름 MVVM의 장점**:
    - **데이터 바인딩**: MVVM은 단방향 데이터 흐름을 통해 View와 Model 간의 의존성을 최소화합니다. 이는 UI 업데이트를 더 직관적이고 예측 가능하게 만듭니다.
    - **테스트 용이성**: ViewModel은 UI 로직을 포함하지 않기 때문에, 독립적으로 테스트할 수 있습니다.
    - **유지보수성**: 각 컴포넌트가 명확히 분리되어 있어, 코드의 유지보수성과 확장성이 뛰어납니다.
    - **협업과 문서화**: “기능 개발 시퀀스 프로토콜”에서 모든 부서가 ViewModel을 공통적으로 개발할 수 있고, ViewModel 자체가 기획서가 될 수 있습니다. 이는 기획, 디자인, 개발, QA 팀 간의 협업을 크게 향상시킵니다.
    

다른 아키텍처와 비교하여 단방향 MVVM을 선택한 이유는 다음과 같습니다:

- **VIPER**: View, Interactor, Presenter, Entity, Router의 다섯 가지 컴포넌트로 구성되어 있습니다. 이 아키텍처는 매우 명확한 역할 분담을 제공하지만, 컴포넌트 수가 많아지고, 복잡도가 높아져 작은 팀에서는 관리가 어렵습니다. 또한, 코드베이스가 커질 수 있어 프로젝트 초기에 도입하기에는 부담이 큽니다.
- **MVC**:  간단하고 이해하기 쉬운 구조로, 많은 프로젝트에서 기본적으로 사용됩니다. 그러나 View와 Controller 간의 의존성이 강해지기 쉬워, 규모가 커질수록 유지보수가 어려워집니다. 특히, UI 로직과 비즈니스 로직이 섞이기 쉬워 테스트와 코드 관리가 어렵습니다.
- **RIBs**: 모듈화와 독립적인 테스트를 강조하며, Uber에서 개발된 아키텍처입니다. 이 아키텍처는 강력한 모듈화를 제공하지만, 초기 설정과 학습 곡선이 매우 높아 작은 팀이나 간단한 프로젝트에는 적합하지 않을 수 있습니다. 하지만 궁극적으로 모듈화와 MFA(마이크로 프론트엔드 아키텍처)를 도입하기 위해 꾸준하게 학습하면 좋을것 같다고 생각하고 있습니다.
- **MVVM**: 단방향 데이터 흐름을 강조하는 MVVM 아키텍처는 ViewModel을 통해 View와 Model 간의 명확한 분리를 제공합니다. 이는 데이터 바인딩을 통해 UI 업데이트를 예측 가능하게 하며, 테스트 용이성과 유지보수성을 높여줍니다. 또한, MVVM은 비교적 간단하게 구현할 수 있어 팀원들이 빠르게 적응할 수 있었습니다. 특히, “기능 개발 시퀀스 프로토콜”에서 모든 부서가 ViewModel을 공통적으로 개발할 수 있고, ViewModel 자체가 기획서가 될 수 있어 협업과 문서화 측면에서 큰 장점이 있습니다.

이러한 이유로, 클린아키텍처와 단방향 흐름 MVVM을 선택하여 프로젝트의 구조를 체계적으로 만들고, 협업과 유지보수를 용이하게 하였습니다.

### **MVVM 아키텍처 설명**

![아키텍처1](https://github.com/user-attachments/assets/ebc7437b-9ad5-4db2-96e9-bd25cedce9a5)

![아키텍처2](https://github.com/user-attachments/assets/8c130ff7-b810-4e80-8e3d-3c59785b6306)


위 이미지는 MVVM (Model-View-ViewModel) 아키텍처를 기반으로 한 클래스 다이어그램을 나타내고 있습니다. 각 컴포넌트는 명확한 역할을 가지고 있으며, 이들 간의 상호작용을 통해 프로젝트의 구조를 체계적으로 구성합니다.

1. **DI Container**
    - 특정 기능 모듈에 대한 의존성을 주입하는 컨테이너입니다. 이를 통해 각 모듈이 독립적으로 의존성을 관리할 수 있습니다.
2. **ViewController**
    - 사용자의 입력을 받아 ViewModel에 전달하고, ViewModel로부터 데이터를 받아 View를 업데이트합니다.
3. **View**
    - ViewModel로부터 전달받은 데이터를 기반으로 UI를 업데이트합니다.
4. **ViewModel**
    - 사용자 입력을 처리하고, Model의 데이터를 가공하여 View에 전달합니다.
5. **Model**
    - 데이터와 관련된 모든 작업을 수행합니다.
6. **ModelUseCase**
    - Model에서 사용하는 비즈니스 로직을 정의합니다. Model의 데이터를 조작하거나 처리하는 역할을 합니다. 이 클래스는 BFF(Backend for Frontend)의 역할을 대신하며, Repository를 통해 API를 호출하고 받아온 DTO를 변환하여 화면에서 사용할 Model을 반환하는 역할을 합니다.
    - ModelUseCase를 도입한 이유는 현재는 BFF를 도입할 인력이 부족하지만, 회사가 발전하여 BFF를 도입하게 되었을 때를 대비하기 위해서입니다. 이를 통해 미래의 확장을 용이하게 만들 수 있습니다.
7. **Repository**
    - API 서비스나 로컬 데이터베이스와 통신합니다.
8. **API Service**
    - 외부 네트워크와 통신하여 데이터를 주고받는 서비스입니다.

### **클래스 간의 상호작용**

- **DI Container**: DI Container는 ViewController, View, ViewModel, Model 등 다양한 컴포넌트에 의존성을 주입합니다.
- **ViewController와 View**: ViewController는 View의 참조를 가지고 있으며, ViewModel로부터 데이터를 받아 View를 업데이트합니다.
- **ViewController와 ViewModel**: ViewController는 ViewModel의 참조를 가지고 있으며, 사용자의 입력을 ViewModel에 전달합니다.
- **ViewModel과 Model**: ViewModel은 Model의 데이터를 가공하여 View에 전달하며, 비즈니스 로직을 처리합니다.
- **Model과 ModelUseCase**: ModelUseCase는 Repository를 통해 API를 호출하고, 받아온 데이터를 화면에서 사용할 수 있는 Model로 변환합니다.
- **ModelUseCase와 Repository**: ModelUseCase는 Repository를 통해 데이터 소스에 접근합니다.
- **Repository와 API Service**: Repository는 API Service와 통신하여 데이터를 주고받습니다.

### 결론

이를 통해 코드의 유지보수성과 확장성을 높일 수 있었으며, 각 컴포넌트가 독립적으로 테스트될 수 있게 되었습니다. 이러한 구조 덕분에 개발팀은 보다 신속하고 효율적으로 버그를 수정하고 새로운 기능을 추가할 수 있게 되었습니다. 또한, 이번 아키텍처 개선을 통해 추후 모듈화와 MFA(Micro Frontend Architecture) 도입을 위한 기반을 마련할 수 있었습니다.

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
