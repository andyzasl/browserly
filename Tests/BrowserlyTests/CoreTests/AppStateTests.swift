import XCTest
@testable import Browserly

final class AppStateTests: XCTestCase {
    
    var appState: AppState!
    
    override func setUp() {
        super.setUp()
        appState = AppState.shared
        // Reset defaults for testing
        UserDefaults.standard.removeObject(forKey: "isPaused")
        UserDefaults.standard.removeObject(forKey: "launchAtLogin")
    }
    
    func testIsPausedPersistence() {
        XCTAssertFalse(appState.isPaused)
        
        appState.isPaused = true
        XCTAssertTrue(appState.isPaused)
        
        // Verify in UserDefaults directly
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "isPaused"))
        
        appState.isPaused = false
        XCTAssertFalse(appState.isPaused)
    }
    
    func testLaunchAtLoginPersistence() {
        XCTAssertFalse(appState.launchAtLogin)
        
        appState.launchAtLogin = true
        XCTAssertTrue(appState.launchAtLogin)
        
        XCTAssertTrue(UserDefaults.standard.bool(forKey: "launchAtLogin"))
    }
    
    func testIsUpdateAvailable() {
        appState.latestVersion = nil
        XCTAssertFalse(appState.isUpdateAvailable)
        
        appState.latestVersion = "1.0.9"
        XCTAssertTrue(appState.isUpdateAvailable)
        
        appState.latestVersion = "0.0.0"
        XCTAssertFalse(appState.isUpdateAvailable)
    }
}
