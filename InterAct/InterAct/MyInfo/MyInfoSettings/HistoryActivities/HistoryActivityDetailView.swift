//
//  ActivityDetailView.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import SwiftUI
import Kingfisher
import MapKit
import CoreLocation

struct HistoryActivityDetailView: View {
    @State var historyActivity: Activity?
    @State var showMap: Bool = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 37)  {
                ScrollView{
                    // 活动标题
                    Text(historyActivity?.activityName ?? "加载中...")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)
                        .padding(.bottom)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("发起人：    ")
                                .font(.system(size: 25, weight: .semibold))
                            HStack {
                                Text(historyActivity?.hostUsername ?? "加载中...")
                                    .font(.system(size: 22, weight: .semibold))
                                    .foregroundColor(.brown)
                                    
                            }
                        }
                        
                        // 活动兴趣标签
                        // 兴趣标签
                        HStack {
                            Text("兴趣标签：")
                                .font(.system(size: 25, weight: .semibold))
                            Text(historyActivity?.interestTag.joined(separator: ", ") ?? "加载中...")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.purple)
                        }
                        
                        // 活动日期
                        HStack {
                            Text("活动时间：")
                                .font(.system(size: 25, weight: .semibold))
                            Text(historyActivity?.formattedTime ?? "加载中...")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.green)
                        }
                        
                        // 参与人数
                        HStack {
                            Text("参与人数：")
                                .font(.system(size: 25, weight: .semibold))
                            Text("\(historyActivity?.participantIds.count ?? 0)/\(historyActivity?.participantsCount ?? 0)")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(historyActivity?.participantIds.count == historyActivity?.participantsCount ? .red : .blue)
                        }
                        
                        // 活动地点
                        HStack {
                            Text("活动地点：")
                                .font(.system(size: 25, weight: .semibold))
                            Text(historyActivity?.locationName ?? "加载中...")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.orange)
                                .onTapGesture {
                                    // 点击活动地点时，显示地图
                                    showMap = true
                                }
                        }
                        
                        // 活动简介部分，使用 ScrollView
                        HStack{
                            Text("活动简介：")
                                .font(.system(size: 25, weight: .semibold))
                        }
                        HStack{
                            ScrollView {
                                Text(historyActivity?.activityDescription ?? "加载中...")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 300, height: 200, alignment: .leading)  // 固定高度，允许滚动
                            .padding(10)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .padding()
            }
            
        }
    }
}
