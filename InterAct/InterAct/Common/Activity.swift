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
    var participantsCount: Int
    var participantIds: Array<String>
    var location: CLLocationCoordinate2D
    var hostLocation: CLLocationCoordinate2D // 发起人所在位置
    var image: UIImage? // 上传的照片（非必填项）
}
