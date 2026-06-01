import XCTest
@testable import Browserly

final class URLRedirectDecoderTests: XCTestCase {
    
    func testHostMatching() {
        let rule = RedirectorRule(hostPattern: "example.com", parameterName: "url")
        XCTAssertTrue(rule.matches(host: "example.com"))
        XCTAssertTrue(rule.matches(host: "EXAMPLE.COM"))
        XCTAssertFalse(rule.matches(host: "sub.example.com"))
        XCTAssertFalse(rule.matches(host: "other.com"))
    }
    
    func testWildcardHostMatching() {
        let rule = RedirectorRule(hostPattern: "*.example.com", parameterName: "url")
        XCTAssertTrue(rule.matches(host: "example.com"))
        XCTAssertTrue(rule.matches(host: "sub.example.com"))
        XCTAssertTrue(rule.matches(host: "a.b.example.com"))
        XCTAssertFalse(rule.matches(host: "example.net"))
    }
    
    func testBasicDecoding() {
        let rule = RedirectorRule(hostPattern: "redirect.net", parameterName: "url")
        let decoder = URLRedirectDecoder(rules: [rule])
        
        let wrappedURL = URL(string: "https://redirect.net/path?url=https%3A%2F%2Ftarget.com%2Fpage%3Fq%3Dtest")!
        let decodedURL = decoder.decode(wrappedURL)
        
        XCTAssertEqual(decodedURL.absoluteString, "https://target.com/page?q=test")
    }
    
    func testNoMatchDecoding() {
        let rule = RedirectorRule(hostPattern: "redirect.net", parameterName: "url")
        let decoder = URLRedirectDecoder(rules: [rule])
        
        let normalURL = URL(string: "https://normal.com/page")!
        let decodedURL = decoder.decode(normalURL)
        
        XCTAssertEqual(decodedURL.absoluteString, "https://normal.com/page")
    }
    
    func testMissingParameterDecoding() {
        let rule = RedirectorRule(hostPattern: "redirect.net", parameterName: "url")
        let decoder = URLRedirectDecoder(rules: [rule])
        
        let wrappedURL = URL(string: "https://redirect.net/path?other=foo")!
        let decodedURL = decoder.decode(wrappedURL)
        
        XCTAssertEqual(decodedURL.absoluteString, "https://redirect.net/path?other=foo")
    }
    
    func testRecursiveDecoding() {
        let rule1 = RedirectorRule(hostPattern: "r1.com", parameterName: "u")
        let rule2 = RedirectorRule(hostPattern: "r2.com", parameterName: "target")
        let decoder = URLRedirectDecoder(rules: [rule1, rule2])
        
        // r1 wraps r2 which wraps github.com
        let inner = "https%3A%2F%2Fgithub.com"
        let middle = "https%3A%2F%2Fr2.com%2F%3Ftarget%3D\(inner)"
        let outerURL = URL(string: "https://r1.com/?u=\(middle)")!
        
        let decodedURL = decoder.decode(outerURL)
        
        XCTAssertEqual(decodedURL.absoluteString, "https://github.com")
    }
}
