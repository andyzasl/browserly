import Foundation
import Observation
import AppKit

public enum ConfigError: Error {
    case directoryCreationFailed
    case loadFailed(Error)
    case saveFailed(Error)
    case invalidData
}

@Observable
public class ConfigManager {
    public static let shared = ConfigManager()
    private let fileManager = FileManager.default
    private let fileName = "config.json"
    
    public private(set) var currentConfig: AppConfiguration?
    
    private init() {}
    
    public var configDirectoryURL: URL? {
        guard let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return nil
        }
        let browserlyURL = appSupportURL.appendingPathComponent("Browserly", isDirectory: true)
        return browserlyURL
    }
    
    private var fileURL: URL? {
        return configDirectoryURL?.appendingPathComponent(fileName)
    }
    
    public func loadOrCreateConfig() throws -> AppConfiguration {
        guard let dirURL = configDirectoryURL, let fileURL = fileURL else {
            throw ConfigError.directoryCreationFailed
        }
        
        // Ensure directory exists
        if !fileManager.fileExists(atPath: dirURL.path) {
            do {
                try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw ConfigError.directoryCreationFailed
            }
        }
        
        let config: AppConfiguration
        // If file exists, load it
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                config = try decoder.decode(AppConfiguration.self, from: data)
                self.currentConfig = config
            } catch {
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "Configuration Error"
                    alert.informativeText = "The configuration file is corrupted or invalid. Browserly cannot start.\n\nError: \(error.localizedDescription)"
                    alert.alertStyle = .critical
                    alert.addButton(withTitle: "Quit")
                    alert.runModal()
                    NSApplication.shared.terminate(nil)
                }
                throw ConfigError.loadFailed(error)
            }
        } else {
            // File doesn't exist, create default
            config = generateDefaultConfig()
            try saveConfig(config)
            self.currentConfig = config
        }
        
        // Always sync with system on startup to detect new browsers
        syncBrowsersWithSystem()
        
        return self.currentConfig ?? config
    }
    
    public func saveConfig(_ config: AppConfiguration) throws {
        guard let fileURL = fileURL else {
            throw ConfigError.directoryCreationFailed
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(config)
            try data.write(to: fileURL, options: .atomic)
            self.currentConfig = config
        } catch {
            throw ConfigError.saveFailed(error)
        }
    }
    
    /// Detects new browsers installed on the system and adds them to the configuration.
    public func syncBrowsersWithSystem() {
        guard var config = currentConfig else { return }
        let detector = BrowserDetector()
        let bundleIds = detector.discoverInstalledBrowsers()
        
        var updated = false
        for bundleId in bundleIds {
            // Only add if it doesn't exist yet
            if !config.browsers.contains(where: { $0.bundleId == bundleId }) {
                let name = detector.getAppName(for: bundleId) ?? bundleId
                // Generate a stable ID from the bundle ID
                let id = bundleId.lowercased().replacingOccurrences(of: ".", with: "-")
                let target = TargetBrowser(id: id, name: name, bundleId: bundleId)
                config.browsers.append(target)
                updated = true
                print("Detected new browser: \(name) (\(bundleId))")
            }
        }
        
        if updated {
            try? saveConfig(config)
        }
    }
    
    /// Updates the default browser ID and saves the configuration.
    public func updateDefaultBrowser(id: String) {
        guard var config = currentConfig else { return }
        if config.defaultBrowserId != id {
            config.defaultBrowserId = id
            try? saveConfig(config)
            print("Default browser updated to: \(id)")
        }
    }
    
    private func generateDefaultConfig() -> AppConfiguration {
        let detector = BrowserDetector()
        let bundleIds = detector.discoverInstalledBrowsers()
        
        var browsers: [TargetBrowser] = []
        var defaultBrowserId = ""
        
        for bundleId in bundleIds {
            let name = detector.getAppName(for: bundleId) ?? bundleId
            let id = bundleId.lowercased().replacingOccurrences(of: ".", with: "-")
            let target = TargetBrowser(id: id, name: name, bundleId: bundleId)
            browsers.append(target)
            
            // Prefer Safari as the initial default
            if bundleId == "com.apple.Safari" {
                defaultBrowserId = id
            }
        }
        
        // Fallback if Safari wasn't found or nothing found
        if defaultBrowserId.isEmpty && !browsers.isEmpty {
            defaultBrowserId = browsers[0].id
        } else if browsers.isEmpty {
            defaultBrowserId = "safari-default"
            browsers.append(TargetBrowser(
                id: defaultBrowserId,
                name: "Safari",
                bundleId: "com.apple.Safari",
                profileDirectory: nil,
                isIncognito: false
            ))
        }
        
        return AppConfiguration(
            defaultBrowserId: defaultBrowserId,
            browsers: browsers,
            rules: []
        )
    }
}
