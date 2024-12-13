//
//  MapViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import Foundation
import Combine
import CoreLocation
import _MapKit_SwiftUI

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555)
    @Published var locationName: String = ""
    @Published var searchText: String = ""
    @Published var position: MapCameraPosition = .automatic
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    
    @Published var errorSearchMessage: String? = nil
    
    // CLLocationManager 实例
    private var locationManager = CLLocationManager()
    private var isUserLocationUpdating = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() // 请求授权
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation() // 开始位置更新
    }
    
    // 设置地图位置到选中的点
    func setCameraToSelectedLocation() {
        if let selectedLocation = selectedLocation {
            position = .camera(
                MapCamera(centerCoordinate: selectedLocation, distance: 5000) // 这里的距离可以调整
            )
        }
    }
    
    // 搜索地址的函数
    func searchAddress(searchText: String) {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(searchText) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error {
                self.handleGeocodingError(error)
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
                self.isUserLocationUpdating = false // 允许更新位置
                print("找到位置: \(placemark.name ?? "未知位置")")
            } else {
                errorSearchMessage = "没有找到相关位置"
                print("没有找到相关位置")
            }
        }
    }
    
    // 通过坐标获取地址的函数（反向地理编码）
    func reverseGeocode(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error as? CLError {
                self.handleGeocodingError(error)
                return
            }
            
            if let placemark = placemarks?.first {
                self.locationName = placemark.name ?? "未知位置"
                print("Found location: \(placemark.name ?? "未知位置")")
            } else {
                errorSearchMessage = "没有找到相关位置"
                print("No results found")
            }
        }
        // 设置延迟清除错误消息
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.errorSearchMessage = nil
        }
    }
    
    private func handleGeocodingError(_ error: Error) {
        if let geocodeError = error as? CLError {
            switch geocodeError.code {
            case .locationUnknown:
                errorSearchMessage = "定位信息未知"
            case .denied:
                errorSearchMessage = "定位服务权限被拒绝"
            case .network:
                errorSearchMessage = "网络错误"
            default:
                errorSearchMessage = "其他错误: \(geocodeError.localizedDescription)"
            }
        } else {
            errorSearchMessage = "Geocoding failed: \(error.localizedDescription)"
        }
    }
}
