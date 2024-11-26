//
//  AlertType.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation

enum AlertType: Identifiable {
    case success(String) // 成功消息
    case error(String)   // 错误消息
    
    var id: String {
        switch self {
        case .success:
            return "success"
        case .error:
            return "error"
        }
    }
    
    var title: String {
        switch self {
        case .success:
            return "成功"
        case .error:
            return "错误"
        }
    }
    
    var message: String {
        switch self {
        case .success(let message), .error(let message):
            return message
        }
    }
}
