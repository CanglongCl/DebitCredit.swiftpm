import SwiftUI

@main
struct MyApp: App {
    let viewModel: ViewModel = .shared

    var body: some Scene {
        WindowGroup {
            if #available(iOS 16, *) {
                ContentView()
                    .environmentObject(viewModel)
            } else {
                EmptyView()
            }
        }
    }
}
