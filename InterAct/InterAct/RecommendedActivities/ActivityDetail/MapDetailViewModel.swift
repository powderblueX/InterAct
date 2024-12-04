//
//  MapDetailViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import Foundation
import MapKit

//class MapDetailViewModel: ObservableObject {
//    @Published var activityLocation: CLLocationCoordinate2D
//    @Published var myCLLocation: CLLocationCoordinate2D
//    
//    @Published var mapRegion: MKCoordinateRegion
//    @Published var showRoute = false
//    @Published var directions: [MKRoute] = []
//    @Published var selectedTransportType: TransportType = .automobile
//    
//    init(myCLLocation: CLLocationCoordinate2D, activityLocation: CLLocationCoordinate2D) {
//        self.myCLLocation = myCLLocation
//        self.activityLocation = activityLocation
//        self.mapRegion = MKCoordinateRegion(
//            center: myCLLocation,
//            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
//        )
//    }
//    
//    // 获取从当前位置到活动地点的路径
//    func getDirections() {
//        let sourcePlacemark = MKPlacemark(coordinate: myCLLocation)
//        let destinationPlacemark = MKPlacemark(coordinate: activityLocation)
//        
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: sourcePlacemark)
//        request.destination = MKMapItem(placemark: destinationPlacemark)
//        request.requestsAlternateRoutes = true
//        
//        // 根据用户选择的交通方式设置请求类型
//        switch selectedTransportType {
//        case .walking:
//            request.transportType = .walking
//        case .cycling:
//            request.transportType = .automobile // MKDirections 并没有直接支持骑行路线，通常用汽车路径来模拟
//        case .automobile:
//            request.transportType = .automobile
//        }
//        
//        let directions = MKDirections(request: request)
//        directions.calculate { [weak self] response, error in
//            if let error = error {
//                print("路径计算失败: \(error.localizedDescription)")
//                return
//            }
//            if let route = response?.routes.first {
//                self?.directions = [route]
//                self?.showRoute = true
//            }
//        }
//    }
//}
