//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation

/// call .string return 2 digits number string
let doubleFormatter = {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .decimal
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    return numberFormatter
}()
