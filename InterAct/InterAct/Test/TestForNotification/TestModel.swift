//
//  TestModel.swift
//  InterAct
//
//  Created by admin on 2024/12/4.
//

import SwiftUI
import LeanCloud

struct TestForNotificationView: View {
    @State private var messages: [String] = []
    @State private var userId: String? = UserDefaults.standard.string(forKey: "objectId")
    
    var body: some View {
        VStack {
            List(messages, id: \.self) { message in
                Text(message)
            }
            
            // 发送消息按钮
            Button("发送消息") {
                sendMessage()
            }
            
            
        }
        .onAppear {
            loadMessages()
        }
    }
    
    
    
    // 加载本地消息
    func loadMessages() {
        if let savedMessages = UserDefaults.standard.array(forKey: "messages") as? [String] {
            messages = savedMessages
        }
    }
    
    // 发送推送通知请求
    func sendMessage() {
        guard let senderId = userId else { return }
        let receiverId = "6746dc6e2096fe04ef313a1d"  // 接收者的 userId
        let message = "你好，我想加入活动！"
        
        // 调用云引擎函数来发送推送通知
        sendPushNotificationRequest(senderId: senderId, receiverId: receiverId, message: message)
    }
    
    // 调用云引擎函数发送消息
    func sendPushNotificationRequest(senderId: String, receiverId: String, message: String) {
        let url = URL(string: "https://tjmdb14p.lc-cn-n1-shared.com/1.1/functions/sendPushNotification")! // 你的后端 API 地址
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "hostId": receiverId,
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            return
        }
        
        // 设置请求头，添加 LeanCloud API Key 和 App ID
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("TJMdb14PZAk2ZMkf41nLWKDW-gzGzoHsz", forHTTPHeaderField: "X-LC-Id")  // 你的 LeanCloud App ID
        request.addValue("9AxeJKCHR8tdD4bIQEgiu6Rv", forHTTPHeaderField: "X-LC-Key")  // 你的 LeanCloud App Key
        
        // 发送请求
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("请求失败：\(error)")
                return
            }
            
            if let data = data {
                
                // 尝试打印原始响应内容
                if let str = String(data: data, encoding: .utf8) {
                    print("响应数据：\(str)") // 打印原始响应数据
                }
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print("响应数据：\(json)")
                } catch {
                    print("响应解析失败：\(error)")
                }
            }
        }
        
        task.resume()
    }
}



