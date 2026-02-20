import SwiftUI

// 🎨 THE THEME ENGINE: Now equipped with Persistent File Storage
class ThemeManager: ObservableObject {
    
    // didSet saves the toggle state immediately
    @Published var isDarkMode: Bool = true {
        didSet { UserDefaults.standard.set(isDarkMode, forKey: "titanium_dark_mode") }
    }
    
    // didSet intercepts the photo picker and writes the image to the SSD
    @Published var backgroundImage: UIImage? = nil {
        didSet {
            if let image = backgroundImage {
                saveImageToDisk(image: image)
            } else {
                deleteImageFromDisk()
            }
        }
    }
    
    private let imageName = "titanium_background.jpg"
    
    init() {
        recoverThemeMemory()
    }
    
    func toggleTheme() {
        isDarkMode.toggle()
        print("🎨 Theme Engine: Switched to \(isDarkMode ? "Dark" : "Light") Mode")
    }
    
    // MARK: - 💾 MEMORY SYSTEM (SSD File Writing)
    
    private func recoverThemeMemory() {
        // 1. Recover Dark/Light Mode
        if UserDefaults.standard.object(forKey: "titanium_dark_mode") != nil {
            self.isDarkMode = UserDefaults.standard.bool(forKey: "titanium_dark_mode")
        }
        
        // 2. Recover the HD Image
        self.backgroundImage = loadImageFromDisk()
    }
    
    private func saveImageToDisk(image: UIImage) {
        // Compress the image slightly to save iPad storage space
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let url = getDocumentsDirectory().appendingPathComponent(imageName)
        
        do {
            try data.write(to: url)
            print("💾 Theme Engine: Background image permanently saved to SSD.")
        } catch {
            print("❌ Theme Engine Error: Could not save image - \(error.localizedDescription)")
        }
    }
    
    private func loadImageFromDisk() -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(imageName)
        if let data = try? Data(contentsOf: url), let loadedImage = UIImage(data: data) {
            print("🧠 Theme Engine: Recovered custom background from disk.")
            return loadedImage
        }
        return nil
    }
    
    private func deleteImageFromDisk() {
        let url = getDocumentsDirectory().appendingPathComponent(imageName)
        try? FileManager.default.removeItem(at: url)
    }
    
    // Helper function to find the exact location of the app's secure sandbox drive
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
