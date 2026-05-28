import AppKit
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let routingEngine = RoutingEngine()
    private let processLauncher = ProcessLauncher()
    private let configManager = ConfigManager.shared
    private let historyManager = HistoryManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Load configuration on launch
        do {
            _ = try configManager.loadOrCreateConfig()
        } catch {
            // For MVP, if config fails to load, we just print. 
            // Phase 5 will add the fatal error dialog.
            print("Failed to load config: \(error)")
        }
        
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Capture frontmost application *immediately* as the source app
        let sourceAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        print("Intercepted URL: \(url) from \(sourceAppBundleId ?? "Unknown")")
        
        guard let config = configManager.currentConfig else {
            print("No configuration available. Opening in default system browser.")
            NSWorkspace.shared.open(url)
            return
        }
        
        // Check if routing is paused
        if AppState.shared.isPaused {
            print("Routing is paused. Falling back to default browser.")
            if let fallbackTarget = config.browsers.first(where: { $0.id == config.defaultBrowserId }) {
                processLauncher.launch(url: url, in: fallbackTarget)
            } else {
                NSWorkspace.shared.open(url)
            }
            return
        }
        
        // 2. Evaluate rules
        let targetBrowserId = routingEngine.evaluate(url: url, sourceAppBundleId: sourceAppBundleId, rules: config.rules) ?? config.defaultBrowserId
        
        // 3. Find target browser info
        let targetBrowser = config.browsers.first(where: { $0.id == targetBrowserId })
        
        if let target = targetBrowser {
            // 4. Launch
            processLauncher.launch(url: url, in: target)
            
            // 5. Record History
            let historyItem = HistoryItem(
                url: url,
                sourceAppBundleId: sourceAppBundleId,
                routedToBrowserId: target.id
            )
            historyManager.addLink(historyItem)
        } else {
            print("Target browser ID \(targetBrowserId) not found in config. Falling back.")
            NSWorkspace.shared.open(url)
        }
    }
}