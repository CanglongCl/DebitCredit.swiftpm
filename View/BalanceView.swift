//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import Charts
import SwiftUI

// MARK: - BalanceView

@available(iOS 16.0, *)
struct BalanceView: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    var body: some View {
        NavigationView {
            List {
                BalanceChartSection()
            }
            .navigationTitle("Balance Sheet")
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
        }
    }

    // MARK: Private

    @State
    private var isHelpSheetShow: Bool = false
}

// MARK: - BalanceView_Previews

@available(iOS 16.0, *)
struct BalanceView_Previews: PreviewProvider {
    static var previews: some View {
        BalanceView()
            .environmentObject(ViewModel.shared)
    }
}

// MARK: - BalanceChartSection

@available(iOS 16.0, *)
private struct BalanceChartSection: View {
    @EnvironmentObject
    var viewModel: ViewModel
    @State
    var _endDate: Date = .init()

    var endDate: Date {
        Calendar.current.theEndOfDay(of: _endDate)
    }

    var body: some View {
        Section {
            DatePicker(
                "Closing Date",
                selection: $_endDate.animation(),
                in: viewModel.availableDateRange(),
                displayedComponents: [.date]
            )
        }
        Section {
            if !viewModel.accounts.isEmpty {
                BalanceChart(date: endDate)
            } else {
                Text("Add your account first. ")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - BalanceChart

@available(iOS 16.0, *)
private struct BalanceChart: View {
    @EnvironmentObject
    var viewModel: ViewModel
    let date: Date

    var balanceAccounts: [Account] {
        viewModel.accounts.filter { account in
            [.asset, .liability, .equity].contains(account.kind)
        }
    }

    var body: some View {
        Chart(balanceAccounts) { account in
            let isAsset = (account.kind == .asset)
            BarMark(
                x: .value("Current Value", unsignedValue(of: account)),
                y: .value("Name", account.name)
            )
            .foregroundStyle(by: .value("Kind", account.kind.rawValue.capitalized))
            .annotation(position: isAsset ? .leading : .trailing) {
                Text(String(format: "%.2f", unsignedValue(of: account)))
                    .font(.footnote)
                    .foregroundColor(isAsset ? .green : .red)
                    .fixedSize()
            }
        }
        .chartYAxis {
            AxisMarks(preset: .inset, position: .trailing) { value in
                AxisValueLabel {
                    Text(value.as(String.self)!)
                }
            }
            AxisMarks(preset: .inset, position: .leading) { value in
                AxisValueLabel {
                    Text(value.as(String.self)!)
                }
            }
        }
        .chartForegroundStyleScale(.init(dictionaryLiteral: ("Asset", Color.green), ("Liability", Color.red)))
        .chartXScale(domain: valueRange)
        .frame(height: CGFloat(balanceAccounts.count) * 70)
    }

    var valueRange: ClosedRange<Double> {
        let max = balanceAccounts.map { $0.amountBefore(date, in: viewModel) }.max() ?? 0
        return -max ... max
    }

    func unsignedValue(of account: Account) -> Double {
        let value = signedValue(of: account)
        let mark = (account.kind == .asset) ? +1.0 : -1.0
        return value * mark
    }

    func signedValue(of account: Account) -> Double {
        account.amountBefore(date, in: viewModel)
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
                    Text("What is Balance Sheet?").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        """
                        A balance sheet is a financial statement that contains details of your **asset accounts** or **liabilities accounts** at a specific point in time (closing date).

                        It provides a snapshot of the your financial situation and helps you understand their net worth.
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

// MARK: - BalanceHelpSheet_Preview

@available(iOS 16.0, *)
struct BalanceHelpSheet_Preview: PreviewProvider {
    static var previews: some View {
        HelpSheet(isSheetShow: .init(get: { true }, set: { _ in }))
    }
}
