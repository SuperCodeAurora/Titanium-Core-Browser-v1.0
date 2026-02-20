import Foundation
import SwiftData

// 🕰️ THE TIME MACHINE SCHEMA
// The @Model macro automatically turns this Swift class into an ultra-fast SQLite database table.
@Model
class HistoryItem {
    @Attribute(.unique) var id: UUID
    var url: String
    var title: String
    var timestamp: Date
    
    init(url: String, title: String = "Unknown Site") {
        self.id = UUID()
        self.url = url
        self.title = title
        self.timestamp = Date() // Automatically logs the exact millisecond you visited
    }
}
