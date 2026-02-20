import SwiftUI
import SwiftData

@main
struct TitaniumCoreApp: App {
    @StateObject private var tabManager = TabManager()
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(tabManager)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
        // 💾 THE DATABASE IGNITION
        // This physically boots up the SQLite database and attaches it to the app.
        .modelContainer(for: HistoryItem.self)
    }
}
