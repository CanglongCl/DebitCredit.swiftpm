//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import SwiftUI

// MARK: - RecordView

@available(iOS 16.0, *)
struct RecordView: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    var records: [Record] { viewModel.records }

    var dateFormatter: DateFormatter {
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM yyyy"
        return fmt
    }

    var groupedRecords: [(Date, [Record])] {
        Dictionary(grouping: records, by: { record in
            let components = Calendar.current.dateComponents([.year, .month], from: record.date)
            return Calendar.current.date(from: .init(year: components.year!, month: components.month!))!
        }).map { ($0, $1) }.sorted(by: { $0.0 > $1.0 })
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(groupedRecords, id: \.1.first!.id) { date, records in
                    Section {
                        ForEach(records.sorted(by: { $0.date > $1.date })) { record in
                            EachRecordView(record: record)
                        }
                        .onDelete { indexSet in
                            indexSet.forEach { index in
                                viewModel.delete(records[index])
                            }
                        }
                    } header: {
                        Text(dateFormatter.string(from: date))
                    }
                }
            }
            .navigationTitle("Transactions")
            .sheet(isPresented: $isAddRecordSheetShow) {
                AddRecordSheet(isSheetShow: $isAddRecordSheetShow)
            }
            .sheet(isPresented: $isHelpSheetShow, content: {
                HelpSheet(isSheetShow: $isHelpSheetShow)
            })
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        isHelpSheetShow.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                    Button {
                        isAddRecordSheetShow.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: Private

    @State
    private var isAddRecordSheetShow: Bool = false
    @State
    private var isHelpSheetShow: Bool = false
}

// MARK: - EachRecordView

@available(iOS 16.0, *)
private struct EachRecordView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    let record: Record

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(record.name)
                        .font(.title2)
                        .bold()
                    Text("$\(doubleFormatter.string(for: record.amount)!)")
                        .font(.system(.title3, design: .monospaced))
                }
                Spacer()
                let imageFrame: CGFloat = 30
                record.tag.image()
                    .resizable().scaledToFit()
                    .foregroundColor(record.tag.color())
                    .frame(width: imageFrame, height: imageFrame)
            }
            CreditDebitAccount(
                creditAccount: record.creditAccount(in: viewModel),
                debitAccount: record.debitAccount(in: viewModel)
            )
        }
    }
}

// MARK: - CreditDebitAccount

private struct CreditDebitAccount: View {
    let creditAccount: Account
    let debitAccount: Account

    var body: some View {
        if #available(iOS 16.0, *) {
            Grid(alignment: .leading) {
                GridRow {
                    debitAccount.kind
                        .inoutIcon(creditOrDebit: .debit)
                    Text(debitAccount.kind.rawValue.capitalized)
                    Text(" - ")
                    Text(debitAccount.name)
                }
                .frame(height: 20)
                GridRow {
                    creditAccount.kind
                        .inoutIcon(creditOrDebit: .credit)
                    Text(creditAccount.kind.rawValue.capitalized)
                    Text(" - ")
                    Text(creditAccount.name)
                }
                .frame(height: 20)
            }
        } else {
            VStack {
                HStack {
                    Text("Debit")
                    Text("\(debitAccount.kind.rawValue.capitalized) - \(debitAccount.name)")
                }
                HStack {
                    Text("Credit")
                    Text("\(creditAccount.kind.rawValue.capitalized) - \(creditAccount.name)")
                }
            }
        }
    }
}

// MARK: - AddRecordSheet

