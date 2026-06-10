import Foundation

// --- Mocking necessary parts of the app for standalone testing ---

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

public struct TargetBrowser {
    public var id: String
    public var name: String
    public var bundleId: String
    public var profileDirectory: String?
    public var isIncognito: Bool
}

public struct AppConfiguration {
    public var defaultBrowserId: String
    public var browsers: [TargetBrowser]
    public var rules: [Rule]
}

public struct HistoryItem: Identifiable, Codable {
    public let id: UUID
    public let url: URL
    public let timestamp: Date
    public let sourceAppBundleId: String?
    public let routedToBrowserId: String
    public let matchedRuleName: String?
    
    public init(id: UUID = UUID(), url: URL, timestamp: Date = Date(), sourceAppBundleId: String? = nil, routedToBrowserId: String, matchedRuleName: String? = nil) {
        self.id = id
        self.url = url
        self.timestamp = timestamp
        self.sourceAppBundleId = sourceAppBundleId
        self.routedToBrowserId = routedToBrowserId
        self.matchedRuleName = matchedRuleName
    }
}

// Mirror of Sources/Browserly/Core/Routing/URLRedirectDecoder.swift (kept in sync for CI).
public struct RedirectorRule {
    public let hostPattern: String
    public let parameterName: String
    public func matches(host: String) -> Bool {
        if hostPattern.hasPrefix("*.") {
            let suffix = String(hostPattern.dropFirst(2))
            return host.hasSuffix(suffix) || host == suffix
        }
        return host.lowercased() == hostPattern.lowercased()
    }
}

public class URLRedirectDecoder {
    public static let defaultRules: [RedirectorRule] = [
        RedirectorRule(hostPattern: "statics.teams.cdn.office.net", parameterName: "url"),
        RedirectorRule(hostPattern: "teams.public.onecdn.static.microsoft", parameterName: "url"),
        RedirectorRule(hostPattern: "*.safelinks.protection.outlook.com", parameterName: "url"),
        RedirectorRule(hostPattern: "urldefense.proofpoint.com", parameterName: "u"),
        RedirectorRule(hostPattern: "slack-redir.net", parameterName: "url")
    ]
    public static let shared = URLRedirectDecoder(rules: defaultRules)
    private var rules: [RedirectorRule]
    public init(rules: [RedirectorRule] = []) { self.rules = rules }
    public func decode(_ url: URL, depth: Int = 0) -> URL {
        guard depth < 3 else { return url }
        guard let host = url.host else { return url }
        for rule in rules where rule.matches(host: host) {
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               let targetEncoded = queryItems.first(where: { $0.name == rule.parameterName })?.value {
                var decodedString = targetEncoded.removingPercentEncoding ?? targetEncoded
                if host.contains("proofpoint.com") {
                    decodedString = decodedString
                        .replacingOccurrences(of: "-3A", with: ":")
                        .replacingOccurrences(of: "_", with: "/")
                }
                if let targetURL = URL(string: decodedString) {
                    return decode(targetURL, depth: depth + 1)
                }
            }
        }
        return url
    }
}

