//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation
import SwiftUI

// MARK: - DefaultAlert

struct DefaultAlert: ViewModifier {
    let title: LocalizedStringKey
    @Binding
    var isAlertShow: Bool
    var buttonTitle: String = "OK"
    var message: String?
    var dismissCompletion: () -> () = {}

    func body(content: Content) -> some View {
        if let message {
            content.alert(title, isPresented: $isAlertShow) {
                DefaultAlertDismissButton(
                    title: buttonTitle,
                    isAlertShow: $isAlertShow,
                    dismissCompletion: dismissCompletion
                )
            } message: {
                Text(message)
            }
        } else {
            content.alert(title, isPresented: $isAlertShow) {
                DefaultAlertDismissButton(
                    title: buttonTitle,
                    isAlertShow: $isAlertShow,
                    dismissCompletion: dismissCompletion
                )
            }
        }
    }
}

// MARK: - DefaultAlertDismissButton

struct DefaultAlertDismissButton: View {
    var title: String = "OK"
    @Binding
    var isAlertShow: Bool
    var dismissCompletion: () -> () = {}

    var body: some View {
        Button("OK") {
            isAlertShow.toggle()
            dismissCompletion()
        }
    }
}

extension View {
    func defaultAlert(
        title: LocalizedStringKey,
        isPresented: Binding<Bool>,
        buttonTitle: String = "OK",
        message: String? = nil,
        dismissCompletion: @escaping () -> () = {}
    )
        -> some View {
        modifier(DefaultAlert(
            title: title,
            isAlertShow: isPresented,
            buttonTitle: buttonTitle,
            message: message,
            dismissCompletion: dismissCompletion
        ))
    }
}
