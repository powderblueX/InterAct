//
//  ChangeIconModel.swift
//  InterAct
//
//  Created by admin on 2024/12/11.
//

import Foundation

enum AppCustomIcon: String {
    case Default = "默认外观图标"
    case Dark = "暗黑外观图标"
    case SpringFestival = "春节外观图标"
    case Christmas = "圣诞节外观图标"
    case Halloween = "万圣节外观图标"
    case Graduate = "毕业季外观图标"
    
    static var allValues: [AppCustomIcon] {
        return [.Default, .Dark, .SpringFestival, .Christmas, .Halloween, .Graduate]
    }
}
