import Foundation
import AppKit

public class BrowserDetector {
    
    public init() {}
    
    /// Returns a list of unique bundle identifiers for applications capable of handling HTTPS.
    public func discoverInstalledBrowsers() -> [String] {
        guard let httpsURL = URL(string: "https://example.com") else { return [] }
        
        let appURLs = NSWorkspace.shared.urlsForApplications(toOpen: httpsURL)
        
        let bundleIds = appURLs.compactMap { url -> String? in
            guard let bundle = Bundle(url: url) else { return nil }
            return bundle.bundleIdentifier
        }
        
        // Remove duplicates if any exist
        let uniqueHandlers = Array(Set(bundleIds))
        
        return uniqueHandlers
    }
    
    /// Helper to get the localized name of an app from its bundle ID
    public func getAppName(for bundleId: String) -> String? {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId),
              let bundle = Bundle(url: url) else {
            return nil
        }
        
        // Try CFBundleDisplayName first, then CFBundleName
        if let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            return displayName
        }
        if let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            return name
        }
        
        // Fallback to the last path component
        return url.deletingPathExtension().lastPathComponent
    }
}
