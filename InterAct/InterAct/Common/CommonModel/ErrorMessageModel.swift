//
//  ErrorMessageModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/25.
//

import Foundation

// 定义 ErrorMessage 类型
struct ErrorMessage: Identifiable {
    var id = UUID() // 符合 Identifiable 协议的要求
    var message: String
}
