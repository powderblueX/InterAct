//
//  ChangeIconViewModel.swift
//  InterAct
//
//  Created by admin on 2024/12/11.
//

import Foundation
import SwiftUI

class ChangeIconViewModel: ObservableObject {
    func setUserCustomIcon(name: AppCustomIcon) {
        UIApplication.shared.setAlternateIconName(name == .Default ? nil : name.rawValue)
    }
}
