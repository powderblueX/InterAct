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
    
    @StateObject var viewModel = MapViewModel()
    
    @Environment(\.dismiss) var dismiss
    
    init(selectedLocation: Binding<CLLocationCoordinate2D?>, locationName: Binding<String>) {
        self._selectedLocation = selectedLocation
        self._locationName = locationName
    }
    
    var body: some View {
        ScrollView{
            VStack {
                // 地址搜索框
                HStack{
                    TextField("输入地址或地点名称", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing, 8)
                    
                    Button(action: {
                        viewModel.searchAddress(searchText: viewModel.searchText)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding()
                
                GeometryReader { geometry in
                    Map(position: $viewModel.position){
                        Marker("活动位置", coordinate: selectedLocation ?? CLLocationCoordinate2D(latitude: 39.9075, longitude: 116.38805555))
                            .tint(.orange)
                    }
                    .mapControls {
                        MapUserLocationButton()
                        MapCompass()
                        MapScaleView()
                    }
                    .onMapCameraChange { context in
                        viewModel.region = context.region
                    }
                    .gesture(
                        LongPressGesture(minimumDuration: 0.5) // 设定长按最短时间为 0.5 秒
                            .onEnded { value in
                                // 获取点击位置的坐标
                                let tappedLocation = viewModel.region.center
                                viewModel.selectedLocation = tappedLocation
                                viewModel.reverseGeocode(location: tappedLocation) // 反向地理编码
                            }
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(height: 500)  // 外部 frame 调整
                
                VStack {
                    Text("所选位置📍：")
                        .bold()
                    
                    Text("\(viewModel.locationName)")
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
        .overlay(
            Group {
                if viewModel.errorSearchMessage != nil {
                    Text("搜索/定位失败🥺🥺🥺")
                        .padding()
                        .background(Color.black.opacity(0.7))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .transition(.opacity)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    viewModel.errorSearchMessage = nil
                                }
                            }
                        }
                }
            },
            alignment: .bottom
        )
//        .onChange(of: vlocationManager.authorizationStatus) { oldValue, status in
//            if status == .authorizedWhenInUse || status == .authorizedAlways {
//                DispatchQueue(label: "定位", qos: .background).async {
//                    locationManager.delegate = locationManager as? CLLocationManagerDelegate
//                    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//                    locationManager.startUpdatingLocation()
//                }
//            }
//        }
        .onChange(of: viewModel.selectedLocation) { oldLocation, newLocation in
            if let newLocation = newLocation {
                if selectedLocation == nil || selectedLocation?.latitude != newLocation.latitude || selectedLocation?.longitude != newLocation.longitude {
                    self.selectedLocation = newLocation
                }
            }
        }
        .onChange(of: viewModel.locationName) { oldLocationName, newLocationName in
            self.locationName = newLocationName
        }
    }
}

// 扩展 Optional<CLLocationCoordinate2D>，使其遵守 Equatable 协议
extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
