//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/15.
//

import Charts
import SwiftUI

// MARK: - IncomeStatementView

@available(iOS 16.0, *)
struct IncomeStatementView: View {
    @State
    var isHelpSheetShow: Bool = false

    var body: some View {
        NavigationView {
            List {
                IncomeStatementChartSection()
            }
            .sheet(isPresented: $isHelpSheetShow, content: {
                HelpSheet(isSheetShow: $isHelpSheetShow)
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        isHelpSheetShow.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
            }
            .navigationTitle("Income Statement")
        }
    }
}

// MARK: - IncomeStatementView_Previews

@available(iOS 16.0, *)
struct IncomeStatementView_Previews: PreviewProvider {
    static var previews: some View {
        IncomeStatementView()
            .environmentObject(ViewModel.shared)
    }

    @EnvironmentObject
    var viewModel: ViewModel
}

// MARK: - DateRangeOption

private enum DateRangeOption: Int, CaseIterable {
    case oneDay
    case threeDay
    case oneWeek
    case oneMonth
    case oneYear
    case customize

    // MARK: Internal

    var description: String {
        switch self {
        case .oneDay:
            return "Last 1 day"
        case .threeDay:
            return "Last 3 days"
        case .oneWeek:
            return "Last 7 days"
        case .oneMonth:
            return "Last 30 days"
        case .oneYear:
            return "Last 365 days"
        case .customize:
            return "Customize"
        }
    }
}

// MARK: - IncomeStatementChartSection

@available(iOS 16.0, *)
private struct IncomeStatementChartSection: View {
    @EnvironmentObject
    var viewModel: ViewModel

