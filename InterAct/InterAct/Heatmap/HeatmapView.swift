//
//  HeatmapView.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import SwiftUI
import MapKit

struct HeatmapView: View {
    @StateObject private var viewModel = HeatmapViewModel()
    @State private var mapRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var zoomScale: Double = 1.0 // 记录地图缩放比例
    
    /// 根据活动数量计算热力图颜色
    private func getHeatmapColor(for region: HeatmapRegion) -> Color {
        let density = Double(region.activityCount) / 10.0  // 假设最大活动数为 10
        let red = min(1.0, density)
        let green = max(0.0, 1.0 - density)
        return Color(red: red, green: green, blue: 0.0) // 冷暖色渐变
    }
    
    var body: some View {
        ZStack{
            Map(coordinateRegion: $mapRegion, annotationItems: viewModel.regions) { region in
                MapAnnotation(coordinate: region.center) {
                    VStack {
                        Circle()
                            .fill(getHeatmapColor(for: region))
                            .frame(width: getScaledSize(for: region), height: getScaledSize(for: region))
                            .opacity(0.6)
                            .onTapGesture {
                                showDetails(for: region)
                            }
                    }
                }
            }
            .onChange(of: mapRegion) {oldRegion, newRegion in
                        updateZoomScale(from: newRegion)
                    }
        }
        .edgesIgnoringSafeArea(.all)
    }
    // 计算缩放比例后的尺寸
    private func getScaledSize(for region: HeatmapRegion) -> CGFloat {
        let baseSize: CGFloat = 2.0 // 每个活动的基础大小
        return CGFloat(region.activityCount) * baseSize / CGFloat(zoomScale)
    }
    // 更新缩放比例
    private func updateZoomScale(from region: MKCoordinateRegion) {
        let span = region.span
        zoomScale = max(span.latitudeDelta, span.longitudeDelta)
    }
    /// 显示热力区域的详细信息
    private func showDetails(for region: HeatmapRegion) {
        print("区域活动总数: \(region.activityCount)")
        print("总参与人数: \(region.totalAttendees)")
        print("活动种类: \(region.categoryCount)")
    }
}

extension MKCoordinateRegion: @retroactive Equatable {
    public static func == (lhs: MKCoordinateRegion, rhs: MKCoordinateRegion) -> Bool {
        lhs.center.latitude == rhs.center.latitude &&
        lhs.center.longitude == rhs.center.longitude &&
        lhs.span.latitudeDelta == rhs.span.latitudeDelta &&
        lhs.span.longitudeDelta == rhs.span.longitudeDelta
    }
}
