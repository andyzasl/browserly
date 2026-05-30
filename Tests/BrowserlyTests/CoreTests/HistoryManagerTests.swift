import XCTest
@testable import Browserly

final class HistoryManagerTests: XCTestCase {
    
    var manager: HistoryManager!
    var tempFileURL: URL!
    
    override func setUp() {
        super.setUp()
        manager = HistoryManager()
        
        let tempDir = FileManager.default.temporaryDirectory
        tempFileURL = tempDir.appendingPathComponent("history_test_\(UUID().uuidString).json")
        manager.storageURL = tempFileURL
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: tempFileURL)
        super.tearDown()
    }
    
    func testAddLink() {
        let item = HistoryItem(url: URL(string: "https://apple.com")!, routedToBrowserId: "safari")
        manager.addLink(item)
        
        XCTAssertEqual(manager.recentLinks.count, 1)
        XCTAssertEqual(manager.recentLinks.first?.url.absoluteString, "https://apple.com")
    }
    
    func testHistoryLimit() {
        // Add 55 items
        for i in 1...55 {
            let item = HistoryItem(url: URL(string: "https://example.com/\(i)")!, routedToBrowserId: "safari")
            manager.addLink(item)
        }
        
        XCTAssertEqual(manager.recentLinks.count, 50)
        XCTAssertEqual(manager.recentLinks.first?.url.absoluteString, "https://example.com/55")
        XCTAssertEqual(manager.recentLinks.last?.url.absoluteString, "https://example.com/6")
    }
    
    func testPersistence() {
        let item = HistoryItem(url: URL(string: "https://persist.com")!, routedToBrowserId: "safari")
        manager.addLink(item)
        
        // Create a new manager instance and point to same file
        let secondManager = HistoryManager()
        secondManager.storageURL = tempFileURL
        secondManager.reloadHistory()
        
        XCTAssertEqual(secondManager.recentLinks.count, 1)
        XCTAssertEqual(secondManager.recentLinks.first?.url.absoluteString, "https://persist.com")
    }
    
    func testClearHistory() {
        manager.addLink(HistoryItem(url: URL(string: "https://test.com")!, routedToBrowserId: "safari"))
        XCTAssertEqual(manager.recentLinks.count, 1)
        
        manager.clearHistory()
        XCTAssertEqual(manager.recentLinks.count, 0)
        
        // Verify file is also cleared
        let secondManager = HistoryManager()
        secondManager.storageURL = tempFileURL
        secondManager.reloadHistory()
        XCTAssertEqual(secondManager.recentLinks.count, 0)
    }
}
