import SwiftUI

struct ContentView: View {
    // 🔌 RECEIVER: The UI now listens directly to the Brain
    @EnvironmentObject var tabManager: TabManager
    @State private var addressText = ""

    var body: some View {
        ZStack(alignment: .bottom) { // Moved UI to the bottom for iPad ergonomics
            
            // 1. The Engine Layer (Now powered by the TabManager)
            if let activeURL = tabManager.activeURL {
                TitaniumWebView(url: .constant(activeURL))
                    .ignoresSafeArea()
            } else {
                Color.black.ignoresSafeArea() // Empty state if all tabs are closed
            }

            // 2. The Glassmorphic Command Center
            VStack(spacing: 12) {
                
                // --- THE TAB BAR ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tabManager.tabs) { tab in
                            Button(action: { 
                                // Haptic-fast tab switching
                                tabManager.activeTabId = tab.id 
                            }) {
                                Text(tab.url.host ?? "New Tab")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    // Highlight the active tab in Titanium Blue
                                    .background(tabManager.activeTabId == tab.id ? Color.blue : Color.gray.opacity(0.3))
                                    .foregroundColor(.white)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // --- THE ADDRESS BAR ---
                HStack {
                    Image(systemName: "shield.fill")
                        .foregroundColor(.blue)
                    
                    TextField("Titanium Search", text: $addressText)
                        .onSubmit { loadPage() }
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    
                    // The "New Tab" Button
                    Button(action: { 
                        tabManager.createNewTab(url: "https://www.github.com") 
                    }) {
                        Image(systemName: "plus.app.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .background(.ultraThinMaterial) // High-end Apple frosted glass
            .cornerRadius(24)
            .padding()
        }
        // Auto-update the text bar when you switch tabs
        .onChange(of: tabManager.activeTabId) { _ in
            addressText = tabManager.activeURL?.absoluteString ?? ""
        }
        .onAppear {
            addressText = tabManager.activeURL?.absoluteString ?? ""
        }
    }

    // Navigates the current tab, or spawns a new one
    func loadPage() {
        var target = addressText.lowercased()
        if !target.hasPrefix("http") {
            target = "https://" + target
        }
        // Spawn a new tab with the requested URL
        tabManager.createNewTab(url: target)
    }
}
