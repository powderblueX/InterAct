//
//  InterActApp.swift
//  InterAct
//
//  Created by admin on 2024/11/26.
//

import SwiftUI

@main
struct InterActApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared // 全局状态
    @State private var isShowingMainView = false  // 控制主界面显示
    @State private var opacity: Double = 0.0      // 控制开场动画的透明度
    @State private var scale: CGFloat = 0.1       // 控制文本缩放
    @State private var translation: CGFloat = 50  // 控制文本的移动
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    // 确保你的设置按钮在主视图中正确显示
                    //                    if isShowingMainView {
                    Group {
                        if appState.isLoggedIn {
                            MainTabView() // 跳转到主页面
                        } else {
                            LoginView(viewModel: viewModel)
                        }
                    }
                    .animation(.easeInOut, value: isShowingMainView) // 添加平滑动画
                    .onAppear {
                        viewModel.autoLogin() // 自动登录
                    }
                    //                    } else {
                    //                        // 开场动画
                    //                        VStack {
                    //                            Text("志趣相投")
                    //                                .font(.system(size: 40, weight: .bold))
                    //                                .foregroundColor(Color.purple)
                    //                                .opacity(opacity)      // 设置透明度
                    //                                .scaleEffect(scale)    // 设置缩放
                    //                                .offset(y: translation) // 设置文本的偏移
                    //                        }
                    //                        .onAppear {
                    //                            // 动画效果：先缩放，然后透明度变化，最后消失
                    //                            withAnimation(.easeInOut(duration: 1.5)) {
                    //                                opacity = 1.0
                    //                                scale = 1.0
                    //                                translation = 0
                    //                            }
                    //
                    //                            // 动画结束后跳转到主界面
                    //                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    //                                withAnimation {
                    //                                    isShowingMainView = true
                    //                                }
                    //                            }
                    //                        }
                    //                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("提示"),
                    message: Text(viewModel.alertMessage),
                    dismissButton: .default(Text("确定"))
                )
            }
            .onOpenURL{ url in
                print(url.absoluteString)
               
                if let host = url.host, host == "activity" {
                    // 如果 URL 是特定的深链接
                    if let activityID = url.queryParameters?["id"] {
                        print("Received activity ID: \(activityID)")
                        // 更新 AppState，触发跳转
                        appState.activityIDToShow = activityID
                        appState.isToShow = true  // 使其跳转
                        
                    }
                }
            }
        }
    }
    func navigateToActivityDetail(activityID: String) {
        // 获取当前激活的场景和窗口
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("无法获取有效的窗口场景")
            return
        }
        
        // 创建 ActivityDetailView 并包装成 UIHostingController
        let activityDetailView = ActivityDetailView(activityId: activityID) // 传递活动 ID
        let hostingController = UIHostingController(rootView: activityDetailView)
        
        if let rootNavController = window.rootViewController as? UINavigationController {
            // 如果根控制器是导航控制器，直接 push
            rootNavController.pushViewController(hostingController, animated: true)
        } else {
            // 否则，创建导航控制器并设置为根控制器
            let navController = UINavigationController(rootViewController: hostingController)
            window.rootViewController = navController
            window.makeKeyAndVisible()
        }
    }
}
