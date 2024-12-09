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

class MapViewModel: ObservableObject {
    @Published var selectedLocation: CLLocationCoordinate2D? = CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555)
    @Published var locationName: String = ""
    @Published var searchText: String = ""
    @Published var position: MapCameraPosition = .automatic
    @Published var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    
    @Published var errorSearchMessage: String? = nil
    
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
    
    // 通过坐标获取地址的函数（反向地理编码）
    func reverseGeocode(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { [weak self] (placemarks, error) in
            guard let self = self else { return }
            
            if let error = error as? CLError {
                switch error.code {
                case .locationUnknown:
                    errorSearchMessage = "定位信息未知"
                    print("定位信息未知")
                case .denied:
                    errorSearchMessage = "定位服务权限被拒绝"
                    print("定位服务权限被拒绝")
                case .network:
                    errorSearchMessage = "网络错误"
                    print("网络错误")
                case .headingFailure:
                    errorSearchMessage = "定位信息未知"
                    print("Heading failure")
                default:
                    errorSearchMessage = "定位信息未知"
                    print("Other error: \(error.localizedDescription)")
                }
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
}
