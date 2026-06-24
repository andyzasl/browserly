import Observation
import Foundation
import SwiftUI

@Observable
public class AppState {
    public static let shared = AppState()
    
    public var isPaused: Bool {
        get {
            access(keyPath: \.isPaused)
            return UserDefaults.standard.bool(forKey: "isPaused")
        }
        set {
            withMutation(keyPath: \.isPaused) {
                UserDefaults.standard.set(newValue, forKey: "isPaused")
            }
        }
    }

    public var launchAtLogin: Bool {
        get {
            access(keyPath: \.launchAtLogin)
            return UserDefaults.standard.bool(forKey: "launchAtLogin")
        }
        set {
            withMutation(keyPath: \.launchAtLogin) {
                UserDefaults.standard.set(newValue, forKey: "launchAtLogin")
            }
        }
    }
    
    // Update tracking
    public var latestVersion: String? = nil
    public var updateUrl: URL? = nil
    internal var mockCurrentVersion: String? = nil
    
    public var checkForUpdatesEnabled: Bool {
        get {
            access(keyPath: \.checkForUpdatesEnabled)
            if UserDefaults.standard.object(forKey: "checkForUpdatesEnabled") == nil {
                return true
            }
            return UserDefaults.standard.bool(forKey: "checkForUpdatesEnabled")
        }
        set {
            withMutation(keyPath: \.checkForUpdatesEnabled) {
                UserDefaults.standard.set(newValue, forKey: "checkForUpdatesEnabled")
            }
        }
    }
    
    public var lastUpdateCheckDate: Date? {
        get {
            access(keyPath: \.lastUpdateCheckDate)
            return UserDefaults.standard.object(forKey: "lastUpdateCheckDate") as? Date
        }
        set {
            withMutation(keyPath: \.lastUpdateCheckDate) {
                UserDefaults.standard.set(newValue, forKey: "lastUpdateCheckDate")
            }
        }
    }
    
    public var currentVersion: String {
        mockCurrentVersion ?? (Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0")
    }
    
    public var isUpdateAvailable: Bool {
        guard let latest = latestVersion else { return false }
        return latest.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    private init() {}
}
