//
//  MyInfoViewModel.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import Foundation
import Combine
import SwiftUI

class MyInfoViewModel: ObservableObject {
    @Published var userInfo: MyInfoModel?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private let leanCloudService = LeanCloudService()
    
    init() {
        fetchUserInfo()
    }
    
    // 获取用户信息
    func fetchUserInfo() {
        isLoading = true
        errorMessage = nil
        
        // 从 UserDefaults 获取已登录的用户名
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            self.isLoading = false
            self.errorMessage = "未找到已登录的ID"
            // TODO: 可以实现提示用户重新登录，并退到登录界面
            return
        }
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            self.isLoading = false
            self.errorMessage = "未找到已登录的用户名"
            // TODO: 可以实现提示用户重新登录，并退到登录界面
            return
        }
        
        // 调用 LeanCloudService 获取用户信息
        leanCloudService.fetchUserInfo(objectId: objectId, username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let userInfo):
                    self?.userInfo = userInfo
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // 更新用户信息
    func updateUserInfo(newInfo: MyInfoModel) {
        isLoading = true
        
        // 从 UserDefaults 获取已登录的ID
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            self.isLoading = false
            self.errorMessage = "未找到已登录的ID"
            return
        }
        
        // 调用 LeanCloudService 更新用户信息
        leanCloudService.updateUserInfo(objectId: objectId, newInfo: newInfo) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    self?.userInfo = newInfo // 更新本地数据
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
}



