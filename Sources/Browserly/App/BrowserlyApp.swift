import SwiftUI

@main
struct BrowserlyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("Browserly", systemImage: "link") {
            Text("Browserly Setup Complete")
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
    }
}