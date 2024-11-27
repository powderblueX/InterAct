//
//  EditInterestViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/26.
//

import Foundation
import LeanCloud

class EditIntereViewModel: ObservableObject {
    @Published var interestTags: [String] = Interest().InterestTags  // 兴趣标签
    @Published var selectedInterests: [String] = [] // 当前选中标签
    @Published var errorMessage: ErrorMessage?
    @Published var isButtonDisabled: Bool = true
    @Published var isUsernameEmailUpdated: Bool = false
    @Published var alertType: AlertType? // 统一管理弹窗类型
    private var initialInterests: [String] = [] // 原始兴趣数据
    
    private var objectId: String? {
        UserDefaults.standard.string(forKey: "objectId")
    }

    // 初始化输入字段
    func initializeFields(with userInfo: MyInfoModel?) {
        initialInterests = userInfo?.interest as? [String] ?? ["无🚫"]
        selectedInterests = initialInterests
        checkIfChangesMade()
    }

    // 切换兴趣标签选择状态
    func toggleInterest(_ tag: String) {
        if tag == "无🚫" {
            // 选择“无”时清空其他选择，仅选中“无”
            selectedInterests = ["无🚫"]
        } else {
            // 取消“无”，添加或移除其他标签
            selectedInterests.removeAll { $0 == "无🚫" }
            if selectedInterests.contains(tag) {
                selectedInterests.removeAll { $0 == tag }
            } else {
                selectedInterests.append(tag)
            }
        }
        checkIfChangesMade()
    }
    
    // 判断是否有更改
    private func checkIfChangesMade() {
        isButtonDisabled = selectedInterests.sorted() == initialInterests.sorted()
    }
    
    // 保存修改到 LeanCloud
    func saveChanges(completion: @escaping (Bool) -> Void) {
        guard let objectId = objectId else {
            alertType = .error("用户未登录")
            completion(false)
            return
        }

        do {
            let user = LCObject(className: "_User", objectId: LCString(objectId))
            try user.set("interest", value: selectedInterests)

            user.save { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        self.isUsernameEmailUpdated = true
                        self.alertType = .success("用户兴趣更新成功")
                        // 更新 UserDefaults
                        UserDefaults.standard.set(self.selectedInterests, forKey: "interest")
                        completion(true)
                    case .failure(let error):
                        self.alertType = .error("保存失败：\(error.localizedDescription)")
                        completion(false)
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                self.alertType = .error("保存失败：\(error.localizedDescription)")
                completion(false)
            }
        }
    }
}
