import XCTest
@testable import Browserly

final class RegexRoutingTests: XCTestCase {
    
    var engine: RoutingEngine!
    
    override func setUp() {
        super.setUp()
        engine = RoutingEngine()
    }
    
    func testComplexRegexMatch() {
        // Match specific subdomains and paths
        let rule = Rule(
            type: .regex,
            pattern: "^https://(dev|staging)\\.example\\.com/api/.*",
            targetBrowserId: "chrome-dev"
        )
        
        let validURL1 = URL(string: "https://dev.example.com/api/v1/users")!
        let validURL2 = URL(string: "https://staging.example.com/api/login")!
        let invalidURL1 = URL(string: "https://prod.example.com/api/v1/users")!
        let invalidURL2 = URL(string: "https://dev.example.com/website")!
        
        XCTAssertEqual(engine.evaluate(url: validURL1, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-dev")
        XCTAssertEqual(engine.evaluate(url: validURL2, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-dev")
        XCTAssertNil(engine.evaluate(url: invalidURL1, sourceAppBundleId: nil, rules: [rule]))
        XCTAssertNil(engine.evaluate(url: invalidURL2, sourceAppBundleId: nil, rules: [rule]))
    }
    
    func testCaseInsensitiveRegex() {
        // Swift's NSRegularExpression usually defaults to case-sensitive unless specified.
        // Let's see how our RoutingEngine handles it.
        let rule = Rule(
            type: .regex,
            pattern: "(?i)GOOGLE\\.COM", // Using inline flag for case insensitivity
            targetBrowserId: "safari"
        )
        
        let url1 = URL(string: "https://google.com")!
        let url2 = URL(string: "https://GOOGLE.COM")!
        
        XCTAssertEqual(engine.evaluate(url: url1, sourceAppBundleId: nil, rules: [rule])?.browserId, "safari")
        XCTAssertEqual(engine.evaluate(url: url2, sourceAppBundleId: nil, rules: [rule])?.browserId, "safari")
    }
    
    func testRegexWithQueryParameters() {
        let rule = Rule(
            type: .regex,
            pattern: ".*[?&]debug=true.*",
            targetBrowserId: "chrome-debug"
        )
        
        let url1 = URL(string: "https://example.com/page?debug=true")!
        let url2 = URL(string: "https://example.com/page?id=123&debug=true&other=1")!
        let url3 = URL(string: "https://example.com/page?debug=false")!
        
        XCTAssertEqual(engine.evaluate(url: url1, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-debug")
        XCTAssertEqual(engine.evaluate(url: url2, sourceAppBundleId: nil, rules: [rule])?.browserId, "chrome-debug")
        XCTAssertNil(engine.evaluate(url: url3, sourceAppBundleId: nil, rules: [rule]))
    }
    
    func testInvalidRegexDoesNotCrash() {
        let rule = Rule(
            type: .regex,
            pattern: "[", // Invalid regex
            targetBrowserId: "any"
        )
        
        let url = URL(string: "https://example.com")!
        
        // Should not crash, just not match
        XCTAssertNil(engine.evaluate(url: url, sourceAppBundleId: nil, rules: [rule]))
    }
}
