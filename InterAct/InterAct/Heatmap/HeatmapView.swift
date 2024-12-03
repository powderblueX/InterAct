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

    var body: some View {
        ZStack{
            Map(position: $viewModel.position){
                ForEach(viewModel.regions){ region in
                    Annotation("", coordinate: region.center){
                        VStack {
                            Circle()
                                .fill(viewModel.getHeatmapColor(for: region))
                                .frame(width: viewModel.getScaledSize(for: region),
                                       height: viewModel.getScaledSize(for: region))
                                .onTapGesture {
                                    viewModel.selectedRegion = region
                                    viewModel.showDetails = true // 显示详情
                                }
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: MapCameraUpdateFrequency.continuous){ context in
                viewModel.updateZoomScale(from: context.region)
                viewModel.region = context.region
            }
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            .onAppear{
                viewModel.loadHeatmapActivities()
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
                        VStack {
                            Text("区域活动总数: \(region.activityCount)")
                                .font(.headline)
                            Spacer()
                            Text("总参与人数: \(region.totalAttendees)")
                                .font(.headline)
                        }
                        .padding()

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
}

