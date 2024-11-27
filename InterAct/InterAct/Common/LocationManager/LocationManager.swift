////
////  LocationManager.swift
////  EcoStep
////
////  Created by admin on 2024/11/20.
////
//
//import Foundation
//import CoreLocation
//import MapKit
//
//class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
//    @Published var currentLocation: CLLocationCoordinate2D?
//    @Published var locationPath: [CLLocationCoordinate2D] = [] // 路径点列表
//    @Published var currentAddress: String? // 用于存储当前位置的地址
//    
//    private let locationManager = CLLocationManager()
//    private let geocoder = CLGeocoder() // 用于反向地理编码
//    
//    override init() {
//        super.init()
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // 提高精度
//        locationManager.distanceFilter = 10 // 每10米更新一次位置
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation() // 自动开始更新位置
//    }
//    
//    // 开始更新位置
//    func startTracking() {
//        if CLLocationManager.locationServicesEnabled() {
//            locationManager.startUpdatingLocation()
//        } else {
//            print("定位服务未启用")
//        }
//    }
//    
//    // 停止更新位置
//    func stopTracking() {
//        locationManager.stopUpdatingLocation()
//    }
//    
//    // CLLocationManagerDelegate 方法
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let location = locations.last else { return }
//        
//        DispatchQueue.main.async {
//            self.currentLocation = location.coordinate
//            
//            // 保存路径点，限制路径长度为最近100个点
//            self.locationPath.append(location.coordinate)
//            if self.locationPath.count > 100 {
//                self.locationPath.removeFirst()
//            }
//            
//            // 反向地理编码，获取当前位置的地址
//            self.reverseGeocodeLocation(location)
//        }
//    }
//    
//    func reverseGeocodeLocation(_ location: CLLocation) {
//        geocoder.reverseGeocodeLocation(location) { placemarks, error in
//            if let error = error {
//                print("地理编码失败: \(error.localizedDescription)")
//                self.currentAddress = "无法获取地址"
//                return
//            }
//            
//            if let placemark = placemarks?.first {
//                self.currentAddress = placemark.name ?? "未知地址"
//            } else {
//                self.currentAddress = "无法解析地址"
//            }
//        }
//    }
//    
//    // 处理位置权限变化
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        switch status {
//        case .denied, .restricted:
//            print("用户未授权使用定位服务")
//        case .authorizedWhenInUse, .authorizedAlways:
//            print("定位服务已授权")
//            startTracking() // 授权后开始跟踪
//        default:
//            break
//        }
//    }
//    
//    // 定位服务发生错误
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("定位失败: \(error.localizedDescription)")
//    }
//}
//
//
