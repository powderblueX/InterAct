//
//  TestModel.swift
//  InterAct
//
//  Created by admin on 2024/12/4.
//

import SwiftUI

struct TestForNotificationView: View {
    @State private var message = ""
    @State private var hostId = ""

    var body: some View {
        VStack {
            TextField("Enter Host ID", text: $hostId)
                .padding()
                .border(Color.gray)
            
            TextField("Enter Message", text: $message)
                .padding()
                .border(Color.gray)
            
            Button(action: {
                // 点击按钮后，发送请求
                sendPushNotificationRequest()
            }) {
                Text("Send Notification")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
    }
    
    // 发送请求到后端，触发云引擎发送推送通知
    func sendPushNotificationRequest() {
        let url = URL(string: "https://your-backend-api.com/sendPushNotification")! // 你的后端 API 地址
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body: [String: Any] = [
            "hostId": hostId,
            "message": message
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            print("Error serializing request body: \(error)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending notification: \(error)")
                return
            }
            print("Push notification request sent successfully")
        }
        task.resume()
    }
}
