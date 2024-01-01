//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation

extension Account {
    func amountIn(_ dateRange: ClosedRange<Date>, in context: ViewModel) -> Double {
        let increaseRecords = increaseRecords(in: context).filter { dateRange.contains($0.date) }
        let decreaseRecords = decreaseRecords(in: context).filter { dateRange.contains($0.date) }
        let increase = increaseRecords.map(\.amount).reduce(0, +)
        let decrease = decreaseRecords.map(\.amount).reduce(0, +)
        return increase - decrease
    }

    func amountBefore(_ date: Date, in context: ViewModel) -> Double {
        initialValue
            +
            increaseRecords(in: context).filter { record in
                record.date <= date
            }.map(\.amount).reduce(0, +)
            -
            decreaseRecords(in: context).filter { record in
                record.date <= date
            }.map(\.amount).reduce(0, +)
    }

    func currentAmount(in context: ViewModel) -> Double {
        initialValue
            +
            increaseRecords(in: context).map(\.amount).reduce(0, +)
            -
            decreaseRecords(in: context).map(\.amount).reduce(0, +)
    }

    func increaseRecords(in context: ViewModel) -> [Record] {
        switch kind.type {
        case .debit:
            return context.creditRecords(of: self)
        case .credit:
            return context.debitRecords(of: self)
        }
    }

    func decreaseRecords(in context: ViewModel) -> [Record] {
        switch kind.type {
        case .debit:
            return context.debitRecords(of: self)
        case .credit:
            return context.creditRecords(of: self)
        }
    }

    func recordCount(in context: ViewModel) -> Int {
        context.recordCount(of: self)
    }

    func records(in context: ViewModel) -> [Record] {
        context.records(of: self)
    }

    func records(in context: ViewModel, dateRange: ClosedRange<Date>) -> [Record] {
        context.records(of: self, in: dateRange)
    }
}

extension Record {
    func debitAccount(in context: ViewModel) -> Account {
        context.debitAccounts(of: self)
    }

    func creditAccount(in context: ViewModel) -> Account {
        context.creditAccounts(of: self)
    }
}

extension ViewModel {
    func creditAccounts(of record: Record) -> Account {
        accounts.first { account in
            account.id == record.creditAccountId
        }!
    }

    func debitAccounts(of record: Record) -> Account {
        accounts.first { account in
            account.id == record.debitAccountId
        }!
    }

    func debitRecords(of account: Account) -> [Record] {
        records.filter { record in
            record.debitAccountId == account.id
        }
    }

    func creditRecords(of account: Account) -> [Record] {
        records.filter { record in
            record.creditAccountId == account.id
        }
    }

    func recordCount(of account: Account) -> Int {
        records.filter { record in
            (record.creditAccountId == account.id) || (record.debitAccountId == account.id)
        }.count
    }

    func records(of account: Account) -> [Record] {
        records.filter { record in
            record.creditAccountId == account.id
        }.sorted(by: { $0.date > $1.date })
    }

    func records(of account: Account, in dateRange: ClosedRange<Date>) -> [Record] {
        records(of: account)
            .filter { record in
                dateRange.contains(record.date)
            }
    }

    func availableDateRange() -> ClosedRange<Date> {
        if let firstDate = records.map(\.date).min() {
            return firstDate ... Date()
        } else {
            return Date() ... Date()
        }
    }

    func firstDate() -> Date {
        records.map(\.date).min() ?? Date()
    }
}
