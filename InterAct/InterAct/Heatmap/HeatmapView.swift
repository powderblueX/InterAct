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
        VStack{
            ZStack{
                // 冷色调动态渐变背景
                RoundedRectangle(cornerRadius: 7)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.8),
                                Color.purple.opacity(0.8),
                                Color.cyan.opacity(0.8)
                            ]),
                            startPoint: viewModel.gradientStart,
                            endPoint: viewModel.gradientEnd
                        )
                    )
                    .frame(height: 60) // 设置背景的高度
                    .onAppear {
                        viewModel.animateGradient()
                    }
                HStack{
                    TextField("输入地址或地点名称", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.trailing, 4)
                        .padding(.leading, 4)
                    
                    Button(action: {
                        viewModel.searchAddress(searchText: viewModel.searchText)
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding(.trailing, 8)
                            .foregroundColor(.white)
                    }
                }
            }
            ZStack{
                Map(position: $viewModel.position){
                    Marker("搜索位置", coordinate: viewModel.selectedLocation ??  CLLocationCoordinate2D(latitude: 39.90318236, longitude: 116.397755))
                        .tint(.orange)
                    Marker("我的位置", coordinate: viewModel.hostLocation ??  CLLocationCoordinate2D(latitude: 39.90318236, longitude: 116.397755))
                        .tint(.blue)
                    ForEach(viewModel.regions){ region in
                        Annotation("", coordinate: region.center) {
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
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                    MapScaleView()
                    MapPitchToggle()
                }
                .onMapCameraChange(frequency: MapCameraUpdateFrequency.continuous){ context in
                    viewModel.updateZoomScale(from: context.region)
                    viewModel.region = context.region
                    viewModel.setCameraToSelectedLocation()
                }
                .onAppear{
                    viewModel.loadHeatmapActivities()
                    viewModel.selectedLocation = viewModel.hostLocation
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
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color(UIColor.systemBackground)).shadow(radius: 10))
                        .padding(.top, 40) // 距离顶部一定的空间
                        .frame(maxWidth: 300) // 使其横向扩展
                        .animation(.spring(), value: region) // 动画效果
                    }
                }
            }
            .edgesIgnoringSafeArea(.all)
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
        .onChange(of: viewModel.selectedLocation) { oldLocation, newLocation in
            if let newLocation = newLocation {
                if viewModel.selectedLocation == nil || viewModel.selectedLocation?.latitude != newLocation.latitude || viewModel.selectedLocation?.longitude != newLocation.longitude {
                    viewModel.selectedLocation = newLocation
                }
            }
        }
    }
}
