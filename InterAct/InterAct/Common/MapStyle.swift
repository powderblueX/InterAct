//
//  MapStyle.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import Foundation
import _MapKit_SwiftUI

struct MapStyleModel {
    static let mapStyle: MapStyle = MapStyle.standard(
        elevation: .automatic,
        emphasis: .automatic,
        pointsOfInterest: .all,
        showsTraffic: true
    )
}
