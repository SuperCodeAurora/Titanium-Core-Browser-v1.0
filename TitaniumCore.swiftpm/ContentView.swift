import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var themeManager: ThemeManager 
    
    @State private var addressText = ""
    @State private var showingImagePicker = false

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 0. 🎨 THE CUSTOM BACKGROUND LAYER
            if let bgImage = themeManager.backgroundImage {
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.black]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            // 1. 🚀 THE MAMMOTH MEMORY POOL (Instant Tab Switching)
            ZStack {
                ForEach($tabManager.tabs) { $tab in
                    TitaniumWebView(url: $tab.url)
                        .ignoresSafeArea()
                        // Keep alive in memory, but hide if not active
                        .opacity(tabManager.activeTabId == tab.id ? 1.0 : 0.0)
                        // Disable interactions on hidden tabs so you don't click invisible buttons
                        .allowsHitTesting(tabManager.activeTabId == tab.id) 
                }
            }

            // 2. THE COMMAND CENTER
            VStack(spacing: 12) {
                
                // --- THE TAB BAR ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(tabManager.tabs) { tab in
                            HStack {
                                // The Tab Name Button
                                Button(action: { tabManager.activeTabId = tab.id }) {
                                    Text(tab.url.host ?? "New Tab")
                                        .font(.system(size: 14, weight: .bold))
                                        .lineLimit(1)
                                        .frame(maxWidth: 120) // Prevents long URLs from breaking the UI
                                }
                                
                                // 🚨 THE CLOSE BUTTON 🚨
                                // Only show the 'X' if there is more than 1 tab open
                                if tabManager.tabs.count > 1 {
                                    Button(action: { 
                                        withAnimation {
                                            tabManager.closeTab(id: tab.id) 
                                        }
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                }
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            // Highlight the active tab in Titanium Blue
                            .background(tabManager.activeTabId == tab.id ? Color.blue : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // --- THE ADDRESS BAR ---
                HStack {
                    // Theme Toggle
                    Button(action: { themeManager.toggleTheme() }) {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.blue)
                    }
                    
                    // URL Input
                    TextField("Titanium Search", text: $addressText)
                        .onSubmit { loadPage() }
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    
                    // Background Image Uploader
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    // New Tab Button
                    Button(action: { tabManager.createNewTab(url: "https://www.apple.com") }) {
                        Image(systemName: "plus.app.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
            .padding(.top, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(24)
            .padding()
        }
        .onChange(of: tabManager.activeTabId) { _ in
            addressText = tabManager.activeURL?.absoluteString ?? ""
        }
        .onAppear {
            addressText = tabManager.activeURL?.absoluteString ?? ""
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $themeManager.backgroundImage)
        }
    }

    func loadPage() {
        var target = addressText.lowercased()
        if !target.hasPrefix("http") { target = "https://" + target }
        tabManager.createNewTab(url: target)
    }
}
