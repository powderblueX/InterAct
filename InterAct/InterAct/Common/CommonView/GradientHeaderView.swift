//
//  GradientHeaderView.swift
//  InterAct
//
//  Created by admin on 2024/12/15.
//

import SwiftUI

struct GradientHeaderView: View {
    var gradientStart: UnitPoint
    var gradientEnd: UnitPoint
    
    var body: some View {
        RoundedRectangle(cornerRadius: 7)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.8),
                        Color.cyan.opacity(0.8)
                    ]),
                    startPoint: gradientStart,
                    endPoint: gradientEnd
                )
            )
            .frame(height: 60)
    }
}
