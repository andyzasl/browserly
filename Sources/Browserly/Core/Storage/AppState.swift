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
    
    public var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }
    
    public var isUpdateAvailable: Bool {
        guard let latest = latestVersion else { return false }
        return latest.compare(currentVersion, options: .numeric) == .orderedDescending
    }
    
    private init() {}
}
