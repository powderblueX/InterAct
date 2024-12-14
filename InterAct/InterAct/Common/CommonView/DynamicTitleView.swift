//
//  DynamicTitleView.swift
//  InterAct
//
//  Created by admin on 2024/12/13.
//

import SwiftUI

// 动态背景视图
// 动态背景视图
struct DynamicBackgroundView: View {
    @State private var gradientColors = [Color.blue, Color.cyan]
    @State private var startPoint = UnitPoint.top
    @State private var endPoint = UnitPoint.bottom

    var body: some View {
        LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: startPoint, endPoint: endPoint)
            .animation(
                Animation.easeInOut(duration: 3).repeatForever(autoreverses: true),
                value: gradientColors
            )
            .onAppear {
                withAnimation {
                    gradientColors = [.cyan, .gray]
                    startPoint = .bottomLeading
                    endPoint = .topTrailing
                }
            }
            .overlay(
                Canvas { context, size in
                    for _ in 0..<15 {
                        let circlePosition = CGPoint(
                            x: CGFloat.random(in: 0...size.width),
                            y: CGFloat.random(in: 0...size.height)
                        )
                        context.fill(
                            Circle()
                                .path(in: CGRect(x: circlePosition.x, y: circlePosition.y, width: 50, height: 50)),
                            with: .color(.white.opacity(0.2))
                        )
                    }
                }
            )
            .blur(radius: 50)
    }
}

// 渐变文字扩展
extension View {
    func gradientForeground(colors: [Color]) -> some View {
        self.overlay(
            LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
        )
        .mask(self)
    }
}

#Preview {
    DynamicBackgroundView()
}
