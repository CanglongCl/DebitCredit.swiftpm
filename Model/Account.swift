//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation
import SwiftUI

// MARK: - Account

struct Account: Codable {
    enum AccountKind: String, Codable {
        case asset
        case liability
        case revenue
        case expense
        case equity

        // MARK: Internal

        /// The type in record when the number of the account increase
        enum `Type`: Int, Codable {
            case debit
            case credit
        }

        /// The type in record when the number of this account increase
        var type: Type {
            switch self {
            case .asset, .expense:
                return .credit
            case .equity, .liability, .revenue:
                return .debit
            }
        }
    }

    var id: UUID = .init()
    var name: String
    var kind: AccountKind
    var initialValue: Double
}

// MARK: - Account.AccountKind + CaseIterable

extension Account.AccountKind: CaseIterable {}

// MARK: - Account + Identifiable

extension Account: Identifiable {}

// MARK: - Account + Equatable

extension Account: Equatable {
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Account + Hashable

extension Account: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(kind)
    }
}

extension Account.AccountKind {
    func inoutIcon(creditOrDebit: Account.AccountKind.`Type`) -> some View {
        let isDebit = (creditOrDebit == .debit)
        switch self {
        case .asset:
            if isDebit {
                return Image(systemName: "plus.circle").resizable().scaledToFit().foregroundColor(.green)
            } else {
                return Image(systemName: "minus.circle").resizable().scaledToFit().foregroundColor(.red)
            }
        case .equity, .liability:
            if isDebit {
                return Image(systemName: "minus.circle").resizable().scaledToFit().foregroundColor(.green)
            } else {
                return Image(systemName: "plus.circle").resizable().scaledToFit().foregroundColor(.red)
            }
        case .revenue:
            if isDebit {
                return Image(systemName: "arrow.up.circle").resizable().scaledToFit().foregroundColor(.red)
            } else {
                return Image(systemName: "arrow.down.circle").resizable().scaledToFit().foregroundColor(.green)
            }
        case .expense:
            if isDebit {
                return Image(systemName: "arrow.up.circle").resizable().scaledToFit().foregroundColor(.red)
            } else {
                return Image(systemName: "arrow.down.circle").resizable().scaledToFit().foregroundColor(.green)
            }
        }
    }

    func inoutIconString(creditOrDebit: Account.AccountKind.`Type`) -> String {
        let isDebit = (creditOrDebit == .debit)
        switch self {
        case .asset:
            if isDebit {
                return "＋"
            } else {
                return "－"
            }
        case .equity, .liability:
            if isDebit {
                return "－"
            } else {
                return "＋"
            }
        case .revenue:
            if isDebit {
                return "↑"
            } else {
                return "↓"
            }
        case .expense:
            if isDebit {
                return "↑"
            } else {
                return "↓"
            }
        }
    }

    func color(amountMoreThanZero: Bool) -> Color {
        switch self {
        case .asset, .revenue:
            if amountMoreThanZero {
                return .green
            } else {
                return .red
            }
        case .equity, .expense, .liability:
            if amountMoreThanZero {
                return .red
            } else {
                return .green
            }
        }
    }
}
