//
//  MapDetailView.swift
//  InterAct
//
//  Created by admin on 2024/12/1.
//

import SwiftUI
import MapKit
import CoreLocation

// TODO: MVVM

struct MapDetailView: View {
    var activityLocation: CLLocationCoordinate2D
    var myCLLocation: CLLocationCoordinate2D
    @Binding var directions: [MKRoute]
    @State var selectedTransportType: TransportType = .automobile
    
    @State private var mapRegion: MKCoordinateRegion
    @State private var showRoute = false
    
    
    init(activityLocation: CLLocationCoordinate2D, myCLLocation: CLLocationCoordinate2D, directions: Binding<[MKRoute]>) {
        self.activityLocation = activityLocation
        self.myCLLocation = myCLLocation
        _directions = directions
        self._mapRegion = State(initialValue: MKCoordinateRegion(
            center: myCLLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        ))
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Map {
                MapCircle(center: activityLocation, radius: 10.0).foregroundStyle(.orange.opacity(0.3))
                MapCircle(center: myCLLocation, radius: 10.0).foregroundStyle(.blue.opacity(0.3))
                Marker("活动位置", coordinate: activityLocation).tint(.orange)
                Marker("你的位置", coordinate: myCLLocation).tint(.blue)
                
                // 使用 MKRoute 的 polyline 来绘制路径
                ForEach(directions, id: \.self) { route in
                    MapPolyline(coordinates: route.polyline.coordinates)
                        .stroke(Color.blue, lineWidth: 3)
                }
            }
            .mapStyle(MapStyleModel.mapStyle)
            .onAppear {
                getDirections()
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onChange(of: selectedTransportType){
                getDirections()
            }


            // 交通方式选择器
            Picker("交通方式", selection: $selectedTransportType){
                Image(systemName: "figure.walk").tag(TransportType.walking)
                Image(systemName: "bicycle").tag(TransportType.cycling)
                Image(systemName: "car").tag(TransportType.automobile)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.leading, 37)
            .padding(.trailing, 37)
            .padding(.bottom, 100)
        }
    }

    // 获取从当前位置到活动地点的路径
    func getDirections() {
        let sourcePlacemark = MKPlacemark(coordinate: myCLLocation)
        let destinationPlacemark = MKPlacemark(coordinate: activityLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        
        // 根据用户选择的交通方式设置请求类型
        switch selectedTransportType {
        case .walking:
            request.transportType = .walking
        case .cycling:
            request.transportType = .walking // 用步行路径来模拟
        case .automobile:
            request.transportType = .automobile
        }
        
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let route = response?.routes.first {
                self.directions = [route]
                self.showRoute = true
            }
        }
    }
}


// CLLocationManagerDelegate 处理位置更新
class LocationManagerDelegate: NSObject, CLLocationManagerDelegate {
    var updateLocation: (CLLocationCoordinate2D) -> Void

    init(updateLocation: @escaping (CLLocationCoordinate2D) -> Void) {
        self.updateLocation = updateLocation
        super.init()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // 更新用户当前位置
            updateLocation(location.coordinate)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("定位失败: \(error.localizedDescription)")
    }
}

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D]()
        for i in 0..<self.pointCount {
            coords.append(self.coordinate(at: i))
        }
        return coords
    }

    func coordinate(at index: Int) -> CLLocationCoordinate2D {
        let point = self.points()[index]
        return point.coordinate
    }
}
