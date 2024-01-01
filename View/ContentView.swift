import SwiftUI

// MARK: - ContentView

@available(iOS 16.0, *)
struct ContentView: View {
    @EnvironmentObject
    var viewModel: ViewModel

    @State
    var tab: Int = 0

    @State
    var isOnBoardingViewShow: Bool = false

    var body: some View {
        TabView(selection: $tab) {
            AccountView()
                .tag(0)
                .tabItem {
                    Label("Account", systemImage: "creditcard")
                }
            RecordView()
                .tag(1)
                .tabItem {
                    Label("Transaction", systemImage: "dollarsign")
                }
            BalanceView()
                .tag(2)
                .tabItem {
                    Label("Balance", systemImage: "chart.bar")
                }
            IncomeStatementView()
                .tag(3)
                .tabItem {
                    Label("In-Out", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .fullScreenCover(isPresented: $isOnBoardingViewShow) {
            OnBoardingView(isShown: $isOnBoardingViewShow)
        }
        .navigationViewStyle(.stack)
        .onAppear {
            if !onBoardingViewHasShown {
                isOnBoardingViewShow.toggle()
                onBoardingViewHasShown = true
            }
        }
    }
}

private var onBoardingViewHasShown: Bool {
    get {
        UserDefaults.standard.bool(forKey: UserDefaultKeys.onBoardingViewHasShown)
    }
    set {
        UserDefaults.standard.set(newValue, forKey: UserDefaultKeys.onBoardingViewHasShown)
    }
}
