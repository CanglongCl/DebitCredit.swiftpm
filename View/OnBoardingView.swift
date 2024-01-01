//
//  SwiftUIView.swift
//
//
//  Created by 戴藏龙 on 2023/4/17.
//

import SwiftUI

// MARK: - OnBoardingView

@available(iOS 16.0, *)
struct OnBoardingView: View {
    @Binding
    var isShown: Bool
    @State
    var tag: Int = 0

    var body: some View {
        TabView(selection: $tag) {
            FirstPage(tag: $tag)
                .tag(0)
            SecondPage(tag: $tag)
                .tag(1)
            ThirdPage(tag: $tag)
                .tag(2)
            FourthPage(tag: $tag)
                .tag(3)
            FinalPage(isShown: $isShown)
                .tag(4)
        }
        .tabViewStyle(.page)
    }
}

// MARK: - OnBoardingView_Previews

@available(iOS 16.0, *)
struct OnBoardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoardingView(isShown: .init(get: { true }, set: { _ in }))
    }
}

// MARK: - FirstPage

@available(iOS 16.0, *)
private struct FirstPage: View {
    @Binding
    var tag: Int

    var body: some View {
        OnBoardingPage(title: "About This App") {
            Text(
                """
                Welcome to **DebitCredit**!

                This app is a bookkeeping app based on the **Double-Entry Accounting** method, designed to help users learn and simplify this powerful financial tool so that everyone can use it to manage their finances without prior knowledge of accounting.

                DebitCredit is **easy to use**, even for those without any accounting knowledge. In addition, we also aims to **educate** users about this powerful financial management tool.
                """
            )
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
        } icon: {
            Image(systemName: "app.gift")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.orange)
        } button: {
            NextButton(tag: $tag)
                .padding(.vertical)
        }
    }
}

// MARK: - SecondPage

@available(iOS 16.0, *)
private struct SecondPage: View {
    @Binding
    var tag: Int

    var body: some View {
        OnBoardingPage(title: "Double-Entry Accounting") {
            Text("""
            Double-entry accounting is a method of bookkeeping that records every financial transaction in two different accounts, one as a **Debit** and the other as a **Credit**.

            Currently, the majority of apps available on the App Store use the single-entry accounting method. However, the double-entry system offers several advantages over it, providing increased accuracy and flexibility.

            Besides, the double-entry accounting method is widely used by companies and even countries. Learning this method can help you better understand their financial position and make better investment decisions.
            """)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
        } icon: {
            Image("calculator")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        } button: {
            NextButton(tag: $tag)
                .padding(.vertical)
        }
    }
}

// MARK: - ThirdPage

@available(iOS 16.0, *)
private struct ThirdPage: View {
    @Binding
    var tag: Int

    var body: some View {
        OnBoardingPage(title: "Accounts") {
            Text("""
            In double-entry accounting, the concept of "accounts" is crucial.

            "Account" refers to **ANY** specific category or type of **money** that **you are interested in tracking**.
            For example, you may want to track the money you paid for food, or the money in your student card.

            There 4 kinds of accounts:
            **Assets - Resources you owns.**
                E.g. cash, money in student card.
            **Liabilities - Debt you owes to others.**
                E.g. loans, mortgages, credit card debts.
            **Expenses - Your costs.**
                E.g. food, transportation.
            **Revenue - Income you earned.**
                E.g. salary, investment revenue.
            """)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
        } icon: {
            Image(systemName: "creditcard.and.123")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.teal)
        } button: {
            NextButton(tag: $tag)
                .padding(.vertical)
        }
    }
}

// MARK: - FourthPage

@available(iOS 16.0, *)
private struct FourthPage: View {
    @Binding
    var tag: Int

