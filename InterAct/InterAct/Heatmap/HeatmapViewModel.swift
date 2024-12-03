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
import SwiftUI

class HeatmapViewModel: ObservableObject {
    
    @Published var position: MapCameraPosition = .automatic
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    @Published var activities: [HeatmapActivity] = []      // 单个活动数据
    @Published var regions: [HeatmapRegion] = []
    @Published var selectedRegion: HeatmapRegion? = nil // 存储当前选中的热力区域
    @Published var showDetails: Bool = false
    @Published private var zoomScale: Double = 1.0 // 记录地图缩放比例
    
    func loadHeatmapActivities() {
        LeanCloudService.fetchActivitiesFromLeanCloud { [weak self] activities, error in
            guard let self = self else { return }
            
            if let activities = activities {
                self.activities = activities
                self.aggregateActivitiesIntoRegions()
            } else if let error = error {
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
    
    // 热力图颜色、透明度
    func getHeatmapColor(for region: HeatmapRegion) -> Color {
        let density = Double(region.activityCount) / 4.0  // 假设最大活动数为 10
        // 计算每种颜色的分量
        let red: Double
        let green: Double
        let blue: Double
        
        // 颜色过渡的范围
        if density < 0.5 {
            // 从蓝色到黄色的过渡
            red = density * 2.0   // 增加红色分量
            green = density * 2.0  // 增加绿色分量
            blue = 1.0 - density * 2.0  // 减少蓝色分量
        } else {
            // 从黄色到红色的过渡
            red = 1.0            // 红色固定最大
            green = 2.0 - density * 2.0  // 减少绿色分量
            blue = 0.0           // 蓝色为 0
        }
        // 透明度随着活动数增加而增大
        let opacity = min(0.3 + density * 0.4, 5.0) // 最小透明度0.6，最大透明度1.0
        return Color(red: red, green: green, blue: blue) // 蓝色到红色渐变
            .opacity(opacity)
    }
    
    func getScaledSize(for region: HeatmapRegion) -> CGFloat {
        let baseSize: CGFloat = 2.0 // 每个活动的基础大小
        return CGFloat(region.activityCount) * baseSize / CGFloat(zoomScale)
    }
    
    // 更新缩放比例
    func updateZoomScale(from region: MKCoordinateRegion) {
        let span = region.span
        zoomScale = max(span.latitudeDelta, span.longitudeDelta)
    }
}
