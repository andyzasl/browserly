import XCTest
@testable import Browserly

final class UpdateManagerTests: XCTestCase {
    
    var updateManager: UpdateManager!
    
    override func setUp() {
        super.setUp()
        updateManager = UpdateManager.shared
    }
    
    func testShouldCheckForUpdates() {
        let now = Date()
        
        // Case 1: Disabled
        XCTAssertFalse(updateManager.shouldCheckForUpdates(enabled: false, lastCheckDate: nil, currentTime: now))
        
        // Case 2: Enabled, first run (lastCheckDate is nil)
        XCTAssertTrue(updateManager.shouldCheckForUpdates(enabled: true, lastCheckDate: nil, currentTime: now))
        
        // Case 3: Enabled, check was less than 24 hours ago (e.g. 1 hour ago)
        let oneHourAgo = now.addingTimeInterval(-3600)
        XCTAssertFalse(updateManager.shouldCheckForUpdates(enabled: true, lastCheckDate: oneHourAgo, currentTime: now))
        
        // Case 4: Enabled, check was 23 hours and 59 minutes ago (should block check)
        let almostTwentyFourHoursAgo = now.addingTimeInterval(-86340)
        XCTAssertFalse(updateManager.shouldCheckForUpdates(enabled: true, lastCheckDate: almostTwentyFourHoursAgo, currentTime: now))
        
        // Case 5: Enabled, check was exactly 24 hours ago (should allow check)
        let twentyFourHoursAgo = now.addingTimeInterval(-86400)
        XCTAssertTrue(updateManager.shouldCheckForUpdates(enabled: true, lastCheckDate: twentyFourHoursAgo, currentTime: now))
        
        // Case 6: Enabled, check was more than 24 hours ago (e.g. 25 hours ago)
        let twentyFiveHoursAgo = now.addingTimeInterval(-90000)
        XCTAssertTrue(updateManager.shouldCheckForUpdates(enabled: true, lastCheckDate: twentyFiveHoursAgo, currentTime: now))
    }
}
