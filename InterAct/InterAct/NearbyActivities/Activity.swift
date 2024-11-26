//
//  Activity.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import Foundation
import CoreLocation

struct Activity {
    var id: String
    var activityName: String
    var activityTime: Date
    var activityIntroduction: String
    var creatorId: String
    var participantsCount: Int
    var coordinate: CLLocationCoordinate2D
}
