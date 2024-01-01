//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/16.
//

import Foundation

extension Calendar {
    func theEndOfDay(of date: Date) -> Date {
        self.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }

    func theStartOfDay(of date: Date) -> Date {
        self.date(bySettingHour: 0, minute: 0, second: 0, of: date)!
    }
}
