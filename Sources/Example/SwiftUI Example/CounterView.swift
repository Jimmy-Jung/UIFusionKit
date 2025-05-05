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
        VStack(spacing: 20) {
            Text("Value: \(viewModel.value)")
                .font(.system(size: 20, weight: .semibold))
            
            Text("허용 범위: -10 ~ 10")
                .font(.caption)
                .foregroundColor(.gray)
            
            ButtonView(
                title: "Increase",
                icon: "plus",
                backgroundColor: .gray.opacity(0.2)
            ) {
                viewModel.send(.increase)
            }
            
            ButtonView(
                title: "Decrease",
                icon: "minus",
                backgroundColor: .gray.opacity(0.2)
            ) {
                viewModel.send(.decrease)
            }
            
            ButtonView(
                title: "Reset",
                icon: "arrow.counterclockwise.circle",
                backgroundColor: .orange.opacity(0.2)
            ) {
                viewModel.send(.reset)
            }
            
            ButtonView(
                title: "Show",
                icon: "exclamationmark.circle.fill",
                backgroundColor: .yellow.opacity(0.2)
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
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .padding(8)
                .background(backgroundColor)
                .cornerRadius(8)
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    CounterView(CounterAsyncViewModel())
}