    private let formatter: DateIntervalFormatter = {
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    @State
    var dateRangeOption: DateRangeOption = .oneYear

    @State
    private var startDate: Date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    @State
    private var endDate: Date = .init()

    var dateRange: ClosedRange<Date> {
        let startDate: Date
        var endDate: Date = Calendar.current.theEndOfDay(of: Date())
        switch dateRangeOption {
        case .oneDay:
            startDate = Calendar.current
                .theStartOfDay(of: Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        case .threeDay:
            startDate = Calendar.current
                .theStartOfDay(of: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)
        case .oneWeek:
            startDate = Calendar.current
                .theStartOfDay(of: Calendar.current.date(byAdding: .day, value: -7, to: Date())!)
        case .oneMonth:
            startDate = Calendar.current
                .theStartOfDay(of: Calendar.current.date(byAdding: .day, value: -30, to: Date())!)
        case .oneYear:
            startDate = Calendar.current
                .theStartOfDay(of: Calendar.current.date(byAdding: .day, value: -365, to: Date())!)
        case .customize:
            startDate = Calendar.current.theStartOfDay(of: self.startDate)
            endDate = Calendar.current.theEndOfDay(of: self.endDate)
        }
        return [startDate, endDate].min()! ... [endDate, startDate].max()!
    }

    var body: some View {
        Section {
            Picker("Date Range", selection: $dateRangeOption.animation()) {
                ForEach(DateRangeOption.allCases, id: \.rawValue) { option in
                    Text(option.description).tag(option)
                }
            }
            if dateRangeOption == .customize {
                DatePicker(
                    "Start Date",
                    selection: $startDate,
                    in: .distantPast ... endDate,
                    displayedComponents: [.date]
                )
                DatePicker("End Date", selection: $endDate, in: .distantPast ... Date(), displayedComponents: [.date])
            }
        } footer: {
            Text(formatter.string(from: dateRange.lowerBound, to: dateRange.upperBound))
        }
        Section {
            AssetLiabilityChangeChart(range: dateRange)
        }
        Section {
            IncomeStatementChart(kind: .expense, range: dateRange)
        } header: {
            Text("Expense Detail")
        }
        Section {
            IncomeStatementChart(kind: .revenue, range: dateRange)
        } header: {
            Text("Revenue Detail")
        }
    }
}

// MARK: - IncomeStatementChart

@available(iOS 16.0, *)
private struct IncomeStatementChart: View {
    @EnvironmentObject
    var viewModel: ViewModel

    let kind: Account.AccountKind
    let range: ClosedRange<Date>

    var accounts: [Account] {
        viewModel.accounts.filter { $0.kind == kind }.filter { value(of: $0) != 0 }
            .sorted(by: { value(of: $0) > value(of: $1) })
    }

    var body: some View {
        if !accounts.isEmpty {
            Chart(accounts) { account in
                BarMark(
                    x: .value("Current Value", account.amountIn(range, in: viewModel)),
                    y: .value("Name", account.name)
                )
                .annotation(position: .trailing) {
                    Text(String(format: "%.2f", value(of: account)))
                        .font(.footnote)
                }
                .foregroundStyle(by: .value("Kind", account.name))
            }
            .chartLegend(.hidden)
            .frame(height: CGFloat(accounts.count) * 70)
        } else {
            Text("No \(kind.rawValue) within this date range.")
                .foregroundColor(.secondary)
        }
    }

    func value(of account: Account) -> Double {
        abs(account.amountIn(range, in: viewModel))
    }
}

// MARK: - AssetLiabilityChangeChart

@available(iOS 16.0, *)
private struct AssetLiabilityChangeChart: View {
    typealias Value = (date: Date, value: Double, kind: Account.AccountKind)

    @EnvironmentObject
    var viewModel: ViewModel

    let range: ClosedRange<Date>

    @State
    var values: [Value]?

    var body: some View {
        Group {
            if let values = values {
                Chart(values, id: \.date) { value in
                    LineMark(
                        x: .value("Date", value.date),
                        y: .value("Value", value.value)
                    )
                    .foregroundStyle(by: .value("Kind", "Total " + value.kind.rawValue.capitalized))
                }
                .chartForegroundStyleScale(range: [.green, .red])
                .chartXScale(domain: range)
                .padding(.vertical)
            } else {
                Label {
                    Text("Calculating, please wait...")
                        .foregroundColor(.secondary)
                } icon: {
                    ProgressView()
                }
            }
        }
        .onAppear {
            updateValues()
        }
        .onChange(of: range) { _ in
            viewModel.objectWillChange.send()
        }
        .onReceive(viewModel.objectWillChange) { _ in
            values = nil
            updateValues()
        }
    }

    var calculateValues: [Value] {
        var result: [(Date, Double, Account.AccountKind)] = []
        result.append(contentsOf: dates.map { date in
            (date, value(kind: .asset, at: date), Account.AccountKind.asset)
        })
        result.append(contentsOf: dates.map { date in
            (date, -value(kind: .liability, at: date), Account.AccountKind.liability)
        })
        return result
    }

    var dates: [Date] {
        let calendar = Calendar.current

        let lowerBound = range.lowerBound
        let upperBound = range.upperBound

        var dates: [Date] = []
        var date = lowerBound

        let hour = calendar.dateComponents([.hour], from: lowerBound, to: upperBound).hour!

        let byHour = (hour <= 24 * 8)

        while true {
            if date <= upperBound {
                if byHour {
                    dates.append(date)
                } else {
                    dates.append(calendar.theStartOfDay(of: date))
                }
                date = calendar.date(byAdding: byHour ? .hour : .day, value: 1, to: date)!
            } else {
                break
            }
        }
        return dates
    }

    func updateValues() {
        DispatchQueue.global(qos: .userInteractive).async {
            let values = calculateValues
            DispatchQueue.main.async {
                withAnimation {
                    self.values = values
                }
            }
        }
    }

    func value(kind: Account.AccountKind, at date: Date) -> Double {
        viewModel.accounts
            .filter { $0.kind == kind }
            .map { $0.amountBefore(date, in: viewModel) }
            .reduce(0, +)
    }
}

// MARK: - HelpSheet

@available(iOS 16.0, *)
private struct HelpSheet: View {
    @Binding
    var isSheetShow: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("What is Income Statement?").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        """
                        Income Statement is a financial report that shows how much **revenue** you have earned and how much **expenses** you have incurred over a specific period of time.

                        You can use it to track your expenses and income over a specific period of time. Additionally, we provide trend charts for your total assets and liabilities.
                        """
                    )
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem {
                    Button("Finished") {
                        isSheetShow.toggle()
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - IncomeStatementHelpSheet_Preview

@available(iOS 16.0, *)
struct IncomeStatementHelpSheet_Preview: PreviewProvider {
    static var previews: some View {
        HelpSheet(isSheetShow: .init(get: { true }, set: { _ in }))
    }
}
