//
//  HeatmapViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import Foundation
import CoreLocation
import Combine
import _MapKit_SwiftUI
import LeanCloud

class HeatmapViewModel: ObservableObject {
    
    @Published var position: MapCameraPosition = .automatic
    @Published var selectedResult: MKMapItem?
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    
    @Published var activities: [HeatmapActivity] = []      // 单个活动数据
    @Published var regions: [HeatmapRegion] = []
    
    // 初始化，加载示例数据
    init() {
        fetchActivitiesFromLeanCloud()
    }
    private func loadSampleData() {
            activities = [
                HeatmapActivity(id: "1", location: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), participatantCount: 50, interestTag: ["Health", "Sports"]),
                HeatmapActivity(id: "2", location: CLLocationCoordinate2D(latitude: 37.7750, longitude: -122.4180), participatantCount: 30, interestTag: ["Dance", "Art"]),
                HeatmapActivity(id: "3", location: CLLocationCoordinate2D(latitude: 37.7748, longitude: -122.4192), participatantCount: 100, interestTag: ["Technology", "Networking"]),
                // 更多活动...
            ]
        print(activities)
        }
    func fetchActivitiesFromLeanCloud() {
        let query = LCQuery(className: "Activity")
        
        query.find { result in
            switch result {
            case .success(let objects):
                let fetchedHeatmapActivities = objects.compactMap { object -> HeatmapActivity? in
                    guard let interestTag = object["interestTag"]?.arrayValue,
                          let participantIds = object["participantIds"]?.arrayValue,
                          let location = object["location"] as? LCGeoPoint
                    else {
                        return nil
                    }
                    
                    // 创建 Activity 对象
                    return HeatmapActivity(
                        id: object.objectId!.stringValue ?? "",
                        location: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                        participatantCount: (participantIds as? Array<String> ?? []).count,
                        interestTag: interestTag as? Array<String> ?? []
                    )
                }
                self.activities = fetchedHeatmapActivities
                self.aggregateActivitiesIntoRegions()
            case .failure(let error):
                print("Error fetching activities: \(error)")
            }
        }
    }
    
    // 按地理位置聚合活动为热力区域
    private func aggregateActivitiesIntoRegions() {
        var regionDict: [String: HeatmapRegion] = [:]
        for activity in activities {
            // 将经纬度归为某个网格（0.01 度为步长，模拟聚合逻辑）
            let key = "\(Int(activity.location.latitude * 100))-\(Int(activity.location.longitude * 100))"
            if regionDict[key] == nil {
                regionDict[key] = HeatmapRegion(center: activity.location, activities: [])
            }
            regionDict[key]?.activities.append(activity)
        }
        
        // 重新计算每个区域的 center（可以是该区域内活动的平均位置）
        for (key, region) in regionDict {
            let totalLatitude = region.activities.reduce(0) { $0 + $1.location.latitude }
            let totalLongitude = region.activities.reduce(0) { $0 + $1.location.longitude }
            let averageLatitude = totalLatitude / Double(region.activities.count)
            let averageLongitude = totalLongitude / Double(region.activities.count)
            regionDict[key]?.center = CLLocationCoordinate2D(latitude: averageLatitude, longitude: averageLongitude)
        }
        
        // 转换成数组
        regions = Array(regionDict.values)
    }
}

