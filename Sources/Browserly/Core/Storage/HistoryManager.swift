import Foundation
import Observation

public struct HistoryItem: Identifiable, Equatable, Codable {
    public let id: UUID
    public let url: URL
    public let timestamp: Date
    public let sourceAppBundleId: String?
    public let routedToBrowserId: String
    public let matchedRuleName: String?
    
    public init(id: UUID = UUID(), url: URL, timestamp: Date = Date(), sourceAppBundleId: String? = nil, routedToBrowserId: String, matchedRuleName: String? = nil) {
        self.id = id
        self.url = url
        self.timestamp = timestamp
        self.sourceAppBundleId = sourceAppBundleId
        self.routedToBrowserId = routedToBrowserId
        self.matchedRuleName = matchedRuleName
    }
}

@Observable
public class HistoryManager {
    public static let shared = HistoryManager()
    
    public private(set) var recentLinks: [HistoryItem] = []
    private var isLoaded = false
    
    private let maxHistoryItems = 50
    private let fileName = "history.json"
    private let fileManager = FileManager.default
    
    // Internal for testing
    internal var storageURL: URL?
    
    private var fileURL: URL? {
        if let custom = storageURL { return custom }
        
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let dir = appSupportURL.appendingPathComponent("Browserly")
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent(fileName)
    }
    
    internal init() {} // Internal for testing
    
    public func addLink(_ item: HistoryItem) {
        // If not loaded, we load first to maintain order
        if !isLoaded { loadHistory() }
        
        self.recentLinks.insert(item, at: 0)
        if self.recentLinks.count > self.maxHistoryItems {
            self.recentLinks.removeLast()
        }
        self.saveHistory()
    }
    
    public func clearHistory() {
        self.recentLinks.removeAll()
        self.saveHistory()
    }
    
    public func reloadHistory() {
        loadHistory()
    }
    
    private func saveHistory() {
        guard let url = fileURL else { return }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(recentLinks)
            try data.write(to: url, options: .atomic)
        } catch {
            // Silently fail for memory efficiency
        }
    }
    
    private func loadHistory() {
        guard let url = fileURL, fileManager.fileExists(atPath: url.path) else {
            isLoaded = true
            return 
        }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let items = try decoder.decode([HistoryItem].self, from: data)
            self.recentLinks = items
            self.isLoaded = true
        } catch {
            isLoaded = true
        }
    }
}
