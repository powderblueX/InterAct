//
//  ActivityDetailView.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import SwiftUI
import Kingfisher

struct ActivityDetailView: View {
    @StateObject var viewModel = ActivityDetailViewModel()
    var activity: Activity
    
    var body: some View {
        VStack {
            Text("活动详情")
                .font(.largeTitle)
                .padding()
            Text("活动名: \(activity.activityName)")
            Text("时间: \(activity.activityTime)")
            Text("活动简介: \(activity.activityDescription)")
            if let imageURL = activity.image {
                KFImage(URL(string: imageURL.absoluteString))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .onTapGesture {
                        // 点击头像，显示大图
                        viewModel.isImageSheetPresented = true
                    }
                    .contextMenu {
                        Button(action: {
                            viewModel.showSaveImageAlert = true
                        }) {
                            Label("保存图片", systemImage: "square.and.arrow.down")
                        }
                    }
            }
        }
        .padding()
        // 弹窗展示头像预览
        .sheet(isPresented: $viewModel.isImageSheetPresented) {
            if let imageURL = activity.image {
                ImagePreviewView(imageURL: imageURL, isPresented: $viewModel.isImageSheetPresented)
            }
        }
    }
}

