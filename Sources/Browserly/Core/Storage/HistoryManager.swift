import Foundation
import AppKit

public struct HistoryItem: Identifiable, Equatable {
    public let id: UUID
    public let url: URL
    public let timestamp: Date
    public let sourceAppBundleId: String?
    public let routedToBrowserId: String
    
    public init(id: UUID = UUID(), url: URL, timestamp: Date = Date(), sourceAppBundleId: String? = nil, routedToBrowserId: String) {
        self.id = id
        self.url = url
        self.timestamp = timestamp
        self.sourceAppBundleId = sourceAppBundleId
        self.routedToBrowserId = routedToBrowserId
    }
}

public class HistoryManager: ObservableObject {
    public static let shared = HistoryManager()
    
    @Published public private(set) var recentLinks: [HistoryItem] = []
    
    private let maxHistoryItems = 5
    
    private init() {}
    
    public func addLink(_ item: HistoryItem) {
        DispatchQueue.main.async {
            self.recentLinks.insert(item, at: 0)
            if self.recentLinks.count > self.maxHistoryItems {
                self.recentLinks.removeLast()
            }
        }
    }
    
    public func clearHistory() {
        DispatchQueue.main.async {
            self.recentLinks.removeAll()
        }
    }
}
