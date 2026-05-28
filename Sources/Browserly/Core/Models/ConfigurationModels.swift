import Foundation

public enum MatchType: String, Codable {
    case domain
    case regex
    case sourceApp
}

public struct Rule: Codable, Identifiable, Equatable {
    public var id: UUID
    public var name: String?
    public var type: MatchType
    public var pattern: String
    public var targetBrowserId: String
    
    public init(id: UUID = UUID(), name: String? = nil, type: MatchType, pattern: String, targetBrowserId: String) {
        self.id = id
        self.name = name
        self.type = type
        self.pattern = pattern
        self.targetBrowserId = targetBrowserId
    }
}

public struct TargetBrowser: Codable, Identifiable, Equatable {
    public var id: String
    public var name: String
    public var bundleId: String
    public var profileDirectory: String?
    public var isIncognito: Bool
    
    public init(id: String, name: String, bundleId: String, profileDirectory: String? = nil, isIncognito: Bool = false) {
        self.id = id
        self.name = name
        self.bundleId = bundleId
        self.profileDirectory = profileDirectory
        self.isIncognito = isIncognito
    }
}

public struct AppConfiguration: Codable, Equatable {
    public var defaultBrowserId: String
    public var browsers: [TargetBrowser]
    public var rules: [Rule]
    
    public init(defaultBrowserId: String, browsers: [TargetBrowser] = [], rules: [Rule] = []) {
        self.defaultBrowserId = defaultBrowserId
        self.browsers = browsers
        self.rules = rules
    }
}
