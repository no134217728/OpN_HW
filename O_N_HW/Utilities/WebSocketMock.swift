//
//  WebSocketMock.swift
//  O_N_HW
//
//  Created by 黃紋吸蜜 on 2025/8/25.
//

import UIKit

class WebSocketMock {
    func generateRandomOdds() -> Odds {
        let matchID = Int.random(in: 1001...1120)
        var oddsA = Decimal(Double.random(in: 1...3))
        var oddsB = Decimal(Double.random(in: 1...3))
        var roundedA = Decimal()
        var roundedB = Decimal()
        NSDecimalRound(&roundedA, &oddsA, 2, .plain)
        NSDecimalRound(&roundedB, &oddsB, 2, .plain)
        
        return Odds(matchID: matchID,
                    teamAOdds: roundedA,
                    teamBOdds: roundedB)
    }
    
    func webSocketTest() {
        let manager = WebSocketManager(url: URL(string: "wss://echo.websocket.org")!)
        manager.connect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            manager.send("Hello WebSocket!")
        }
    }
    
    func nwWebSocketTest() {
        let client = WebSocketClient()
        client.connect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            client.send(text: "Hello WebSocket 👋")
        }
    }
    
    func socketTest() {
        SocketManager.shared.connect()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SocketManager.shared.send("Hello Server")
        }
    }
}

// AI 產出 Socket 基本使用
import Foundation
import Network

// Web Socket
class WebSocketManager {
    private var webSocketTask: URLSessionWebSocketTask?
    private var url: URL
    private var isConnected = false
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    
    init(url: URL) {
        self.url = url
    }
    
    func connect() {
        disconnect()
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        isConnected = true
        
        print("🔗 WebSocket connecting...")
        receive()
        startHeartbeat()
    }
    
    func disconnect() {
        stopHeartbeat()
        isConnected = false
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        webSocketTask = nil
    }
    
    func send(_ text: String) {
        guard let webSocketTask = webSocketTask else { return }
        
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask.send(message) { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        }
    }
    
    private func receive() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("❌ Receive error: \(error)")
                self.reconnect()
            case .success(let message):
                switch message {
                case .string(let text):
                    print("📩 Received: \(text)")
                case .data(let data):
                    print("📩 Received binary: \(data)")
                @unknown default:
                    print("⚠️ Unknown message")
                }
                
                self.receive()
            }
        }
    }
    
    private func startHeartbeat() {
        stopHeartbeat()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { [weak self] _ in
            self?.sendPing()
        }
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }
    
    private func sendPing() {
        webSocketTask?.sendPing { error in
            if let error = error {
                print("❌ Ping failed: \(error)")
                self.reconnect()
            } else {
                print("💓 Ping success")
            }
        }
    }
    
    private func reconnect() {
        guard !isConnected else { return }
        print("🔄 Attempting to reconnect in 3 seconds...")
        reconnectTimer?.invalidate()
        reconnectTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { [weak self] _ in
            self?.connect()
        }
    }
}

