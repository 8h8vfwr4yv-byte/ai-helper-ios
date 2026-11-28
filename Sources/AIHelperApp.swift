import SwiftUI

@main
struct AIHelperApp: App {
    @StateObject private var store = HistoryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