@available(iOS 16.0, *)
private struct AddRecordSheet: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    @Binding
    var isSheetShow: Bool

    @Namespace
    var animation

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Launch, Receive Salary, etc", text: $name)
                } header: {
                    Text("Title")
                }
                Section {
                    AccountPicker(title: "Debit", account: $debitAccount, type: .debit)
                    AccountPicker(title: "Credit", account: $creditAccount, type: .credit)
                } header: {
                    Text("Account")
                }
                .navigationLinkPickerStyle()
                Section {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("Amount", value: $amount, format: .number)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                } header: {
                    Text("Amount")
                }

                Section {
                    DatePicker("Date", selection: $date)
                } header: {
                    Text("Transaction Date")
                }
                Section {
                    if !isIconBarExpand {
                        ScrollView(.horizontal) {
                            HStack(spacing: 20) {
                                ForEach(Tag.allCases) { tag in
                                    TagView(tag: tag, selectedTag: self.$tag, animation: animation)
                                }
                            }
                            .padding(.vertical, 5)
                        }
                    } else {
                        LazyVGrid(columns: [.init(.adaptive(minimum: 50))], spacing: 20) {
                            ForEach(Tag.allCases) { tag in
                                TagView(tag: tag, selectedTag: self.$tag, animation: animation)
                            }
                        }
                        .padding(.vertical)
                    }
                } header: {
                    HStack {
                        Text("Icon")
                        Spacer()
                        Button(isIconBarExpand ? "Hide" : "More") {
                            withAnimation {
                                isIconBarExpand.toggle()
                            }
                        }
                        .font(.footnote)
                    }
                }
            }
            .navigationTitle("New Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .defaultAlert(title: "Fields Missing", isPresented: $isNotFinishedAlertShow, message: missingFieldMessage)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard name != "",
                              let amount,
                              let creditAccount,
                              let debitAccount,
                              let tag
                        else {
                            isNotFinishedAlertShow.toggle()
                            return
                        }
                        let record = Record(
                            name: name,
                            amount: amount,
                            creditAccount: creditAccount,
                            debitAccount: debitAccount,
                            date: date,
                            tag: tag
                        )
                        viewModel.add(record)
                        isSheetShow.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isSheetShow.toggle()
                    }
                }
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
        }
    }

    // MARK: Private

    private struct TagView: View {
        let tag: Tag
        @Binding
        var selectedTag: Tag?

        let animation: Namespace.ID

        var isSelected: Bool { selectedTag == tag }
        var body: some View {
            let frame: CGFloat = 30
            VStack {
                tag.image().resizable().scaledToFit()
                    .matchedGeometryEffect(id: tag.id, in: animation)
            }
            .frame(width: frame, height: frame)
            .foregroundColor(tag == selectedTag ? tag.color() : .primary)
            .onTapGesture {
                withAnimation(.interactiveSpring()) {
                    selectedTag = tag
                }
            }
        }
    }

    @State
    private var name: String = ""

    @State
    private var creditAccount: Account?
    @State
    private var debitAccount: Account?

    @State
    private var amount: Double?

    @State
    private var date: Date = .init()
    @State
    private var tag: Tag?

    @State
    private var isNotFinishedAlertShow: Bool = false

    @State
    private var isIconBarExpand: Bool = false

    @State
    private var isHelpSheetShow: Bool = false

    private var notFinishedAllField: Bool {
        (name == "") || (creditAccount == nil) || (debitAccount == nil) || (amount == 0) || (tag == nil)
    }

    private var missingFieldMessage: String {
        "Please complete all required fields before submitting the form. The following fields are still missing: \n\(name == "" ? "\nName" : "")\(creditAccount == nil ? "\nCredit Account" : "")\(debitAccount == nil ? "\nDebit Account" : "")\(((amount == 0) || (amount == nil)) ? "\nAmount" : "")\(tag == nil ? "\nIcon" : "")"
    }
}

// MARK: - AccountPicker

