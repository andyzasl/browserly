import XCTest
@testable import Browserly

final class RoutingEngineTests: XCTestCase {
    
    var engine: RoutingEngine!
    
    override func setUp() {
        super.setUp()
        engine = RoutingEngine()
    }
    
    func testDomainMatch() {
        let rule = Rule(type: .domain, pattern: "github.com", targetBrowserId: "chrome-work")
        let url = URL(string: "https://github.com/my-org/repo")!
        
        let target = engine.evaluate(url: url, sourceAppBundleId: nil, rules: [rule])?.browserId
        XCTAssertEqual(target, "chrome-work")
    }
    
    func testDomainMatchWithWWW() {
        let rule = Rule(type: .domain, pattern: "github.com", targetBrowserId: "chrome-work")
        let url = URL(string: "https://www.github.com/my-org/repo")!
        
        let target = engine.evaluate(url: url, sourceAppBundleId: nil, rules: [rule])?.browserId
        XCTAssertEqual(target, "chrome-work")
    }
    
    func testRegexMatch() {
        let rule = Rule(type: .regex, pattern: "^https://(jira|confluence)\\.company\\.com", targetBrowserId: "chrome-work")
        let url1 = URL(string: "https://jira.company.com/browse/PROJ-123")!
        let url2 = URL(string: "https://confluence.company.com/pages/viewpage.action?pageId=123")!
        let url3 = URL(string: "https://other.company.com")!
        
        XCTAssertEqual(engine.evaluate(url: url1, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-work")
        XCTAssertEqual(engine.evaluate(url: url2, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-work")
        XCTAssertNil(engine.evaluate(url: url3, sourceAppBundleId: nil, rules: [rule]))
    }
    
    func testSourceAppMatch() {
        let rule = Rule(type: .sourceApp, pattern: "com.tinyspeck.slackmacgap", targetBrowserId: "chrome-work")
        let url = URL(string: "https://random-link.com")!
        
        XCTAssertEqual(engine.evaluate(url: url, sourceAppBundleId: "com.tinyspeck.slackmacgap", rules: [rule])?.browserId, "chrome-work")
        XCTAssertNil(engine.evaluate(url: url, sourceAppBundleId: "com.apple.Terminal", rules: [rule]))
    }
    
    func testSequentialPrecedence() {
        let rule1 = Rule(type: .sourceApp, pattern: "com.tinyspeck.slackmacgap", targetBrowserId: "chrome-work")
        let rule2 = Rule(type: .domain, pattern: "twitter.com", targetBrowserId: "safari-personal")
        
        let url = URL(string: "https://twitter.com/someuser")!
        
        // Match source app first
        XCTAssertEqual(engine.evaluate(url: url, sourceAppBundleId: "com.tinyspeck.slackmacgap", rules: [rule1, rule2])?.browserId, "chrome-work")
        
        // Match domain if source app doesn't match
        XCTAssertEqual(engine.evaluate(url: url, sourceAppBundleId: "com.apple.Terminal", rules: [rule1, rule2])?.browserId, "safari-personal")
    }
}
