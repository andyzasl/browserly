import XCTest
@testable import Browserly

final class ConfigManagerTests: XCTestCase {
    
    var configManager: ConfigManager!
    
    override func setUp() {
        super.setUp()
        configManager = ConfigManager.shared
    }
    
    func testConfigManagerIsObservable() {
        let expectation = XCTestExpectation(description: "Config changes should be observed")
        
        let cancellable = configManager.$currentConfig.sink { config in
            if config != nil {
                expectation.fulfill()
            }
        }
        
        // Trigger a load
        _ = try? configManager.loadOrCreateConfig()
        
        wait(for: [expectation], timeout: 2.0)
        cancellable.cancel()
    }
    
    func testUpdateDefaultBrowser() {
        // Load initial config
        let config = try? configManager.loadOrCreateConfig()
        XCTAssertNotNil(config)
        
        let initialDefault = config?.defaultBrowserId
        let newDefault = "new-test-browser"
        
        configManager.updateDefaultBrowser(id: newDefault)
        
        XCTAssertEqual(configManager.currentConfig?.defaultBrowserId, newDefault)
    }
}

// Simple Combine-like sink for testing if Combine isn't fully available/imported
import Combine
extension Publisher {
    func sink(receiveValue: @escaping (Output) -> Void) -> AnyCancellable {
        return self.sink(receiveCompletion: { _ in }, receiveValue: receiveValue)
    }
}
