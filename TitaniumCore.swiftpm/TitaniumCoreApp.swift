import SwiftUI

@main
struct TitaniumCoreApp: App {
    // 🧠 IGNITION: We boot up the Titanium Brain here
    @StateObject private var tabManager = TabManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // 🔌 INJECTION: This plugs the Brain into the entire app
                .environmentObject(tabManager) 
                .preferredColorScheme(.dark)
        }
    }
}
