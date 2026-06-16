import Foundation

public class RoutingEngine {
    
    public init() {}
    
    /// Evaluates a URL and an optional source app bundle ID against a list of rules.
    /// Returns a tuple containing the targetBrowserId and the rule name if a match was found.
    public func evaluate(url: URL, sourceAppBundleId: String?, rules: [Rule]) -> (browserId: String, ruleName: String?)? {
        let decodedURL = URLRedirectDecoder.shared.decode(url)
        
        let host = decodedURL.host
        let urlString = decodedURL.absoluteString
        
        for rule in rules {
            switch rule.type {
            case .domain:
                guard let host = host else { continue }
                // Strict equality check against the host, ignoring case
                if host.caseInsensitiveCompare(rule.pattern) == .orderedSame {
                    return (rule.targetBrowserId, rule.name ?? "Domain: \(rule.pattern)")
                }
                // Handle optional 'www.' prefix matching if needed
                if host.hasPrefix("www.") {
                    let hostWithoutWww = String(host.dropFirst(4))
                    if hostWithoutWww.caseInsensitiveCompare(rule.pattern) == .orderedSame {
                        return (rule.targetBrowserId, rule.name ?? "Domain: \(rule.pattern)")
                    }
                }
                
            case .regex:
                do {
                    let regex = try NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive])
                    let range = NSRange(location: 0, length: urlString.utf16.count)
                    if regex.firstMatch(in: urlString, options: [], range: range) != nil {
                        return (rule.targetBrowserId, rule.name ?? "Regex Match")
                    }
                } catch {
                    print("Invalid regex in rule \(rule.id): \(error.localizedDescription)")
                    // Skip malformed regex rules
                    continue
                }
                
            case .sourceApp:
                guard let sourceApp = sourceAppBundleId else {
                    continue
                }
                if sourceApp.caseInsensitiveCompare(rule.pattern) == .orderedSame {
                    return (rule.targetBrowserId, rule.name ?? "Source App: \(rule.pattern)")
                }
            }
        }
        
        return nil
    }
}
