import SwiftUI

@main
struct AlejaApp: App {
    @StateObject private var cardStore = CardStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(cardStore)
                .preferredColorScheme(.light)
        }
    }
}
