import SwiftUI

@main
struct BrowserlyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    private var appState = AppState.shared

    var body: some Scene {
        MenuBarExtra(
            "Browserly",
            systemImage: appState.isPaused ? "link.badge.plus" : "link"
        ) {
            PopoverView()
        }
        .menuBarExtraStyle(.window) // Use window style for rich popover interactions
    }
}