//
//  WebSocketView.swift
//
//
//  Created by zundaeng on 2024
//

import SwiftUI

struct WebSocketView: View {
    @StateObject private var viewModel = WebSocketAsyncViewModel()
    @State private var serverURL: String = "wss://echo.websocket.events"
    @State private var messageText: String = ""
    @State private var showAlert = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 상단 헤더 및 연결 상태
            HStack {
                VStack(alignment: .leading) {
                    Text("웹소켓 예제")
                        .font(.headline)
                    HStack {
                        Circle()
                            .fill(viewModel.isConnected ? Color.green : Color.red)
                            .frame(width: 10, height: 10)
                        Text(viewModel.connectionStatus)
                            .font(.subheadline)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // 서버 URL 입력 및 연결 버튼
            VStack(alignment: .leading, spacing: 8) {
                Text("서버 URL")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    TextField("웹소켓 URL을 입력하세요", text: $serverURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .disabled(viewModel.isConnected)
                    
                    Button(viewModel.isConnected ? "연결 해제" : "연결") {
                        if viewModel.isConnected {
                            viewModel.send(.disconnect)
                        } else {
                            viewModel.send(.connect(url: serverURL))
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(viewModel.isConnected ? .red : .blue)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // 메시지 목록
            ScrollView {
                ScrollViewReader { scrollView in
                    LazyVStack(alignment: .leading, spacing: 8) {
                        if viewModel.messages.isEmpty {
                            Text("아직 메시지가 없습니다.\n연결 후 메시지를 보내보세요.")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            ForEach(viewModel.messages) { message in
                                MessageView(message: message)
                                    .id(message.id)
                            }
                            .onChange(of: viewModel.messages, { _, _ in
                                if let lastMessage = viewModel.messages.last {
                                    scrollView.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            })
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            // 메시지 입력 및 전송
            HStack {
                TextField("메시지 입력", text: $messageText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(!viewModel.isConnected)
                
                Button(action: {
                    viewModel.send(.sendMessage(text: messageText))
                    messageText = ""
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .padding(8)
                        .background(viewModel.isConnected ? Color.blue : Color.gray)
                        .clipShape(Circle())
                }
                .disabled(!viewModel.isConnected || messageText.isEmpty)
            }
            .padding()
            
            // 하단 버튼
            HStack {
                Button("메시지 지우기") {
                    viewModel.send(.clearMessages)
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Text("Starscream 예제")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding()
        .alert(item: alertBinding()) { alertType in
            switch alertType {
            case .info(let message):
                return Alert(
                    title: Text("알림"),
                    message: Text(message),
                    dismissButton: .default(Text("확인"))
                )
            case .error(let error):
                return Alert(
                    title: Text("오류"),
                    message: Text(error.localizedDescription),
                    dismissButton: .default(Text("확인"))
                )
            case .none:
                return Alert(
                    title: Text("알림"),
                    message: Text(""),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
    
    private func alertBinding() -> Binding<WebSocketAsyncViewModel.AlertType?> {
        Binding<WebSocketAsyncViewModel.AlertType?>(
            get: { viewModel.activeAlert },
            set: { viewModel.activeAlert = $0 }
        )
    }
}

// 메시지 셀 뷰
struct MessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
                Text(message.text)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.leading, 50)
            } else {
                Text(message.text)
                    .padding(10)
                    .background(Color(.systemGray5))
                    .cornerRadius(10)
                    .padding(.trailing, 50)
                Spacer()
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WebSocketView()
}
