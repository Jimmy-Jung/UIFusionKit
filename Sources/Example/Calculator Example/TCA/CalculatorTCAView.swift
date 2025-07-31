//
//  CalculatorTCAView.swift
//
//
//  Created by Assistant on 2024/12/19.
//

import SwiftUI
import ComposableArchitecture

struct CalculatorTCAView: View {
    let store: StoreOf<CalculatorFeature>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: .DS.lg) {
                // 디스플레이 영역
                CalculatorTCADisplayView(
                    display: viewStore.display,
                    isAutoClearActive: viewStore.isAutoClearTimerActive
                )
                
                // 버튼 그리드
                CalculatorTCAButtonsView(
                    onNumberTap: { number in
                        viewStore.send(.numberTapped(number))
                    },
                    onOperationTap: { operation in
                        viewStore.send(.operationTapped(operation))
                    },
                    onEqualsTap: {
                        viewStore.send(.equalsTapped)
                    },
                    onClearTap: {
                        viewStore.send(.clearTapped)
                    }
                )
            }
            .padding(.DS.lg)
            .background(Color.DS.background)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .alert(
                item: Binding<CalculatorFeature.State.AlertType?>(
                    get: { viewStore.activeAlert },
                    set: { _ in viewStore.send(.dismissAlert) }
                )
            ) { alertType in
                switch alertType {
                case .error(let error):
                    return Alert(
                        title: Text("오류"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("확인")) {
                            viewStore.send(.dismissAlert)
                        }
                    )
                }
            }
        }
    }
}

// MARK: - TCA 계산기 디스플레이 컴포넌트
struct CalculatorTCADisplayView: View {
    let display: String
    let isAutoClearActive: Bool
    
    var body: some View {
        VStack {
            // 자동 클리어 타이머 상태 표시
            if isAutoClearActive {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                    Text("5초 후 자동 클리어됩니다")
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Text(display)
                    .font(.system(size: 48, weight: .light, design: .default))
                    .foregroundColor(.DS.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .accessibilityIdentifier("calculator_display_tca")
            }
        }
        .frame(height: isAutoClearActive ? 140 : 120)
        .padding(.horizontal, .DS.lg)
        .background(
            RoundedRectangle(cornerRadius: .DS.buttonRadius)
                .fill(Color.DS.surface)
                .overlay(
                    // 자동 클리어 활성화 시 테두리 효과
                    RoundedRectangle(cornerRadius: .DS.buttonRadius)
                        .stroke(isAutoClearActive ? Color.orange.opacity(0.6) : Color.clear, lineWidth: 2)
                )
        )
        .animation(.easeInOut(duration: 0.3), value: isAutoClearActive)
    }
}

// MARK: - TCA 계산기 버튼 그리드 컴포넌트
struct CalculatorTCAButtonsView: View {
    let onNumberTap: (Int) -> Void
    let onOperationTap: (CalculatorOperation) -> Void
    let onEqualsTap: () -> Void
    let onClearTap: () -> Void
    
    private let buttonSpacing: CGFloat = 12
    
    var body: some View {
        VStack(spacing: buttonSpacing) {
            // 첫 번째 행: C, ÷
            HStack(spacing: buttonSpacing) {
                CalculatorTCAButton(
                    title: "C",
                    backgroundColor: .orange,
                    accessibilityId: "clear_button_tca",
                    action: onClearTap
                )
                
                Spacer()
                Spacer()
                
                CalculatorTCAButton(
                    title: "÷",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_divide_tca",
                    action: { onOperationTap(.divide) }
                )
            }
            
            // 두 번째 행: 7, 8, 9, ×
            HStack(spacing: buttonSpacing) {
                CalculatorTCAButton(
                    title: "7",
                    accessibilityId: "number_button_7_tca",
                    action: { onNumberTap(7) }
                )
                
                CalculatorTCAButton(
                    title: "8",
                    accessibilityId: "number_button_8_tca",
                    action: { onNumberTap(8) }
                )
                
                CalculatorTCAButton(
                    title: "9",
                    accessibilityId: "number_button_9_tca",
                    action: { onNumberTap(9) }
                )
                
                CalculatorTCAButton(
                    title: "×",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_multiply_tca",
                    action: { onOperationTap(.multiply) }
                )
            }
            
            // 세 번째 행: 4, 5, 6, -
            HStack(spacing: buttonSpacing) {
                CalculatorTCAButton(
                    title: "4",
                    accessibilityId: "number_button_4_tca",
                    action: { onNumberTap(4) }
                )
                
                CalculatorTCAButton(
                    title: "5",
                    accessibilityId: "number_button_5_tca",
                    action: { onNumberTap(5) }
                )
                
                CalculatorTCAButton(
                    title: "6",
                    accessibilityId: "number_button_6_tca",
                    action: { onNumberTap(6) }
                )
                
                CalculatorTCAButton(
                    title: "-",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_subtract_tca",
                    action: { onOperationTap(.subtract) }
                )
            }
            
            // 네 번째 행: 1, 2, 3, +
            HStack(spacing: buttonSpacing) {
                CalculatorTCAButton(
                    title: "1",
                    accessibilityId: "number_button_1_tca",
                    action: { onNumberTap(1) }
                )
                
                CalculatorTCAButton(
                    title: "2",
                    accessibilityId: "number_button_2_tca",
                    action: { onNumberTap(2) }
                )
                
                CalculatorTCAButton(
                    title: "3",
                    accessibilityId: "number_button_3_tca",
                    action: { onNumberTap(3) }
                )
                
                CalculatorTCAButton(
                    title: "+",
                    backgroundColor: .blue,
                    accessibilityId: "operation_button_add_tca",
                    action: { onOperationTap(.add) }
                )
            }
            
            // 다섯 번째 행: 0, =
            HStack(spacing: buttonSpacing) {
                CalculatorTCAButton(
                    title: "0",
                    accessibilityId: "number_button_0_tca",
                    action: { onNumberTap(0) }
                )
                
                Spacer()
                
                CalculatorTCAButton(
                    title: "=",
                    backgroundColor: .green,
                    accessibilityId: "equals_button_tca",
                    action: onEqualsTap
                )
            }
        }
    }
}

// MARK: - TCA 개별 계산기 버튼 컴포넌트
struct CalculatorTCAButton: View {
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

// MARK: - Preview
@available(iOS 17.0, *)
#Preview {
    CalculatorTCAView(
        store: Store(initialState: CalculatorFeature.State()) {
            CalculatorFeature()
        }
    )
} 