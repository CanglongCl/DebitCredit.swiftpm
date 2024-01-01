//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/13.
//

import SwiftUI

// MARK: - AccountView

struct AccountView: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel

    var body: some View {
        NavigationView {
            List {
//                #if DEBUG
//                Button("Using Demo Records and Accounts") {
//                    viewModel.replacingUsingDemoData()
//                }
//                Button("Delete All") {
//                    viewModel.deleteAll()
//                }
//                #endif
                ForEach(Account.AccountKind.allCases, id: \.rawValue) { kind in
                    let accounts = viewModel.accounts.filter { account in
                        account.kind == kind
                    }
                    if !accounts.isEmpty {
                        Section {
                            ForEach(accounts) { account in
                                EachAccountView(account: account)
                                    .swipeActions {
                                        Button("Delete", role: .destructive) {
                                            toBeDeleteAccount = account
                                        }
                                    }
                            }
                        } header: {
                            Text(kind.rawValue)
                        }
                    }
                }
            }
            .alert("Are you sure you want to delete?", isPresented: isDeleteAccountAlertShow) {
                Button("Delete", role: .destructive) {
                    withAnimation {
                        if let toBeDeleteAccount {
                            viewModel.delete(toBeDeleteAccount)
                            self.toBeDeleteAccount = nil
                        }
                    }
                }
            } message: {
                if let toBeDeleteAccount {
                    Text(
                        "There are \(toBeDeleteAccount.recordCount(in: viewModel)) related records which will also be deleted."
                    )
                }
            }
            .navigationTitle("Accounts")
            .sheet(isPresented: $isAddAccountSheetShow) {
                AddAccountSheet(isSheetShow: $isAddAccountSheetShow)
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
                        isAddAccountSheetShow.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
    }

    // MARK: Private

    @State
    private var isAddAccountSheetShow: Bool = false
    @State
    private var isHelpSheetShow: Bool = false

    @State
    private var toBeDeleteAccount: Account?

    private var isDeleteAccountAlertShow: Binding<Bool> {
        .init {
            toBeDeleteAccount != nil
        } set: { _ in
            toBeDeleteAccount = nil
        }
    }
}

// MARK: - AccountView_Previews

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
            .environmentObject(ViewModel.shared)
    }
}

// MARK: - EachAccountView

struct EachAccountView: View {
    @EnvironmentObject
    var viewModel: ViewModel
    let account: Account

    var currentAmount: Double {
        account.currentAmount(in: viewModel)
    }

    var body: some View {
        HStack {
            Text(account.name)
            Spacer()
            Text(doubleFormatter.string(for: currentAmount)!)
                .foregroundColor(account.kind.color(amountMoreThanZero: currentAmount >= 0))
        }
    }

    var color: Color {
        guard currentAmount != 0 else { return .secondary }
        switch account.kind.type {
        case .credit:
            if currentAmount > 0 {
                return .green
            } else {
                return .red
            }
        case .debit:
            if currentAmount < 0 {
                return .green
            } else {
                return .red
            }
        }
    }
}

// MARK: - AddAccountSheet

struct AddAccountSheet: View {
    // MARK: Internal

    @EnvironmentObject
    var viewModel: ViewModel
    @Binding
    var isSheetShow: Bool

    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("Account Name")
                        Spacer()
                        TextField("Account Name", text: $name, prompt: Text("Credit Card, Salary, etc"))
                            .multilineTextAlignment(.trailing)
                    }
                    Picker("Kind of Account", selection: $kind) {
                        if kind == nil {
                            Text("Not selected")
                                .tag(Account.AccountKind?(nil))
                        }
                        ForEach(Account.AccountKind.allCases, id: \.rawValue) { kind in
                            Text(kind.rawValue.capitalized).tag(Account.AccountKind?(kind))
                        }
                    }
                }
                if kind == .asset || kind == .liability || kind == .equity {
                    Section {
                        HStack {
                            Text("Initial Amount")
                            Spacer()
                            TextField("Init Value", value: $initialValue, format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                }
            }
            .navigationTitle("New Account")
            .navigationBarTitleDisplayMode(.inline)
            .defaultAlert(title: "Require Account Name", isPresented: $isRequireNameAlertShow)
            .defaultAlert(title: "Require Account Kind", isPresented: $isRequireTypeAlertShow)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        guard name != "" else { isRequireNameAlertShow.toggle(); return }
                        guard let kind else { isRequireTypeAlertShow.toggle(); return }
                        viewModel.add(.init(name: name, kind: kind, initialValue: initialValue))
                        isSheetShow.toggle()
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isSheetShow.toggle()
                    }
                }
            }
        }
    }

    // MARK: Private

    @State
    private var name: String = ""
    @State
    private var kind: Account.AccountKind?
    @State
    private var initialValue: Double = 0

    @State
    private var isRequireNameAlertShow: Bool = false
    @State
    private var isRequireTypeAlertShow: Bool = false
    @State
    private var isAddSucceededAlertShow: Bool = false
}

// MARK: - HelpSheet

private struct HelpSheet: View {
    @Binding
    var isSheetShow: Bool

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("What is Account?").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        """
                        In double-entry accounting, the concept of "accounts" is crucial.

                        "Account" refers to **ANY** specific category or type of **money** that **you are interested in tracking**.

                        For example, you may want to track the money you paid for food, or the money in your student card.
                        """
                    )
                    Divider()
                    Text("Kind of Accounts").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        """
                        There 4 kinds of accounts:

                        **Assets - Resources you owns.**
                            E.g. cash, money in student card.

                        **Liabilities - Debt you owes to others.**
                            E.g. loans, mortgages, credit card debts.

                        **Expenses - Your costs.**
                            E.g. food, transportation.

                        **Revenue - Income you earned.**
                            E.g. salary, investment revenue.
                        """
                    )
                    Divider()
                    Text("Maintain Flexibly").font(.title).bold().multilineTextAlignment(.leading)
                    Text(
                        """
                        Only create accounts for the part of your money you want to track.

                        For example, for food expenses:

                        - Some people may want to record their spending daily, and should create a unified **"Food"** account.

                        - Some people may want to focus on how much they spend on each meal, and should create separate **"Breakfast"**, **"Lunch"**, and **"Dinner"** accounts.

                        - Others may also want to track spending on different types of food, and can create accounts like **"Meat"** and **"Vegetables"**.
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
