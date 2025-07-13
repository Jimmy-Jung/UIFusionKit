//
//  CounterView.swift
//  
//
//  Created by 정준영 on 2024/8/4.
//

import SwiftUI

struct CounterView: View {
    @StateObject private var viewModel: CounterAsyncViewModel
    
    init(_ viewModel: CounterAsyncViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: .DS.sectionSpacing) {
            CounterDisplayView(
                value: viewModel.value,
                description: "허용 범위: -10 ~ 10"
            )
            
            CounterActionsView(
                isIncreaseLoading: viewModel.loadingState == .increasing,
                isDecreaseLoading: viewModel.loadingState == .decreasing,
                onIncrease: { viewModel.send(.increase) },
                onDecrease: { viewModel.send(.decrease) },
                onReset: { viewModel.send(.reset) },
                onShow: { viewModel.send(.show) }
            )
        }
        .padding(.DS.lg)
        .background(Color.DS.background)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// 기존 ButtonView는 새로운 ActionButton 컴포넌트로 대체되었습니다.

@available(iOS 17.0, *)
#Preview {
    CounterView(CounterAsyncViewModel())
}