// NWConnection NWProtocolWebSocket
class WebSocketClient {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "WebSocketQueue")
    private let heartbeatInterval: TimeInterval = 15
    private var heartbeatTimer: DispatchSourceTimer?
    private var reconnectDelay: TimeInterval = 3
    private var isReconnecting = false
    
    func connect() {
        guard let url = URL(string: "wss://echo.websocket.org"),
              let urlHost = url.host,
              let port = NWEndpoint.Port(rawValue: UInt16(url.port ?? (url.scheme == "wss" ? 443 : 80))) else {
            print("❌ Invalid URL")
            return
        }
        
        let wsOptions = NWProtocolWebSocket.Options()
        wsOptions.autoReplyPing = false
        
        let parameters = NWParameters(tls: nil)
        parameters.defaultProtocolStack.applicationProtocols.insert(wsOptions, at: 0)
        
        let host = NWEndpoint.Host(urlHost)
        connection = NWConnection(host: host, port: port, using: parameters)
        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                print("✅ WebSocket connected")
                self?.isReconnecting = false
                self?.startHeartbeat()
                self?.receiveMessage()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self?.scheduleReconnect()
            case .waiting(let error):
                print("⚠️ Waiting: \(error)")
                self?.scheduleReconnect()
            case .cancelled:
                print("🔌 Connection cancelled")
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
    
    private func receiveMessage() {
        connection?.receiveMessage { [weak self] (data, context, isComplete, error) in
            if let error = error {
                print("❌ Receive error: \(error)")
                self?.scheduleReconnect()
                return
            }
            
            if let data = data, let text = String(data: data, encoding: .utf8) {
                print("📩 Received: \(text)")
            }
            
            self?.receiveMessage()
        }
    }
    
    func send(text: String) {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .text)
        let context = NWConnection.ContentContext(identifier: "send",
                                                  metadata: [metadata])
        connection?.send(content: text.data(using: .utf8),
                         contentContext: context,
                         isComplete: true,
                         completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            }
        })
    }
    
    private func startHeartbeat() {
        heartbeatTimer?.cancel()
        heartbeatTimer = DispatchSource.makeTimerSource(queue: queue)
        heartbeatTimer?.schedule(deadline: .now() + heartbeatInterval, repeating: heartbeatInterval)
        heartbeatTimer?.setEventHandler { [weak self] in
            self?.sendPing()
        }
        
        heartbeatTimer?.resume()
    }
    
    private func sendPing() {
        let metadata = NWProtocolWebSocket.Metadata(opcode: .ping)
        let context = NWConnection.ContentContext(identifier: "ping",
                                                  metadata: [metadata])
        connection?.send(content: nil,
                         contentContext: context,
                         isComplete: true,
                         completion: .contentProcessed { error in
            if let error = error {
                print("❌ Ping error: \(error)")
            } else {
                print("💓 Ping sent")
            }
        })
    }
    
    private func stopHeartbeat() {
        heartbeatTimer?.cancel()
        heartbeatTimer = nil
    }
    
    private func scheduleReconnect() {
        guard !isReconnecting else { return }
        
        isReconnecting = true
        stopHeartbeat()
        connection?.cancel()
        print("⏳ Reconnecting in \(reconnectDelay)s...")
        queue.asyncAfter(deadline: .now() + reconnectDelay) { [weak self] in
            self?.connect()
        }
    }
    
    func disconnect() {
        stopHeartbeat()
        connection?.cancel()
    }
}

// NWConnection
class SocketManager {
    static let shared = SocketManager()
    
    private var connection: NWConnection?
    private var host: NWEndpoint.Host = "echo.websocket.org"
    private var port: NWEndpoint.Port = 80
    
    private var isConnected = false
    private var heartbeatTimer: Timer?
    private var reconnectTimer: Timer?
    
    private init() {}
    
    func connect() {
        if isConnected { return }
        
        let params = NWParameters.tcp
        connection = NWConnection(host: host, port: port, using: params)
        
        connection?.stateUpdateHandler = { [weak self] newState in
            guard let self = self else { return }
            switch newState {
            case .ready:
                print("✅ Connected to server")
                self.isConnected = true
                self.startReceive()
                self.startHeartbeat()
            case .failed(let error):
                print("❌ Connection failed: \(error)")
                self.isConnected = false
                self.stopHeartbeat()
                self.scheduleReconnect()
            case .waiting(let error):
                print("⚠️ Waiting: \(error)")
                self.isConnected = false
                self.stopHeartbeat()
                self.scheduleReconnect()
            case .cancelled:
                print("🔌 Connection cancelled")
                self.isConnected = false
                self.stopHeartbeat()
            default:
                break
            }
        }
        
        connection?.start(queue: .global())
    }
    
    private func startReceive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { [weak self] data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                let text = String(decoding: data, as: UTF8.self)
                print("📩 Received: \(text)")
            }
            if error == nil && !isComplete {
                self?.startReceive()
            }
        }
    }
    
    func send(_ text: String) {
        guard isConnected, let connection = connection else { return }
        let data = text.data(using: .utf8) ?? Data()
        connection.send(content: data, completion: .contentProcessed { error in
            if let error = error {
                print("❌ Send error: \(error)")
            } else {
                print("📤 Sent: \(text)")
            }
        })
    }
    
    private func startHeartbeat() {
        DispatchQueue.main.async {
            self.stopHeartbeat()
            self.heartbeatTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.send("PING")
            }
        }
    }
    
    private func stopHeartbeat() {
        DispatchQueue.main.async {
            self.heartbeatTimer?.invalidate()
            self.heartbeatTimer = nil
        }
    }
    
    private func scheduleReconnect() {
        DispatchQueue.main.async {
            self.reconnectTimer?.invalidate()
            self.reconnectTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) { [weak self] _ in
                print("🔄 Trying to reconnect...")
                self?.connect()
            }
        }
    }
    
    func disconnect() {
        connection?.cancel()
        connection = nil
        stopHeartbeat()
        reconnectTimer?.invalidate()
        reconnectTimer = nil
        isConnected = false
    }
}