public class RoutingEngine {
    public init() {}
    public func evaluate(url: URL, sourceAppBundleId: String?, rules: [Rule]) -> (browserId: String, ruleName: String?)? {
        let decodedURL = URLRedirectDecoder.shared.decode(url)
        guard let host = decodedURL.host else { return nil }
        let urlString = decodedURL.absoluteString
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

public class ProcessLauncher {
    public init() {}
    public func isChromium(bundleId: String) -> Bool {
        let chromiumIds = ["com.google.chrome", "org.chromium.chromium", "com.brave.browser", "com.microsoft.edgemac"]
        return chromiumIds.contains { bundleId.lowercased().contains($0.lowercased()) } || 
               bundleId.lowercased().contains("chrome") || 
               bundleId.lowercased().contains("brave") || 
               bundleId.lowercased().contains("msedge")
    }

    public func generateChromiumArguments(url: URL, target: TargetBrowser) -> [String] {
        var arguments = [String]()
        if let profile = target.profileDirectory, !profile.isEmpty {
            arguments.append("--profile-directory=\(profile)")
        }
        if target.isIncognito {
            arguments.append("--incognito")
        }
        arguments.append(url.absoluteString)
        return arguments
    }
}

public class HistoryManager {
    public private(set) var recentLinks: [HistoryItem] = []
    private let maxHistoryItems = 5
    
    public init() {}
    
    public func addLink(_ item: HistoryItem) {
        self.recentLinks.insert(item, at: 0)
        if self.recentLinks.count > self.maxHistoryItems {
            self.recentLinks.removeLast()
        }
    }
    
    public func clearHistory() {
        self.recentLinks.removeAll()
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

print("🚀 Running Redirect Decoder Tests...")

// Teams ATP Safe Links wrapper on the new onecdn host should decode to the inner URL.
let teamsWrapped = URL(string: "https://teams.public.onecdn.static.microsoft/evergreen-assets/safelinks/2/atp-safelinks.html?url=https%3A%2F%2Fexample.com%2Fpages%2Fwiki%3FcurrentLanguage%3DEN")!
let teamsDecoded = URLRedirectDecoder.shared.decode(teamsWrapped)
assert(teamsDecoded.absoluteString == "https://example.com/pages/wiki?currentLanguage=EN", "Teams onecdn Safe Links decoding failed")

// A domain rule on the inner host must match the wrapped URL (decode happens before routing).
let wikiRule = Rule(id: UUID(), name: "Wiki", type: .domain, pattern: "example.com", targetBrowserId: "work")
assert(engine.evaluate(url: teamsWrapped, sourceAppBundleId: nil, rules: [wikiRule])?.browserId == "work", "Routing through Teams onecdn wrapper failed")

print("🚀 Running Incognito Tests...")

// Test Incognito Routing Logic
let incognitoBrowser = TargetBrowser(id: "chrome-incognito", name: "Chrome Private", bundleId: "com.google.Chrome", profileDirectory: nil, isIncognito: true)
let bankRule = Rule(id: UUID(), name: "Banking", type: .domain, pattern: "bank.com", targetBrowserId: "chrome-incognito")
let config = AppConfiguration(defaultBrowserId: "safari", browsers: [incognitoBrowser], rules: [bankRule])

let bankResult = engine.evaluate(url: URL(string: "https://bank.com")!, sourceAppBundleId: nil, rules: config.rules)
assert(bankResult?.browserId == "chrome-incognito", "Incognito routing failed")
let foundBrowser = config.browsers.first { $0.id == bankResult?.browserId }
assert(foundBrowser?.isIncognito == true, "Target browser should be incognito")

// Test ProcessLauncher Incognito Arguments
let launcher = ProcessLauncher()
assert(launcher.isChromium(bundleId: "com.google.Chrome"), "IsChromium failed for Chrome")
assert(launcher.isChromium(bundleId: "com.brave.Browser"), "IsChromium failed for Brave")
assert(!launcher.isChromium(bundleId: "com.apple.Safari"), "IsChromium should fail for Safari")

let args = launcher.generateChromiumArguments(url: URL(string: "https://bank.com")!, target: incognitoBrowser)
assert(args.contains("--incognito"), "Arguments missing --incognito")
assert(args.last == "https://bank.com", "URL should be the last argument")

print("🚀 Running History Tests...")
let history = HistoryManager()
history.addLink(HistoryItem(url: URL(string: "https://a.com")!, routedToBrowserId: "s"))
history.addLink(HistoryItem(url: URL(string: "https://b.com")!, routedToBrowserId: "s"))
assert(history.recentLinks.count == 2, "History count mismatch")
assert(history.recentLinks.first?.url.absoluteString == "https://b.com", "History order mismatch")

// Test limit (mocked to 5 in this script)
for i in 1...10 {
    history.addLink(HistoryItem(url: URL(string: "https://\(i).com")!, routedToBrowserId: "s"))
}
assert(history.recentLinks.count == 5, "History limit failed")
assert(history.recentLinks.first?.url.absoluteString == "https://10.com", "History limit order failed")

print("✅ All Standalone Tests Passed!")
