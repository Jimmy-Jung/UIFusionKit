//
//  CounterView.swift
//  
//
//  Created by 정준영 on 2024/8/4.
//

import SwiftUI
import Combine

struct CounterView: View {
    var viewModel: any CounterViewModel
    @ObservedObject private var state: CounterState
    @State private var isPresented = false
    private var cancellables = Set<AnyCancellable>()
    
    init(_ viewModel: any CounterViewModel) {
        self.viewModel = viewModel
        self.state = viewModel.state
    }
    var body: some View {
        VStack(spacing: 20) {
            Text("Value: \(state.value)")
                .font(.system(size: 20, weight: .semibold))
            
            Button(action: {
                viewModel.send(.increase)
            }) {
                Label("Increase", systemImage: "plus")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.send(.decrease)
            }) {
                Label("Decrease", systemImage: "minus")
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.send(.reset)
            }) {
                Label("Reset", systemImage: "arrow.counterclockwise.circle")
                    .padding(8)
                    .background(Color.orange.opacity(0.2))
                    .cornerRadius(8)
            }
            
            Button(action: {
                viewModel.send(.show)
            }) {
                Label("Show", systemImage: "exclamationmark.circle.fill")
                    .padding(8)
                    .background(Color.yellow.opacity(0.2))
                    .cornerRadius(8)
            }
        }
        .alert(isPresented: $isPresented) {
            Alert(title: Text("알림"), message: Text("\(state.value)"), dismissButton: .default(Text("닫기"), action: {
                isPresented = false
            }))
        }
        .onReceive(state.$showAlert.dropFirst(), perform: { _ in
            isPresented = true
        })
    }
}

#Preview {
    CounterView(DefaultCounterViewModel())
}
