import Foundation

// --- Mocking necessary parts of the app for standalone testing ---

// Manually include RoutingEngine logic to avoid target issues in a script
public enum MatchType: String, Codable {
    case domain, regex, sourceApp
}

public struct Rule {
    public var id: UUID
    public var name: String?
    public var type: MatchType
    public var pattern: String
    public var targetBrowserId: String
}

public class RoutingEngine {
    public init() {}
    public func evaluate(url: URL, sourceAppBundleId: String?, rules: [Rule]) -> (browserId: String, ruleName: String?)? {
        guard let host = url.host else { return nil }
        let urlString = url.absoluteString
        for rule in rules {
            switch rule.type {
            case .domain:
                if host.caseInsensitiveCompare(rule.pattern) == .orderedSame { return (rule.targetBrowserId, rule.name ?? "Domain: \(rule.pattern)") }
                if host.hasPrefix("www.") {
                    let hostWithoutWww = String(host.dropFirst(4))
                    if hostWithoutWww.caseInsensitiveCompare(rule.pattern) == .orderedSame { return (rule.targetBrowserId, rule.name ?? "Domain: \(rule.pattern)") }
                }
            case .regex:
                do {
                    let regex = try NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive])
                    let range = NSRange(location: 0, length: urlString.utf16.count)
                    if regex.firstMatch(in: urlString, options: [], range: range) != nil { return (rule.targetBrowserId, rule.name ?? "Regex Match") }
                } catch { continue }
            case .sourceApp:
                guard let sourceApp = sourceAppBundleId else { continue }
                if sourceApp.caseInsensitiveCompare(rule.pattern) == .orderedSame { return (rule.targetBrowserId, rule.name ?? "Source App: \(rule.pattern)") }
            }
        }
        return nil
    }
}

// --- Test Runner ---

func assert(_ condition: Bool, _ message: String, file: StaticString = #file, line: UInt = #line) {
    if !condition {
        print("❌ FAIL: \(message) at \(file):\(line)")
        exit(1)
    }
}

print("🚀 Running Standalone Routing Tests...")

let engine = RoutingEngine()

// Test Domain Match
let domainRule = Rule(id: UUID(), type: .domain, pattern: "github.com", targetBrowserId: "work")
assert(engine.evaluate(url: URL(string: "https://github.com/test")!, sourceAppBundleId: nil, rules: [domainRule])?.browserId == "work", "Domain match failed")
assert(engine.evaluate(url: URL(string: "https://www.github.com/test")!, sourceAppBundleId: nil, rules: [domainRule])?.browserId == "work", "WWW Domain match failed")

// Test Regex Match
let regexRule = Rule(id: UUID(), type: .regex, pattern: ".*[?&]debug=true.*", targetBrowserId: "debug")
assert(engine.evaluate(url: URL(string: "https://example.com?debug=true")!, sourceAppBundleId: nil, rules: [regexRule])?.browserId == "debug", "Regex query param match failed")

// Test Source App Match
let appRule = Rule(id: UUID(), type: .sourceApp, pattern: "com.apple.Terminal", targetBrowserId: "terminal")
assert(engine.evaluate(url: URL(string: "https://link.com")!, sourceAppBundleId: "com.apple.Terminal", rules: [appRule])?.browserId == "terminal", "Source app match failed")

print("✅ All Standalone Tests Passed!")
