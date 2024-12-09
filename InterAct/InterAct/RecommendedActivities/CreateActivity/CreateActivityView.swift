//
//  CreateActivityView.swift
//  InterAct
//
//  Created by admin on 2024/11/27.
//

import SwiftUI
import CoreLocation
import MapKit

struct CreateActivityView: View {
    @StateObject var viewModel = CreateActivityViewModel()
    @State private var showingTagSelection = false // 用于控制弹窗的显示
    @State private var tempSelectedTags: [String] = ["无🚫"] // 存储临时选择的标签
    @State private var showConfirmationAlert = false // 显示确认弹窗
    @State private var dateError: Bool = false // 错误提示：日期不能小于当前时间
    @State private var showingMapView = false // 控制是否显示地图选择地点
    @State private var locationManager = CLLocationManager()
    
    @Environment(\.dismiss) var dismiss
    
    // 获取兴趣标签列表
    let availableTags = Interest().InterestTags
    
    var body: some View {
        NavigationView {
            Form {
                // 标题
                Section(header: Text("标题")) {
                    TextField("请输入活动标题", text: $viewModel.activityName)
                }
                
                // 标签选择部分
                Section(header: Text("选择标签")) {
                    HStack {
                        Text(viewModel.selectedTags.isEmpty ? "请选择标签" : viewModel.selectedTags.joined(separator: ", "))
                        Spacer()
                        Button(action: {
                            showingTagSelection.toggle() // 弹出标签选择界面
                        }) {
                            Text("选择")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // 日期
                Section(header: Text("选择日期")) {
                    DatePicker("活动时间", selection: $viewModel.activityTime, displayedComponents: [.date, .hourAndMinute])
                        .environment(\.locale, Locale(identifier: "zh_CN")) // 设置为中文显示
                }
                
                // 人数
                Section(header: Text("选择人数")) {
                    Stepper("最多参与人数：\(viewModel.participantsCount)", value: $viewModel.participantsCount, in: 2...100)
                    Text("人数上限为：100") // 显示当前字数
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // 简介
                Section(header: Text("活动简介")) {
                    TextEditor(text: $viewModel.activityDescription)
                        .frame(height: 150)
                        .onChange(of: viewModel.activityDescription) {
                            // 限制简介字符数为200以内
                            if viewModel.activityDescription.count > 200 {
                                viewModel.activityDescription = String(viewModel.activityDescription.prefix(200))
                            }
                        }
                    Text("\(viewModel.activityDescription.count)/200 字") // 显示当前字数
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                // 上传照片
                Section(header: Text("上传一张照片（可选）")) {
                    HStack {
                        Button("选择照片") {
                            // 这里可以通过ImagePicker选择照片
                            viewModel.isImagePickerPresented = true // 这里模拟上传照片
                        }
                        
                        Button(action: {
                            viewModel.selectedImage = nil
                        }) {
                            Image(systemName: "multiply.circle.fill")
                                .foregroundStyle((viewModel.selectedImage != nil) ? .red : .gray)
                        }
                        .padding()
                    }
                    Image(uiImage: viewModel.selectedImage ?? UIImage())
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                }
                
                // 选择定位
                Section(header: Text("选择活动地点")) {
                    Button("当前选定位置：\(viewModel.selectedLocationName)") {
                        // 在这里可以选择发起人所在地或者点击地图选择
                        showingMapView.toggle() // 显示地图界面
                    }
                    if viewModel.islocationDistanceWarning {
                        Text(viewModel.locationDistanceWarning)
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, 5)
                    }
                }
                
                // 发布按钮
                Section {
                    Button("确认发布") {
                        viewModel.createActivity()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .navigationTitle("发布活动")
            .sheet(isPresented: $viewModel.isImagePickerPresented) {
                AvatarImagePicker.ImagePicker(
                    selectedImage: $viewModel.selectedImage,
                    onImagePicked: {
                        viewModel.isImageEditingPresented = true
                    },
                    isEditingPresented: $viewModel.isImageEditingPresented
                )
            }
            .fullScreenCover(isPresented: $viewModel.isImageEditingPresented) {
                if viewModel.selectedImage != nil {
                    CropImageView(image: $viewModel.selectedImage) { croppedImage in
                        viewModel.selectedImage = croppedImage
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(title: Text("提示"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("确定")))
            }
            .sheet(isPresented: $showingTagSelection) {
                TagSelectionView(availableTags: availableTags, selectedTags: $viewModel.selectedTags, showingTagSelection: $showingTagSelection)
            }
            .sheet(isPresented: $showingMapView) {
                MapView(selectedLocation: $viewModel.location, locationName: $viewModel.selectedLocationName) // 显示地图视图来选择位置
                    .onDisappear {
                        viewModel.updateLocationDistanceWarning()
                    }
            }
            .onChange(of: viewModel.isCreateSuccessfully) {
                if viewModel.isCreateSuccessfully {
                    dismiss()  // 调用 dismiss() 关闭当前视图
                }
            }
        }
        // TODO: 可以在主界面加上一个刷新按钮，按下后重新定位
//        .onAppear {
//            viewModel.startUpdatingLocation() // 确保在视图出现时开始位置更新
//        }
//        .onDisappear {
//            viewModel.stopUpdatingLocation() // 停止更新位置
//        }
    }
}

// 选择标签的弹窗视图
struct TagSelectionView: View {
    let availableTags: [String]
    @Binding var selectedTags: [String] // 绑定选择的标签
    @Binding var showingTagSelection: Bool // 用于关闭标签选择弹窗
    
    var body: some View {
        NavigationView {
            List(availableTags, id: \.self) { tag in
                MultipleSelectionRow(tag: tag, isSelected: selectedTags.contains(tag)) {
                    if tag == "无🚫" {
                        // 如果选择了"无"标签，取消其他标签的选择
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags = [tag] // 只保留"无"标签
                        }
                    } else {
                        // 如果之前选择了"无"标签，取消"无"标签的选择
                        if selectedTags.contains("无🚫") {
                            selectedTags.removeAll { $0 == "无🚫" }
                        }
                        
                        // 其他标签的处理逻辑
                        if selectedTags.contains(tag) {
                            selectedTags.removeAll { $0 == tag }
                        } else {
                            selectedTags.append(tag)
                        }
                    }
                }
            }
            .navigationTitle("选择标签")
            .navigationBarItems(trailing: Button("完成") {
                // 如果用户没有选择标签，默认选择"无"标签
                if selectedTags.isEmpty {
                    selectedTags = ["无🚫"]
                }
                showingTagSelection = false
            })
        }
    }
}

// 多标签选择视图
struct MultipleSelectionListView: View {
    var tag: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(tag)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            self.action()
        }
    }
}

// 标签行组件
struct MultipleSelectionRow: View {
    var tag: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        HStack {
            Text(tag)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            self.action()
        }
    }
}

