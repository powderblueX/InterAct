//
//  MapView.swift
//  InterAct
//
//  Created by admin on 2024/11/28.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Binding var selectedLocation: CLLocationCoordinate2D?
    @Binding var locationName: String
    
    @State private var region: MKCoordinateRegion
    @State private var locationManager = CLLocationManager()
    @State private var userTrackingMode: MapUserTrackingMode = .follow // 使用 `.follow` 作为初始状态
    @State private var searchText: String = "" // 用于搜索的文本框
    
    @Environment(\.dismiss) var dismiss
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, locationName: Binding<String>) {
        self._selectedLocation = selectedLocation
        self._locationName = locationName
        self._region = State(initialValue: MKCoordinateRegion(
            center: selectedLocation.wrappedValue ?? CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555), // 默认位置
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        ))
    }
    
    var body: some View {
        VStack {
            // 地址搜索框
            TextField("输入地址或地点名称", text: $searchText, onCommit: {
                searchAddress() // 按回车后进行搜索
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true)
                .onTapGesture(coordinateSpace: .global) { _ in
                    // 获取点击位置并更新选中的位置
                    let tappedLocation = region.center
                    selectedLocation = tappedLocation
                    reverseGeocode(location: tappedLocation) // 获取选中位置的地址
                }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        // 保存选择的地点
                        dismiss()
                    }) {
                        Text("确定选择")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
        }
        .onAppear {
            locationManager.requestWhenInUseAuthorization()
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = locationManager as? CLLocationManagerDelegate
                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                locationManager.startUpdatingLocation()
            }
        }
    }
    
    // 搜索地址的函数
    private func searchAddress() {
        let geocoder = CLGeocoder()
        
        geocoder.geocodeAddressString(searchText) { (placemarks, error) in
            if let error = error {
                if let geocodeError = error as? CLError {
                    switch geocodeError.code {
                    case .locationUnknown:
                        print("定位信息未知")
                    case .denied:
                        print("定位服务权限被拒绝")
                    case .network:
                        print("网络错误")
                    default:
                        print("其他错误: \(geocodeError.localizedDescription)")
                    }
                } else {
                    // 如果是其他类型的错误，输出错误信息
                    print("Geocoding failed: \(error.localizedDescription)")
                }
                return
            }
            
            // 如果找到了地点
            if let placemark = placemarks?.first, let location = placemark.location {
                // 更新地图位置和显示的地名
                self.selectedLocation = location.coordinate
                self.locationName = placemark.name ?? "未知位置"
                
                // 更新地图的显示区域
                self.region.center = location.coordinate
                self.region.span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001) // 设置缩放级别

                // 如果需要，可以调用其他方法来重新渲染地图或进行其他操作
                print("找到位置: \(placemark.name ?? "未知位置")")
            } else {
                print("没有找到相关位置")
            }
        }
    }

    
    // 通过坐标获取地址的函数（反向地理编码）
    private func reverseGeocode(location: CLLocationCoordinate2D) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        
        geocoder.reverseGeocodeLocation(clLocation) { (placemarks, error) in
            if let error = error as? CLError {
                // 判断错误类型
                switch error.code {
                case .locationUnknown:
                    print("Location unknown")
                case .denied:
                    print("Permission denied")
                case .network:
                    print("Network error")
                case .headingFailure:
                    print("Heading failure")
                default:
                    print("Other error: \(error.localizedDescription)")
                }
                return
            }
            
            if let placemark = placemarks?.first {
                self.locationName = placemark.name ?? "Unknown Location"
                print("Found location: \(placemark.name ?? "Unknown")")
            } else {
                print("No results found")
            }
        }
    }
}

