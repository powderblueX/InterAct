//
//  MyInfoViewModel.swift
//  InterAct
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
    @Published var MeAndActivities: Bool = true

    init() {
        fetchUserInfo()
    }
    
    // 获取用户信息
    func fetchUserInfo() {
        isLoading = true
        errorMessage = nil
        
        // 从 UserDefaults 获取已登录的用户名 TODO: 登出
        guard let objectId = UserDefaults.standard.string(forKey: "objectId") else {
            self.isLoading = false
            self.errorMessage = "未找到已登录的ID"
            LeanCloudService.logout()
            return
        }
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            self.isLoading = false
            self.errorMessage = "未找到已登录的用户名"
            LeanCloudService.logout()
            return
        }
        
        // 调用 LeanCloudService 获取用户信息
        LeanCloudService.fetchUserInfo(objectId: objectId, username: username) { [weak self] result in
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
        LeanCloudService.updateUserInfo(objectId: objectId, newInfo: newInfo) { [weak self] result in
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



