//
//  WebSocketAsyncViewModel.swift
//
//
//  Created by zundaeng on 2024
//

import SwiftUI
import Starscream

/// 웹소켓 통신 시 발생할 수 있는 에러 정의
enum WebSocketError: Error, LocalizedError {
    case connectionFailed(reason: String)
    case invalidURL
    case messageSendFailed
    case notConnected
    
    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "웹소켓 연결 실패: \(reason)"
        case .invalidURL:
            return "유효하지 않은 URL입니다"
        case .messageSendFailed:
            return "메시지 전송에 실패했습니다"
        case .notConnected:
            return "웹소켓에 연결되어 있지 않습니다"
        }
    }
}

/// 채팅 메시지 모델
struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isFromUser: Bool
    let timestamp: Date
    
    static func userMessage(_ text: String) -> ChatMessage {
        ChatMessage(text: text, isFromUser: true, timestamp: Date())
    }
    
    static func serverMessage(_ text: String) -> ChatMessage {
        ChatMessage(text: text, isFromUser: false, timestamp: Date())
    }
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.isFromUser == rhs.isFromUser &&
        lhs.timestamp == rhs.timestamp
    }
}

final class WebSocketAsyncViewModel: AsyncViewModel, WebSocketDelegate {
    
    // AsyncViewModel 프로토콜 타입 정의
    enum Input {
        case connect(url: String)
        case disconnect
        case sendMessage(text: String)
        case clearMessages
    }
    
    enum Action {
        case connectToServer(url: String)
        case disconnectFromServer
        case sendMessageToServer(text: String)
        case clearMessageHistory
    }
    
    // 알림 타입을 정의하는 enum
    enum AlertType: Identifiable {
        case none
        case info(message: String)
        case error(Error)
        
        var id: String {
            switch self {
            case .none: return "none"
            case .info: return "info"
            case .error: return "error"
            }
        }
    }
    
    // 상태 값
    @Published var isConnected: Bool = false
    @Published var messages: [ChatMessage] = []
    @Published var connectionStatus: String = "연결 안됨"
    @Published var activeAlert: AlertType?
    
    // 웹소켓 객체
    private var socket: WebSocket?
    private var isConnecting: Bool = false
    
    // MARK: - AsyncViewModel 프로토콜 구현
    
    func transform(_ input: Input) async -> [Action] {
        switch input {
        case .connect(let url):
            return [.connectToServer(url: url)]
        case .disconnect:
            return [.disconnectFromServer]
        case .sendMessage(let text):
            return [.sendMessageToServer(text: text)]
        case .clearMessages:
            return [.clearMessageHistory]
        }
    }
    
    func perform(_ action: Action) async throws {
        switch action {
        case .connectToServer(let url):
            try await connectToServer(urlString: url)
        case .disconnectFromServer:
            disconnectFromServer()
        case .sendMessageToServer(let text):
            try await sendMessage(text: text)
        case .clearMessageHistory:
            clearMessages()
        }
    }
    
    // MARK: - 웹소켓 기능 구현
    
    private func connectToServer(urlString: String) async throws {
        guard !isConnecting && !isConnected else {
            connectionStatus = "이미 연결 중이거나 연결되어 있습니다"
            return
        }
        
        guard let url = URL(string: urlString) else {
            throw WebSocketError.invalidURL
        }
        
        isConnecting = true
        connectionStatus = "연결 중..."
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        
        socket = WebSocket(request: request)
        socket?.delegate = self
        socket?.connect()
    }
    
    private func disconnectFromServer() {
        guard let socket = socket, isConnected else {
            connectionStatus = "연결되어 있지 않습니다"
            return
        }
        
        socket.disconnect()
        self.connectionStatus = "연결 종료됨"
    }
    
    private func sendMessage(text: String) async throws {
        guard let socket = socket, isConnected else {
            throw WebSocketError.notConnected
        }
        
        guard !text.isEmpty else { return }
        
        // 사용자 메시지 추가
        let userMessage = ChatMessage.userMessage(text)
        messages.append(userMessage)
        
        // 메시지 전송
        socket.write(string: text)
    }
    
    private func clearMessages() {
        messages.removeAll()
    }
    
    // MARK: - WebSocketDelegate 구현
    
    func didReceive(event: WebSocketEvent, client: WebSocketClient) {
        Task { @MainActor in
            switch event {
            case .connected(_):
                isConnected = true
                isConnecting = false
                connectionStatus = "연결됨"
                activeAlert = .info(message: "서버에 연결되었습니다")
                
            case .disconnected(let reason, _):
                isConnected = false
                isConnecting = false
                connectionStatus = "연결 종료됨: \(reason)"
                
            case .text(let string):
                let serverMessage = ChatMessage.serverMessage(string)
                messages.append(serverMessage)
                
            case .binary(let data):
                if let string = String(data: data, encoding: .utf8) {
                    let serverMessage = ChatMessage.serverMessage(string)
                    messages.append(serverMessage)
                }
                
            case .ping(_):
                break
                
            case .pong(_):
                break
                
            case .viabilityChanged(_):
                break
                
            case .reconnectSuggested(_):
                break
                
            case .cancelled:
                isConnected = false
                isConnecting = false
                connectionStatus = "연결이 취소됨"
                
            case .error(let error):
                isConnected = false
                isConnecting = false
                connectionStatus = "오류 발생"
                if let error = error {
                    handleWSError(error)
                }
                
            case .peerClosed:
                isConnected = false
                isConnecting = false
                connectionStatus = "상대방이 연결을 종료함"
            }
        }
    }
    
    private func handleWSError(_ error: Error) {
        let wsError = WebSocketError.connectionFailed(reason: error.localizedDescription)
        activeAlert = .error(wsError)
    }
    
    func handleError(_ error: Error) async {
        activeAlert = .error(error)
        print("웹소켓 오류: \(error.localizedDescription)")
    }
} 
