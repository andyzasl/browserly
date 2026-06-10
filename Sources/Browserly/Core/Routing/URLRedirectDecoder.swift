import Foundation

/// Represents a rule for decoding a wrapped URL from a known redirector.
public struct RedirectorRule {
    public let hostPattern: String
    public let parameterName: String
    
    public init(hostPattern: String, parameterName: String) {
        self.hostPattern = hostPattern
        self.parameterName = parameterName
    }
    
    /// Checks if the given host matches the rule's host pattern.
    /// Supports simple wildcard `*` at the beginning (e.g., `*.safelinks.protection.outlook.com`).
    public func matches(host: String) -> Bool {
        if hostPattern.hasPrefix("*.") {
            let suffix = String(hostPattern.dropFirst(2))
            return host.hasSuffix(suffix) || host == suffix
        }
        return host.lowercased() == hostPattern.lowercased()
    }
}

/// The result of an attempted URL decoding operation.
public struct DecodingResult {
    public let originalURL: URL
    public let decodedURL: URL
    public let isDecoded: Bool
}

/// Decodes wrapped URLs from known enterprise redirectors.
public class URLRedirectDecoder {
    public static let shared = URLRedirectDecoder(rules: defaultRules)
    
    public static let defaultRules: [RedirectorRule] = [
        RedirectorRule(hostPattern: "statics.teams.cdn.office.net", parameterName: "url"),
        RedirectorRule(hostPattern: "teams.public.onecdn.static.microsoft", parameterName: "url"),
        RedirectorRule(hostPattern: "*.safelinks.protection.outlook.com", parameterName: "url"),
        RedirectorRule(hostPattern: "urldefense.proofpoint.com", parameterName: "u"),
        RedirectorRule(hostPattern: "slack-redir.net", parameterName: "url")
    ]
    
    private var rules: [RedirectorRule] = []
    
    public init(rules: [RedirectorRule] = []) {
        self.rules = rules
    }
    
    /// Attempts to decode the given URL using known redirector rules.
    /// Supports recursive decoding up to a maximum depth.
    public func decode(_ url: URL, depth: Int = 0) -> URL {
        // Prevent infinite loops or excessive recursion
        guard depth < 3 else { return url }
        
        guard let host = url.host else { return url }
        
        for rule in rules {
            if rule.matches(host: host) {
                if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                   let queryItems = components.queryItems,
                   let targetEncoded = queryItems.first(where: { $0.name == rule.parameterName })?.value {
                    
                    var decodedString = targetEncoded.removingPercentEncoding ?? targetEncoded
                    
                    // Special handling for Proofpoint v2 encoding
                    if host.contains("proofpoint.com") {
                        decodedString = decodedString
                            .replacingOccurrences(of: "-3A", with: ":")
                            .replacingOccurrences(of: "_", with: "/")
                    }
                    
                    if let targetURL = URL(string: decodedString) {
                        // Recursively decode in case of nested redirectors
                        return decode(targetURL, depth: depth + 1)
                    }
                }
            }
        }
        
        return url
    }
    
    /// Updates the rules used by the decoder.
    public func setRules(_ rules: [RedirectorRule]) {
        self.rules = rules
    }
}
