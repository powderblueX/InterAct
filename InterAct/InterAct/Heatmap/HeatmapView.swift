//
//  HeatmapView.swift
//  InterAct
//
//  Created by admin on 2024/12/2.
//

import SwiftUI
import MapKit
import Charts

struct HeatmapView: View {
    @StateObject private var viewModel = HeatmapViewModel()
    @State private var zoomScale: Double = 1.0 // 记录地图缩放比例
    
    var body: some View {
        ZStack{
            Map(position: $viewModel.position){
                ForEach(viewModel.regions){ region in
                    Annotation("", coordinate: region.center){
                        VStack {
                            Circle()
                                .fill(getHeatmapColor(for: region))
                                .frame(width: getScaledSize(for: region), height: getScaledSize(for: region))
                                .onTapGesture {
                                    viewModel.selectedRegion = region
                                    viewModel.showDetails = true // 显示详情
                                }
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: MapCameraUpdateFrequency.continuous){ context in
                updateZoomScale(from: context.region)
                viewModel.region = context.region
            }
            // 显示详细信息框，如果选择了区域
            if viewModel.showDetails, let region = viewModel.selectedRegion {
                // 遮罩层
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        viewModel.showDetails = false // 点击遮罩层关闭详情
                    }
                
                // 详情框
                LazyVStack {
                    ScrollView{
                        HStack {
                            Text("区域活动总数: \(region.activityCount)")
                                .font(.headline)
                            Spacer()
                        }
                        .padding()
                        
                        Text("总参与人数: \(region.totalAttendees)")
                        
                        let chartData: [String: Int] = region.categoryCount
                        ScrollView(.horizontal, showsIndicators: true){
                            Chart {
                                // 为每个字典条目创建一个条形图
                                ForEach(Array(chartData.keys), id: \.self) { key in
                                    BarMark(
                                        x: .value("Category", key),
                                        y: .value("End", chartData[key]!)
                                    )
                                    .foregroundStyle(.blue)  // 设置条形的颜色
                                }
                            }
                            .frame(width: 70*CGFloat(region.categoryCount.count), height: 150, alignment: .center)
                            .padding(.top, 7)
                        }
                        
                        Spacer()
                        
                        // 关闭按钮
                        Button(action: {
                            viewModel.showDetails = false
                        }) {
                            Image(systemName: "xmark.circle")
                        }
                        .padding(.top, 10)
                        .padding(.bottom, 5)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white).shadow(radius: 10))
                    .padding(.top, 40) // 距离顶部一定的空间
                    .frame(maxWidth: 300) // 使其横向扩展
                    .animation(.spring(), value: region) // 动画效果
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
        
    
    // 热力图颜色、透明度
    func getHeatmapColor(for region: HeatmapRegion) -> Color {
        let density = Double(region.activityCount) / 4.0  // 假设最大活动数为 10
        // 计算每种颜色的分量
        let red: Double
        let green: Double
        let blue: Double
        
        // 颜色过渡的范围
        if density < 0.5 {
            // 从蓝色到黄色的过渡
            red = density * 2.0   // 增加红色分量
            green = density * 2.0  // 增加绿色分量
            blue = 1.0 - density * 2.0  // 减少蓝色分量
        } else {
            // 从黄色到红色的过渡
            red = 1.0            // 红色固定最大
            green = 2.0 - density * 2.0  // 减少绿色分量
            blue = 0.0           // 蓝色为 0
        }
        // 透明度随着活动数增加而增大
        let opacity = min(0.3 + density * 0.4, 5.0) // 最小透明度0.6，最大透明度1.0
        return Color(red: red, green: green, blue: blue) // 蓝色到红色渐变
            .opacity(opacity)
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