@available(iOS 16.0, *)
private struct AccountPicker: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel
    let title: String

    @Binding
    var account: Account?

    let type: Account.AccountKind.`Type`

    var body: some View {
        NavigationLink {
            MenuPicker(title: title, type: type, account: $account)
        } label: {
            HStack {
                Text(title)
                Spacer()
                if let account {
                    AccountLabel(account: account, type: type)
                } else {
                    Text("Not selected").foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: Private

    private struct MenuPicker: View {
        // MARK: Internal

        @Environment(\.presentationMode)
        var presentationMode
        @EnvironmentObject
        var viewModel: ViewModel

        let title: String

        let type: Account.AccountKind.`Type`

        @Binding
        var account: Account?

        var body: some View {
            List {
                Button("New Account") {
                    isAddAccountSheetShow.toggle()
                }
                ForEach(Account.AccountKind.allCases, id: \.rawValue) { kind in
                    let accounts = viewModel.accounts.filter { account in
                        account.kind == kind
                    }
                    if !accounts.isEmpty {
                        Section {
                            ForEach(accounts) { account in
                                PickerButton(account: account, type: type) { account in
                                    self.account = account
                                    presentationMode.wrappedValue.dismiss()
                                }
                            }
                        } header: {
                            Text(kind.rawValue)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isAddAccountSheetShow) {
                AddAccountSheet(isSheetShow: $isAddAccountSheetShow)
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
        }

        // MARK: Private

        @State
        private var isAddAccountSheetShow: Bool = false
        @State
        private var isHelpSheetShow: Bool = false
    }

    private struct PickerButton: View {
        let account: Account
        let type: Account.AccountKind.`Type`

        let completion: (Account) -> ()

        var body: some View {
            Button {
                completion(account)
            } label: {
                AccountLabel(account: account, type: type)
            }
            .foregroundColor(.primary)
        }
    }
}

// MARK: - AccountLabel

private struct AccountLabel: View {
    let account: Account
    let type: Account.AccountKind.`Type`

    var body: some View {
        Label {
            Text("\(account.kind.rawValue.capitalized) - \(account.name)")
        } icon: {
            switch type {
            case .debit:
                account.kind.inoutIcon(creditOrDebit: .debit)
            case .credit:
                account.kind.inoutIcon(creditOrDebit: .credit)
            }
        }
    }
}

// MARK: - RecordView_Preview

@available(iOS 16.0, *)
struct RecordView_Preview: PreviewProvider {
    static var previews: some View {
        RecordView()
            .environmentObject(ViewModel.shared)
    }
}

// MARK: - AddRecordSheet_Preview

@available(iOS 16.0, *)
struct AddRecordSheet_Preview: PreviewProvider {
    static var previews: some View {
        AddRecordSheet(isSheetShow: .init(get: { true }, set: { _ in }))
            .environmentObject(ViewModel.shared)
    }

    @State
    var isSheetShow: Bool = false
}

// MARK: - HelpSheet_Preview

@available(iOS 16.0, *)
struct HelpSheet_Preview: PreviewProvider {
    static var previews: some View {
        HelpSheet(isSheetShow: .init(get: { true }, set: { _ in }))
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
                    Text("What is Transaction?").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        "In double-entry accounting, a transaction refers to an exchange or transfer of value between **two accounts** - credited account and debited account."
                    )
                    Divider()
                    Text("Choose Credited Account & Debited Account").font(.title).bold()
                        .multilineTextAlignment(.leading)
                    Text(
                        "While the concept of debits and credits may seem complex, DebitCredit simplifies this process by replacing it with easily recognizable icons and colors:"
                    )
                    Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                        ForEach(tableItems) { item in
                            TableItemRow(item: item)
                        }
                    }
                    Text("Note that ") + Text("**RED**")
                        .foregroundColor(.red) + Text(" means you have less money while ") + Text("**GREEN**")
                        .foregroundColor(.green) + Text(" means you have more money.")
                    Divider()
                    Text("Example").font(.title).bold().multilineTextAlignment(.leading)
                    Group {
                        VStack(alignment: .leading) {
                            Text("You buy groceries using your credit card:").bold().multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            RecordItemRow(icon: "arrow.up.circle", color: .red, accountName: "Expense - Groceries")
                            RecordItemRow(icon: "plus.circle", color: .red, accountName: "Liability - Credit card")
                        }
                        VStack(alignment: .leading) {
                            Text("You receive payment from a client for services rendered:").bold()
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            RecordItemRow(icon: "plus.circle", color: .green, accountName: "Asset - Cash")
                            RecordItemRow(icon: "arrow.down.circle", color: .green, accountName: "Revenue - Service")
                        }
                        VStack(alignment: .leading) {
                            Text("Transfer money from checking account to student card:").bold()
                                .multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            RecordItemRow(icon: "plus.circle", color: .green, accountName: "Asset - Student Card")
                            RecordItemRow(icon: "minus.circle", color: .red, accountName: "Asset - Checking")
                        }
                        VStack(alignment: .leading) {
                            Text("You purchase supplies with cash:").bold().multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            RecordItemRow(icon: "arrow.down.circle", color: .red, accountName: "Expense - Supplies")
                            RecordItemRow(icon: "minus.circle", color: .red, accountName: "Asset - Cash")
                        }
                        VStack(alignment: .leading) {
                            Text("You pay your monthly rent:").bold().multilineTextAlignment(.leading)
                                .fixedSize(horizontal: false, vertical: true)
                            RecordItemRow(icon: "arrow.up.circle", color: .red, accountName: "Expense - Rent")
                            RecordItemRow(icon: "minus.circle", color: .red, accountName: "Asset - Cash")
                        }
                    }
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

// MARK: - RecordItemRow

@available(iOS 16.0, *)
private struct RecordItemRow: View {
    let icon: String
    let color: Color
    let accountName: String

    var body: some View {
        let frame: CGFloat = 20
        HStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(color)
                .frame(width: frame, height: frame)
            Text(accountName)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
