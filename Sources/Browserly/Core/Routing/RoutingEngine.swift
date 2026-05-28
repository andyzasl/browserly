import Foundation

public class RoutingEngine {
    
    public init() {}
    
    /// Evaluates a URL and an optional source app bundle ID against a list of rules.
    /// Returns the targetBrowserId of the first matching rule, or nil if no rules match.
    public func evaluate(url: URL, sourceAppBundleId: String?, rules: [Rule]) -> String? {
        guard let host = url.host else {
            return nil
        }
        
        let urlString = url.absoluteString
        
        for rule in rules {
            switch rule.type {
            case .domain:
                // Strict equality check against the host, ignoring case
                if host.caseInsensitiveCompare(rule.pattern) == .orderedSame {
                    return rule.targetBrowserId
                }
                // Handle optional 'www.' prefix matching if needed
                if host.hasPrefix("www.") {
                    let hostWithoutWww = String(host.dropFirst(4))
                    if hostWithoutWww.caseInsensitiveCompare(rule.pattern) == .orderedSame {
                        return rule.targetBrowserId
                    }
                }
                
            case .regex:
                do {
                    let regex = try NSRegularExpression(pattern: rule.pattern, options: [.caseInsensitive])
                    let range = NSRange(location: 0, length: urlString.utf16.count)
                    if regex.firstMatch(in: urlString, options: [], range: range) != nil {
                        return rule.targetBrowserId
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
                    return rule.targetBrowserId
                }
            }
        }
        
        return nil
    }
}
