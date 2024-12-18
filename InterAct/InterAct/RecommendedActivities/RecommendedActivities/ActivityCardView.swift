//
//  ActivityCardView.swift
//  InterAct
//
//  Created by admin on 2024/11/30.
//

import SwiftUI

// 活动卡片视图
struct ActivityCardView: View {
    @StateObject private var viewModel = RecommendedActivitiesViewModel()
//    @State private var floatingOffset: CGFloat = 0 // 卡片的浮动偏移量
//    @State private var floatingDirection: Bool = true // 控制浮动方向
    
    var activity: Activity
    
    var body: some View {
        VStack {
            Text(activity.activityName)
                .font(.headline)
                .padding(.top, 5)
            
            Text(activity.formattedTime)
                .font(.subheadline)
                .lineLimit(3)
                .padding(.top, 2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .center)
                .environment(\.locale, Locale(identifier: "zh_CN"))
            
            Text("标签: \(activity.interestTag.joined(separator: ", "))")
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.top, 2)
            
            Text("参与人数: \(activity.participantIds.count)/\(activity.participantsCount)")
                .font(.footnote)
                .foregroundColor(viewModel.getparticipantsCountColor(isFull: activity.participantIds.count == activity.participantsCount))
                .padding(.top, 1)
            
            Text("离你 \(viewModel.LocationDistance(location: activity.location)) km")
                .font(.footnote)
                .padding(.top, 1)
                .foregroundColor(.brown)
                .background(Color(UIColor.secondarySystemBackground)) // 背景颜色
        }
        .padding()
        .background(Color(UIColor.secondarySystemBackground)) // 背景颜色
        .cornerRadius(10)
        .shadow(radius: 5)
//        .offset(y: floatingOffset) // 应用浮动偏移量
//        .onAppear {
//            // 开始浮动动画
//            withAnimation(Animation.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
//                floatingOffset = floatingDirection ? -5 : 5
//                floatingDirection.toggle()
//            }
//        }
    }
}
