//
//  AppState.swift
//  EcoStep
//
//  Created by admin on 2024/11/24.
//

import Foundation

class AppState: ObservableObject {
    static let shared = AppState() // 单例模式，确保全局共享
    @Published var isLoggedIn: Bool = false // 登录状态
    @Published var activityIDToShow: String? = nil // 存储深链接传递的活动ID
    @Published var isToShow: Bool = false
    
}