    var body: some View {
        OnBoardingPage(title: "Transactions") {
            VStack(alignment: .leading) {
                Text(
                    """
                    In double-entry accounting, a transaction refers to an exchange or transfer of value between **two accounts** - credited account and debited account.

                    While the concept of debits and credits may seem complex, DebitCredit simplifies this process by replacing it with easily recognizable icons and colors:
                    """
                )
                .multilineTextAlignment(.leading)
                Grid(alignment: .leading, horizontalSpacing: 10, verticalSpacing: 10) {
                    ForEach(tableItems) { item in
                        TableItemRow(item: item)
                    }
                }
                .padding(.vertical)
                Text("Note that ") + Text("**RED**")
                    .foregroundColor(.red) + Text(" means you have less money while ") + Text("**GREEN**")
                    .foregroundColor(.green) + Text(" means you have more money.")
            }
            .padding(.horizontal)
        } icon: {
            Image(systemName: "cart.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.purple)
        } button: {
            NextButton(tag: $tag)
                .padding(.vertical)
        }
    }
}

// MARK: - OnBoardingPage

struct OnBoardingPage<M: View, I: View, B: View>: View {
    let title: AttributedString
    @ViewBuilder
    let message: () -> M
    @ViewBuilder
    let icon: () -> I
    @ViewBuilder
    let button: () -> B

    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    Spacer()
                    icon()
                    Text(title)
                        .bold()
                        .font(.title)
                        .padding(.vertical)
                    message()
                }
                .padding()
            }
            Spacer()
            button()
                .padding(.bottom)
        }
    }
}

// MARK: - FinalPage

@available(iOS 16.0, *)
private struct FinalPage: View {
    @Binding
    var isShown: Bool

    var body: some View {
        OnBoardingPage(title: "Get Start") {
            Text("""
            To get started with DebitCredit, we recommend:

            First, create accounts in the **Account** page.
            Second, add transactions in the **Transaction** page.

            The **Balance** page provides a summary of the user's overall financial situation, while the **In-Out** page shows the user's income and expenses over time.

            If you experience any issues, please click \(
                Image(systemName: "questionmark.circle")
            ) on the top-right corner of each page for assistance.

            In this demo, I've included some sample accounts and transactions for you to investigate.
            """)
            .multilineTextAlignment(.leading)
            .padding(.horizontal)
        } icon: {
            Image(systemName: "figure.run")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .foregroundColor(.cyan)
        } button: {
            CloseButton(isShown: $isShown)
                .padding(.vertical)
        }
    }
}

// MARK: - BottomButton

@available(iOS 16.0, *)
private struct BottomButton: View {
    let title: String
    let action: () -> ()

    var body: some View {
        Button(title) {
            withAnimation {
                action()
            }
        }
        .foregroundColor(.blue)
        .buttonStyle(.bordered)
        .buttonBorderShape(.roundedRectangle)
    }
}

// MARK: - NextButton

@available(iOS 16.0, *)
private struct NextButton: View {
    @Binding
    var tag: Int

    var body: some View {
        BottomButton(title: "Next") {
            tag += 1
        }
    }
}

// MARK: - CloseButton

@available(iOS 16.0, *)
private struct CloseButton: View {
    @Binding
    var isShown: Bool

    var body: some View {
        BottomButton(title: "Start") {
            isShown.toggle()
        }
    }
}

// MARK: - TableItem

struct TableItem: Identifiable {
    let id: Int
    let icon: String
    let color: Color
    let description: String
}

// MARK: - TableItemRow

@available(iOS 16.0, *)
struct TableItemRow: View {
    let item: TableItem

    var body: some View {
        let frame: CGFloat = 20
        GridRow(alignment: .top) {
            Image(systemName: item.icon)
                .resizable()
                .scaledToFit()
                .foregroundColor(item.color)
                .frame(width: frame, height: frame)
            Text(item.description)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

let tableItems: [TableItem] = [
    .init(id: 0, icon: "plus.circle", color: .green, description: "Increase in money"),
    .init(id: 1, icon: "minus.circle", color: .red, description: "Decrease in money"),
    .init(id: 3, icon: "plus.circle", color: .red, description: "Increase in debt"),
    .init(id: 2, icon: "minus.circle", color: .green, description: "Decrease in debt"),
    .init(id: 4, icon: "arrow.up.circle", color: .red, description: "Money out (spending or giving money away)"),
    .init(id: 5, icon: "arrow.down.circle", color: .green, description: "Money in (income or receiving money)"),
]
