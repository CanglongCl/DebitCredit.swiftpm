//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/14.
//

import SwiftUI

// MARK: - NavigationLinkPickerStyle

struct NavigationLinkPickerStyle: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.pickerStyle(.navigationLink)
        } else {
            content
        }
    }
}

extension View {
    func navigationLinkPickerStyle() -> some View {
        modifier(NavigationLinkPickerStyle())
    }
}
