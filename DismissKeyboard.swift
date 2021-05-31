//
//  DissmissKeyboard.swift
//  Memo
//
//  Created by Nicolas Bouyssounouse on 03/05/2021.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
