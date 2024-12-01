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
    @State private var position: MapCameraPosition = .automatic
    
    @State private var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555),
        span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
    )
    @State private var locationManager = CLLocationManager()
    @State private var searchText: String = "" // 用于搜索的文本框

    @Environment(\.dismiss) var dismiss
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, locationName: Binding<String>) {
        self._selectedLocation = selectedLocation
        self._locationName = locationName
    }
    
    var body: some View {
        ScrollView{
            VStack {
                // 地址搜索框
                TextField("输入地址或地点名称", text: $searchText, onCommit: {
                    searchAddress() // 按回车后进行搜索
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

                GeometryReader { geometry in
                    Map(position: $position){
                        Marker("活动位置", coordinate: selectedLocation ?? CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555))
                            .tint(.orange)
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .onMapCameraChange { context in
                        region = context.region
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5) // 设定长按最短时间为 0.5 秒
                            .onEnded { value in
                                // 获取点击位置的坐标
                                let tappedLocation = region.center
                                selectedLocation = tappedLocation
                                reverseGeocode(location: tappedLocation) // 获取地址
                            }
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(height: 500)  // 外部 frame 调整
                
                VStack {
                    Text("所选位置📍：")
                        .bold()
                    
                    Text("\(locationName)")
                        .bold()
                    
                    HStack {
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
        }
//        .onAppear {
//            locationManager.requestWhenInUseAuthorization()
//            if CLLocationManager.locationServicesEnabled() {
//                locationManager.delegate = locationManager as? CLLocationManagerDelegate
//                locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//                locationManager.startUpdatingLocation()
//            }
//        }
        .onChange(of: locationManager.authorizationStatus) { oldValue, status in
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                DispatchQueue(label: "定位", qos: .background).async {
                    locationManager.delegate = locationManager as? CLLocationManagerDelegate
                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
                    locationManager.startUpdatingLocation()
                }
            }
        }
    }
    
    // TODO: MVVM 架构
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
                position = .automatic
                // 如果需要，可以调用其他方法来重新渲染地图或进行其他操作
                print("找到位置: \(placemark.name ?? "未知位置")")
            } else {
                // TODO: 提示
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

