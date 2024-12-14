//
//  Activity.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import CoreLocation
import UIKit

struct Activity {
    var id: String
    var activityName: String
    var interestTag: Array<String>
    var activityTime: Date
    var activityDescription: String
    var hostId: String
    var hostUsername: String
    var participantsCount: Int
    var participantIds: Array<String>
    var location: CLLocationCoordinate2D
    var locationName: String
    var image: URL? // 上传的照片（非必填项）
    
    // 用于展示时间的格式化
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter.string(from: activityTime)
    }
}
