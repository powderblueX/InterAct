//
//  MapDetailView.swift
//  InterAct
//
//  Created by admin on 2024/12/1.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapDetailView: View {
    var activityLocation: CLLocationCoordinate2D
    var myCLLocation: CLLocationCoordinate2D
    @Binding var directions: [MKRoute]
    
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
        VStack {
            Map {
                MapCircle(center: activityLocation, radius: 10.0).foregroundStyle(.orange.opacity(0.3))
                MapCircle(center: CLLocationCoordinate2D(latitude: 31.2800000, longitude: 121.2100000), radius: 10.0).foregroundStyle(.blue.opacity(0.3))
                Marker("活动位置", coordinate: activityLocation).tint(.orange)
                Marker("你的位置", coordinate: CLLocationCoordinate2D(latitude: 31.2800000, longitude: 121.2100000)).tint(.blue)
                MapPolyline(coordinates: [activityLocation, CLLocationCoordinate2D(latitude: 31.2800000, longitude: 121.2100000)]).stroke(.red.opacity(0.5), lineWidth: 5)
            }
            .mapStyle(MapStyleModel.mapStyle)
            .onAppear {
                getDirections()
            }
            
            if showRoute, !directions.isEmpty {
                MapRoute(directions: directions)
                    .padding(.top, 10)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    // 获取从当前位置到活动地点的路径
    func getDirections() {
        let sourcePlacemark = MKPlacemark(coordinate: myCLLocation)
        let destinationPlacemark = MKPlacemark(coordinate: activityLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
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


struct MapRoute: View {
    var directions: [MKRoute]
    
    var body: some View {
        if let route = directions.first {
            Path { path in
                let start = route.polyline.coordinates.first!
                path.move(to: CGPoint(x: start.latitude, y: start.longitude))
                for coordinate in route.polyline.coordinates {
                    path.addLine(to: CGPoint(x: coordinate.latitude, y: coordinate.longitude))
                }
            }
            .stroke(Color.blue, lineWidth: 3)
            .frame(maxHeight: .infinity)
        }
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

