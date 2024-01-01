//
//  Model.swift
//  DebtCredit
//
//  Created by 戴藏龙 on 2023/4/7.
//

import Foundation
import SwiftUI

// MARK: - Tag

enum Tag: String, Codable, CaseIterable {
    case food
    case transportation
    case shopping
    case entertainment
    case travel
    case housing
    case utilities
    case education
    case health
    case investment
    case income
    case gift
    case charity
}

// MARK: Identifiable

extension Tag: Identifiable {
    var id: String { rawValue }
}

extension Tag {
    func image() -> Image {
        switch self {
        case .food:
            return .init(systemName: "takeoutbag.and.cup.and.straw")
        case .transportation:
            return .init(systemName: "bus")
        case .shopping:
            return .init(systemName: "cart")
        case .entertainment:
            return .init(systemName: "gamecontroller")
        case .travel:
            return .init(systemName: "figure.walk.departure")
        case .housing:
            return .init(systemName: "house")
        case .utilities:
            return .init(systemName: "briefcase")
        case .education:
            return .init(systemName: "brain.head.profile")
        case .health:
            return .init(systemName: "heart.rectangle")
        case .investment:
            return .init(systemName: "banknote")
        case .income:
            return .init(systemName: "dollarsign.arrow.circlepath")
        case .gift:
            return .init(systemName: "gift")
        case .charity:
            return .init(systemName: "giftcard")
        }
    }

    func color() -> Color {
        switch self {
        case .food:
            return .cyan
        case .transportation:
            return .teal
        case .shopping:
            return .purple
        case .entertainment:
            return .pink
        case .travel:
            return .orange
        case .housing:
            return .mint
        case .utilities:
            return .indigo
        case .education:
            return .cyan
        case .health:
            return .indigo
        case .investment:
            return .teal
        case .income:
            return .green
        case .gift:
            return .orange
        case .charity:
            return .mint
        }
    }
}
