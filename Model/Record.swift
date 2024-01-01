//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation

// MARK: - Record

struct Record: Codable {
    // MARK: Lifecycle

    init(name: String, amount: Double, creditAccount: Account, debitAccount: Account, date: Date, tag: Tag) {
        self.name = name
        self.amount = amount
        self.debitAccountId = debitAccount.id
        self.creditAccountId = creditAccount.id
        self.date = date
        self.tag = tag
    }

    // MARK: Internal

    var id: UUID = .init()

    let name: String

    var amount: Double

    var creditAccountId: UUID
    var debitAccountId: UUID

    var date: Date
    var tag: Tag
}

// MARK: Equatable

extension Record: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: Identifiable

extension Record: Identifiable {}
