import SwiftUI

struct ContentView: View {
    @EnvironmentObject var tabManager: TabManager
    @EnvironmentObject var themeManager: ThemeManager // 🆕 Listening to the Theme
    
    @State private var addressText = ""
    @State private var showingImagePicker = false

    var body: some View {
        ZStack(alignment: .bottom) {
            
            // 0. 🎨 THE CUSTOM BACKGROUND LAYER (New Tab Page)
            if let bgImage = themeManager.backgroundImage {
                Image(uiImage: bgImage)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                // Default Titanium gradient if no image is uploaded
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.black]), startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()
            }

            // 1. THE ENGINE LAYER (Only shows if there is an active website)
            if let activeURL = tabManager.activeURL {
                TitaniumWebView(url: .constant(activeURL))
                    .ignoresSafeArea()
            }

            // 2. THE COMMAND CENTER
            VStack(spacing: 12) {
                
                // --- THE TAB BAR ---
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tabManager.tabs) { tab in
                            Button(action: { tabManager.activeTabId = tab.id }) {
                                Text(tab.url.host ?? "New Tab")
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
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
                    // 🆕 Theme Toggle Button
                    Button(action: { themeManager.toggleTheme() }) {
                        Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                            .foregroundColor(.blue)
                    }
                    
                    TextField("Titanium Search", text: $addressText)
                        .onSubmit { loadPage() }
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .padding(10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(12)
                    
                    // 🆕 Background Upload Button
                    Button(action: { showingImagePicker = true }) {
                        Image(systemName: "photo.on.rectangle")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: { tabManager.createNewTab(url: "https://www.github.com") }) {
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
        // 🆕 Spawns the iPad Photo Picker when the button is pressed
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(image: $themeManager.backgroundImage)
        }
    }

    func loadPage() {
        var target = addressText.lowercased()
        if !target.hasPrefix("http") {
            target = "https://" + target
        }
        tabManager.createNewTab(url: target)
    }
}
