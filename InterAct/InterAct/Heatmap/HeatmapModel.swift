//
//  HeatmapModel.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import Foundation
import CoreLocation
import SwiftUI

// 表示单个活动的模型
struct HeatmapActivity: Identifiable {
    let id: String
    let location: CLLocationCoordinate2D
    let participatantCount: Int  // 活动的参与人数
    let interestTag: [String] // 活动的种类标签
}

// 表示聚合后的热力区域
struct HeatmapRegion: Identifiable, Hashable {
    static func == (lhs: HeatmapRegion, rhs: HeatmapRegion) -> Bool {
        lhs.id == rhs.id
    }
   
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let id = UUID()
    var center: CLLocationCoordinate2D
    var activities: [HeatmapActivity]
    
    /// 活动总数
    var activityCount: Int {
        activities.count
    }
    
    /// 总参与人数
    var totalAttendees: Int {
        activities.reduce(into: 0) { result, activity in
            result += activity.participatantCount
        }
    }
    
    /// 活动种类统计
    var categoryCount: [String: Int] {
        var countDict: [String: Int] = [:]
        for activity in activities {
            for category in activity.interestTag {
                countDict[category, default: 0] += 1
            }
        }
        return countDict
    }
}

