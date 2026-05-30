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
    
    private init() {}
}
