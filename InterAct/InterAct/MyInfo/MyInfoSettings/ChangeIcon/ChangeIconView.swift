//
//  ChangeIconView.swift
//  InterAct
//
//  Created by admin on 2024/12/11.
//

import SwiftUI

struct ChangeIconView: View {
    @ObservedObject var viewModel = ChangeIconViewModel()

    var body: some View {
        List {
            ForEach(AppCustomIcon.allValues, id:\.self) { icon in
                HStack {
                    Image(uiImage: (UIImage(named: icon.rawValue) ?? UIImage(systemName: "photo.badge.exclamationmark")) ?? UIImage())
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44,height: 44)
                        .cornerRadius(12)
                    Text(icon.rawValue)
                }
                .onTapGesture {
                    viewModel.setUserCustomIcon(name: icon)
                }
            }
        }
        .scrollTargetBehavior(.paging)
    }
}

#Preview {
    ChangeIconView()
}
