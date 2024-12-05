//
//  MessageRowViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/6.
//

import Foundation

class MessageRowViewModel: ObservableObject {
    @Published var activityId: String? = nil
    
    func updateContent(content: String) -> String {
        var updatedContent: String = content
        
        if content.starts(with: "# wannaParticipateIn: ") {
            // 去掉前缀，提取活动的 JSON 字符串
            let activityJSONString = String(content.dropFirst("# wannaParticipateIn: ".count))
            
            // 尝试解析 JSON 字符串为活动对象
            if let activity = decodeJSONStringToActivity(jsonString: activityJSONString) {
                activityId = activity.activityId
                // 更新文本为活动名称
                updatedContent = "我想参加您发起的活动：“\(activity.activityName)”"
            } else {
                // 如果 JSON 解析失败，显示原始文本
                updatedContent = content
            }
        } else {
            // 如果不匹配条件，显示原始文本
            updatedContent = content
        }
        return updatedContent
    }
    
    func decodeJSONStringToActivity(jsonString: String) -> SendParticipateIn? {
        let decoder = JSONDecoder()
        
        if let data = jsonString.data(using: .utf8) {
            do {
                let activity = try decoder.decode(SendParticipateIn.self, from: data)
                return activity
            } catch {
                print("Error decoding JSON to activity: \(error)")
            }
        }
        return nil
    }
}

