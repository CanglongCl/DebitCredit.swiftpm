//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/18.
//

import Foundation

enum UserDefaultKeys {
    static let onBoardingViewHasShown = "onBoardingViewHasShown"
    static let debugDataHasApplied = "debugDataHasApplied"

    func registerUserDefault() {
        UserDefaults.standard.register(defaults: [
            Self.onBoardingViewHasShown: false,
            Self.debugDataHasApplied: false,
        ])
    }
}
