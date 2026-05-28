import Foundation
import AppKit

public enum ConfigError: Error {
    case directoryCreationFailed
    case loadFailed(Error)
    case saveFailed(Error)
    case invalidData
}

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
        
        // If file exists, load it
        if fileManager.fileExists(atPath: fileURL.path) {
            do {
                let data = try Data(contentsOf: fileURL)
                let decoder = JSONDecoder()
                let config = try decoder.decode(AppConfiguration.self, from: data)
                self.currentConfig = config
                return config
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
        }
        
        // File doesn't exist, create default
        let defaultConfig = generateDefaultConfig()
        try saveConfig(defaultConfig)
        self.currentConfig = defaultConfig
        return defaultConfig
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
    
    private func generateDefaultConfig() -> AppConfiguration {
        // Find Safari as a safe fallback. If not found, create a dummy ID.
        let defaultBrowserId = "safari-default"
        let safariBrowser = TargetBrowser(
            id: defaultBrowserId,
            name: "Safari",
            bundleId: "com.apple.Safari",
            profileDirectory: nil,
            isIncognito: false
        )
        
        return AppConfiguration(
            defaultBrowserId: defaultBrowserId,
            browsers: [safariBrowser],
            rules: []
        )
    }
}
