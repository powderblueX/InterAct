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

class HeatmapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555)
    @Published var hostLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.90750000, longitude: 116.38805555) // 默认发起人位置
    @Published var locationName: String = ""
    @Published var searchText: String = ""
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
    @Published var errorSearchMessage: String? = nil
    
    @Published var gradientStart = UnitPoint.topLeading
    @Published var gradientEnd = UnitPoint.bottomTrailing
    var chartData: [String: Int] {
        guard let region = selectedRegion else { return [:] }
        return region.categoryCount
    }
    
    func loadHeatmapActivities() {
        LeanCloudService.fetchActivitiesFromDB { [weak self] activities, error in
            guard let self = self else { return }
            
            if let activities = activities {
                self.activities = activities
                self.aggregateActivitiesIntoRegions()
            } else if let error = error {
                print("Error fetching activities: \(error)")
            }
        }
    }
    
    // CLLocationManager 实例
    private var locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 请求授权
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation() // 开始位置更新
    }
    
    // 获取设备当前位置
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.first else { return }
        
        // 更新设备当前位置信息
        self.hostLocation = newLocation.coordinate
    }
    
    // 设置地图位置到选中的点
    func setCameraToSelectedLocation() {
        if let selectedLocation = selectedLocation {
            position = .camera(
                MapCamera(centerCoordinate: selectedLocation, distance: 5000) // 这里的距离可以调整
            )
        }
    }
    
    // 按地理位置聚合活动为热力区域
    private func aggregateActivitiesIntoRegions() {
        var regionDict: [String: HeatmapRegion] = [:]
        for activity in activities {
            // 将经纬度归为某个网格（0.01 度为步长，模拟聚合逻辑）
            let key = "\(Int(activity.location.latitude * 200))-\(Int(activity.location.longitude * 200))"
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
    
    // 搜索地址的函数
    func searchAddress(searchText: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(searchText) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                if let geocodeError = error as? CLError {
                    switch geocodeError.code {
                    case .locationUnknown:
                        errorSearchMessage = "定位信息未知"
                        print("定位信息未知")
                    case .denied:
                        errorSearchMessage = "定位服务权限被拒绝"
                        print("定位服务权限被拒绝")
                    case .network:
                        errorSearchMessage = "网络错误"
                        print("网络错误")
                    default:
                        errorSearchMessage = "其他错误: \(geocodeError.localizedDescription)"
                        print("其他错误: \(geocodeError.localizedDescription)")
                    }
                } else {
                    errorSearchMessage = "Geocoding failed: \(error.localizedDescription)"
                    print("Geocoding failed: \(error.localizedDescription)")
                }
                return
            }
            
            if let placemark = placemarks?.first, let location = placemark.location {
                // 更新地图位置和显示的地名
                self.selectedLocation = location.coordinate
                self.locationName = placemark.name ?? "未知位置"
                
                // 更新地图的显示区域
                region.center = location.coordinate
                region.span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                position = .automatic
                
                print("找到位置: \(placemark.name ?? "未知位置")")
            } else {
                errorSearchMessage = "没有找到相关位置"
                print("没有找到相关位置")
            }
        }
    }
    
    // 热力图颜色、透明度
    func getHeatmapColor(for region: HeatmapRegion) -> Color {
        let density = Double(region.activityCount) / 5.0  // 假设最大活动数为 10
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
        let opacity = min(0.3 + density * 0.4, 0.8) // 最小透明度0.6，最大透明度0.8
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
    
    func animateGradient() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 2.0)) {
                self.gradientStart = UnitPoint.randomPoint()
                self.gradientEnd = UnitPoint.randomPoint()
            }
        }
    }
}


extension UnitPoint {
    static func randomPoint() -> UnitPoint {
        let points: [UnitPoint] = [.top, .bottom, .leading, .trailing, .topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
        return points.randomElement() ?? .top
    }
}
