//
//  File.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Foundation
import SwiftUI

var accountDataFileURL: URL {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("account", conformingTo: .json)
    if !FileManager.default.fileExists(atPath: url.absoluteString) {
        try! FileManager.default.createFile(atPath: url.absoluteString, contents: JSONEncoder().encode([Account]()))
    }
    return url
}

var recordDataFileURL: URL {
    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        .appendingPathComponent("record", conformingTo: .json)
    if !FileManager.default.fileExists(atPath: url.absoluteString) {
        try! FileManager.default.createFile(atPath: url.absoluteString, contents: JSONEncoder().encode([Record]()))
    }
    return url
}

private var debugDataHasApplied: Bool {
    get {
        UserDefaults.standard.bool(forKey: UserDefaultKeys.debugDataHasApplied)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.debugDataHasApplied)
    }
}

// MARK: - ViewModel

class ViewModel: ObservableObject {
    // MARK: Lifecycle

    private init() {
        load()
        if accounts.isEmpty, records.isEmpty {
            if !debugDataHasApplied {
                replacingUsingDemoData()
                debugDataHasApplied = true
            }
        }
    }

    // MARK: Internal

    static let shared: ViewModel = .init()

    let queue: DispatchQueue = .init(label: "SaveDatas", qos: .background)

    @Published
    var accounts: [Account] = [] {
        didSet {
            saveAccounts()
        }
    }

    var records: [Record] {
        _records.sorted(by: { $0.date < $1.date })
    }

    func add(_ newAccount: Account) {
        accounts.append(newAccount)
    }

    func add(_ newRecord: Record) {
        _records.append(newRecord)
    }

    func delete(_ record: Record) {
        let index = _records.firstIndex(of: record)!
        _records.remove(at: index)
    }

    func delete(_ account: Account) {
        let index = accounts.firstIndex(of: account)!
        accounts.remove(at: index)
        records.filter { record in
            (record.creditAccountId == account.id) || (record.debitAccountId == account.id)
        }.forEach { record in
            delete(record)
        }
    }

    func replacingUsingDemoData() {
        _records = DemoData.records
        accounts = DemoData.accounts
    }

    func deleteAll() {
        _records = []
        accounts = []
    }

    // MARK: Private

    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    @Published
    private var _records: [Record] = [] {
        didSet {
            saveRecords()
        }
    }

    private func save() {
        saveAccounts()
        saveRecords()
    }

    private func saveAccounts() {
        queue.async {
            do {
                let data = try self.encoder.encode(self.accounts)
                try data.write(to: accountDataFileURL)
            } catch {
                print(error)
            }
        }
    }

    private func saveRecords() {
        queue.async {
            do {
                let data = try self.encoder.encode(self.records)
                try data.write(to: recordDataFileURL)
            } catch {
                print(error)
            }
        }
    }

    private func load() {
        do {
            accounts = try decoder.decode([Account].self, from: Data(contentsOf: accountDataFileURL))
            _records = try decoder.decode([Record].self, from: Data(contentsOf: recordDataFileURL))
        } catch {
            print(error)
        }
    }
}
