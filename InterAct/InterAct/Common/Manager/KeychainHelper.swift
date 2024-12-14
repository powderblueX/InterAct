//
//  KeychainHelper.swift
//  EcoStep
//
//  Created by admin on 2024/11/23.
//

import Security
import Foundation

class KeychainHelper {
    // 存储密码到 Keychain
    static func savePassword(password: String) -> Bool {
        guard let passwordData = password.data(using: .utf8) else { return false }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecValueData as String: passwordData
        ]
        
        // 检查密码是否已经存在，如果存在就更新
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // 从 Keychain 中读取密码
    static func loadPassword() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword",
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data, let password = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return password
    }
    
    // 从 Keychain 中删除密码
    static func deletePassword() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: "userPassword"
        ]
        SecItemDelete(query as CFDictionary)
    }
}

