//
//  ActivityDetailViewModel.swift
//  InterAct
//
//  Created by admin on 2024/11/29.
//

import Foundation

class ActivityDetailViewModel: ObservableObject {
    @Published var isImageSheetPresented: Bool = false
    @Published var showSaveImageAlert: Bool = false
}
