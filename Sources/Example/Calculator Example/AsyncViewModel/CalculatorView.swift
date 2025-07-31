//
//  CalculatorView.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import SwiftUI

struct CalculatorView: View {
    @StateObject private var viewModel: CalculatorAsyncViewModel
    
    init(_ viewModel: CalculatorAsyncViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .DS.lg) {
            // 디스플레이 영역
            CalculatorDisplayView(display: viewModel.display)
            
            // 버튼 그리드
            CalculatorButtonsView(
                onNumberTap: { number in
                    viewModel.send(.number(number))
                },
                onOperationTap: { operation in
                    viewModel.send(.operation(operation))
                },
                onEqualsTap: {
                    viewModel.send(.equals)
                },
                onClearTap: {
                    viewModel.send(.clear)
                }
            )
        }
        .padding(.DS.lg)
        .background(Color.DS.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(item: $viewModel.activeAlert) { alertType in
            switch alertType {
            case .error(let error):
                return Alert(
                    title: Text("오류"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("확인")) {
                        viewModel.send(.dismissAlert)
                    }
                )
            }
        }
    }
}

// 계산기 디스플레이 컴포넌트
struct CalculatorDisplayView: View {
    let display: String
    
    var body: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                Text(display)
                    .font(.system(size: 48, weight: .light, design: .default))
                    .foregroundColor(.DS.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityIdentifier("calculator_display")
            }
        }
        .frame(height: 120)
        .padding(.horizontal, .DS.lg)
        .background(
            RoundedRectangle(cornerRadius: .DS.buttonRadius)
                .fill(Color.DS.surface)
        )
    }
}

// 계산기 버튼 그리드 컴포넌트
struct CalculatorButtonsView: View {
    let onNumberTap: (Int) -> Void
    let onOperationTap: (CalculatorOperation) -> Void
    let onEqualsTap: () -> Void
    let onClearTap: () -> Void
    
    private let buttonSpacing: CGFloat = 12
    
    var body: some View {
        VStack(spacing: buttonSpacing) {
            // 첫 번째 행: C, ÷
            HStack(spacing: buttonSpacing) {
                CalculatorButton(
                    title: "C",
                    backgroundColor: .orange,
                    accessibilityId: "clear_button",
                    action: onClearTap
                )
                
                Spacer()
                Spacer()
                
                CalculatorButton(
                    title: "÷",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_divide",
                    action: { onOperationTap(.divide) }
                )
            }
            
            // 두 번째 행: 7, 8, 9, ×
            HStack(spacing: buttonSpacing) {
                CalculatorButton(
                    title: "7",
                    accessibilityId: "number_button_7",
                    action: { onNumberTap(7) }
                )
                
                CalculatorButton(
                    title: "8",
                    accessibilityId: "number_button_8",
                    action: { onNumberTap(8) }
                )
                
                CalculatorButton(
                    title: "9",
                    accessibilityId: "number_button_9",
                    action: { onNumberTap(9) }
                )
                
                CalculatorButton(
                    title: "×",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_multiply",
                    action: { onOperationTap(.multiply) }
                )
            }
            
            // 세 번째 행: 4, 5, 6, -
            HStack(spacing: buttonSpacing) {
                CalculatorButton(
                    title: "4",
                    accessibilityId: "number_button_4",
                    action: { onNumberTap(4) }
                )
                
                CalculatorButton(
                    title: "5",
                    accessibilityId: "number_button_5",
                    action: { onNumberTap(5) }
                )
                
                CalculatorButton(
                    title: "6",
                    accessibilityId: "number_button_6",
                    action: { onNumberTap(6) }
                )
                
                CalculatorButton(
                    title: "-",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_subtract",
                    action: { onOperationTap(.subtract) }
                )
            }
            
            // 네 번째 행: 1, 2, 3, +
            HStack(spacing: buttonSpacing) {
                CalculatorButton(
                    title: "1",
                    accessibilityId: "number_button_1",
                    action: { onNumberTap(1) }
                )
                
                CalculatorButton(
                    title: "2",
                    accessibilityId: "number_button_2",
                    action: { onNumberTap(2) }
                )
                
                CalculatorButton(
                    title: "3",
                    accessibilityId: "number_button_3",
                    action: { onNumberTap(3) }
                )
                
                CalculatorButton(
                    title: "+",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_add",
                    action: { onOperationTap(.add) }
                )
            }
            
            // 다섯 번째 행: 0, =
            HStack(spacing: buttonSpacing) {
                CalculatorButton(
                    title: "0",
                    accessibilityId: "number_button_0",
                    action: { onNumberTap(0) }
                )
                
                Spacer()
                
                CalculatorButton(
                    title: "=",
                    backgroundColor: .green,
                    accessibilityId: "equals_button",
                    action: onEqualsTap
                )
            }
        }
    }
}

// 개별 계산기 버튼 컴포넌트
struct CalculatorButton: View {
    let title: String
    let backgroundColor: Color
    let accessibilityId: String
    let action: () -> Void
    
    init(title: String, backgroundColor: Color = .gray, accessibilityId: String = "", action: @escaping () -> Void) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.accessibilityId = accessibilityId
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .aspectRatio(1, contentMode: .fit)
        }
        .frame(height: 60)
        .background(
            RoundedRectangle(cornerRadius: .DS.buttonRadius)
                .fill(backgroundColor)
        )
        .accessibilityIdentifier(accessibilityId)
    }
}

@available(iOS 17.0, *)
#Preview {
    CalculatorView(CalculatorAsyncViewModel())
} 
