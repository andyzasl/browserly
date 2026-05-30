import Foundation

// --- Mocking necessary parts for performance testing ---

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

// --- Performance Test Suite ---

print("🏎️  Starting Routing Performance Benchmarks...")

let engine = RoutingEngine()

// 1. Setup a large set of rules (100 rules)
var rules: [Rule] = []
for i in 1...100 {
    rules.append(Rule(id: UUID(), name: "Rule \(i)", type: .domain, pattern: "domain-\(i).com", targetBrowserId: "browser-\(i)"))
}
// Add a few regex rules at the end to ensure we test the slower path
rules.append(Rule(id: UUID(), name: "Complex Regex", type: .regex, pattern: ".*telekom.*", targetBrowserId: "chrome"))

let testURLs = [
    URL(string: "https://domain-50.com/path?query=1")!,
    URL(string: "https://wiki.telekom.de/display/PAGE")!,
    URL(string: "https://google.com/search")!, // Will hit default (no match)
    URL(string: "https://domain-99.com")!
]

let iterations = 10_000
print("📊 Running \(iterations) routing evaluations against \(rules.count) rules...")

let start = DispatchTime.now()

for _ in 0..<iterations {
    for url in testURLs {
        _ = engine.evaluate(url: url, sourceAppBundleId: "com.apple.Terminal", rules: rules)
    }
}

let end = DispatchTime.now()
let timeInterval = Double(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000

let totalEvaluations = iterations * testURLs.count
let avgTime = (timeInterval / Double(totalEvaluations)) * 1_000_000

print("--------------------------------------------------")
print("🏁 Benchmark Complete")
print("⏱️  Total Time: \(String(format: "%.4f", timeInterval)) seconds")
print("📉 Avg Time per Routing: \(String(format: "%.4f", avgTime)) microseconds (μs)")
print("🚀 Throughput: \(Int(Double(totalEvaluations) / timeInterval)) routings/sec")
print("--------------------------------------------------")

if avgTime > 500 {
    print("⚠️  Warning: Routing is slower than expected (>500μs per match)")
} else {
    print("✅ Performance is optimal.")
}
