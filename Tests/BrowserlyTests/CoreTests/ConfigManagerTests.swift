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
        
        _ = withObservationTracking {
            _ = configManager.currentConfig
        } onChange: {
            expectation.fulfill()
        }
        
        // Trigger a load
        _ = try? configManager.loadOrCreateConfig()
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testUpdateDefaultBrowser() {
        // Load initial config
        _ = try? configManager.loadOrCreateConfig()
        
        let newDefault = "new-test-browser"
        configManager.updateDefaultBrowser(id: newDefault)
        
        XCTAssertEqual(configManager.currentConfig?.defaultBrowserId, newDefault)
    }
}
