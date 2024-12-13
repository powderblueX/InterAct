//
//  LaunchAnimationView.swift
//  InterAct
//
//  Created by admin on 2024/12/13.
//

import SwiftUI

struct LaunchAnimationView: View {
    @State private var showInterest = false
    @State private var showActivity = false
    @State private var showLocation = false
    @State private var showChat = false
    @State private var showInterAct = false
    @State private var fadeOut = false
    @Binding var isActive: Bool // 用于控制动画结束后跳转到主界面

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // 背景色

            VStack {
                // 兴趣图标和文字
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(showInterest ? .red : .gray)
                        .scaleEffect(showInterest ? 1.2 : 0.5)
                        .animation(.easeInOut(duration: 0.5), value: showInterest)

                    Text("Interest")
                        .foregroundColor(.white)
                        .font(.title)
                        .opacity(showInterest ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: showInterest)
                }

                // 活动图标和文字
                HStack(spacing: 8) {
                    Image(systemName: "calendar.badge.plus")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(showActivity ? .orange : .gray)
                        .scaleEffect(showActivity ? 1.2 : 0.5)
                        .animation(.easeInOut(duration: 0.5), value: showActivity)
                    
                    Text("Activity")
                        .foregroundColor(.white)
                        .font(.title)
                        .opacity(showActivity ? 1 : 0)
                        .animation(.easeInOut(duration: 0.5).delay(0.2), value: showActivity)
                }

                // 定位和聊天图标
                HStack(spacing: 20) {
                    Image(systemName: "mappin.and.ellipse")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(showLocation ? .blue : .gray)
                        .rotationEffect(.degrees(showLocation ? 360 : 0))
                        .animation(.easeInOut(duration: 0.6), value: showLocation)
                    
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(showChat ? .green : .gray)
                        .offset(y: showChat ? 0 : 200)
                        .animation(.easeInOut(duration: 0.6), value: showChat)
                    
                    // InterAct 合并文字
                    if showInterest {
                        Text("InterAct")
                            .foregroundColor(.white)
                            .font(.largeTitle)
                            .bold()
                            .opacity(showInterAct ? 1 : 0)
                            .animation(.easeInOut(duration: 0.5).delay(0.4), value: showInterAct)
                    }
                }
            }
            .scaleEffect(fadeOut ? 0.5 : 1.0)
            .opacity(fadeOut ? 0 : 1)
            .animation(.easeInOut(duration: 0.8).delay(2.2), value: fadeOut)
        }
        .onAppear {
            startAnimation()
        }
    }

    private func startAnimation() {
        // 依次触发动画
        showInterest = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { showActivity = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showLocation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { showChat = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { showInterAct = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) { fadeOut = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) { isActive = false } // 跳转到主界面
    }
}
