import AppKit
import Foundation
import ServiceManagement

class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let routingEngine = RoutingEngine()
    private let processLauncher = ProcessLauncher()
    private let configManager = ConfigManager.shared
    private let historyManager = HistoryManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupLaunchAtLogin()
        
        let currentBundleId = Bundle.main.bundleIdentifier
        let currentPID = ProcessInfo.processInfo.processIdentifier
        let executableName = (CommandLine.arguments[0] as NSString).lastPathComponent
        
        // 1. Check if another instance is already running
        let runningApps = NSWorkspace.shared.runningApplications
        let otherInstances = runningApps.filter { app in
            if app.processIdentifier == currentPID { return false }
            
            if let bundleId = currentBundleId, let appBundleId = app.bundleIdentifier {
                return bundleId == appBundleId
            }
            
            // Fallback for non-bundled execution: check executable name
            return app.localizedName == executableName
        }
        
        if !otherInstances.isEmpty {
            print("Another instance of Browserly is already running.")
            
            // Forward any CLI arguments to the running instance
            let arguments = CommandLine.arguments
            for i in 1..<arguments.count {
                let arg = arguments[i]
                if let url = URL(string: arg), url.scheme == "http" || url.scheme == "https" {
                    if let targetApp = otherInstances.first {
                        print("Forwarding URL to running instance (PID \(targetApp.processIdentifier)): \(url)")
                        forwardURLToRunningInstance(url, targetPID: targetApp.processIdentifier)
                    }
                    break
                }
            }
            
            // Exit immediately
            NSApplication.shared.terminate(nil)
            return
        }

        // 2. Load configuration on launch
        do {
            _ = try configManager.loadOrCreateConfig()
        } catch {
            print("Failed to load config: \(error)")
        }
        
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleURLEvent(_:withReplyEvent:)),
            forEventClass: AEEventClass(kInternetEventClass),
            andEventID: AEEventID(kAEGetURL)
        )
        
        // Check for URL passed via command line arguments (first instance only)
        processCommandLineArguments()
    }
    
    private func setupLaunchAtLogin() {
        // Only attempt this if we are running as a bundled app
        guard Bundle.main.bundleIdentifier != nil else { return }
        
        do {
            if #available(macOS 13.0, *) {
                // Modern API for macOS 13+
                if SMAppService.main.status == .notRegistered {
                    try SMAppService.main.register()
                    print("Registered for launch at login.")
                }
            }
        } catch {
            print("Failed to register for launch at login: \(error)")
        }
    }
    
    private func forwardURLToRunningInstance(_ url: URL, targetPID: pid_t) {
        let appleEvent = NSAppleEventDescriptor(
            eventClass: AEEventClass(kInternetEventClass),
            eventID: AEEventID(kAEGetURL),
            targetDescriptor: NSAppleEventDescriptor(processIdentifier: targetPID),
            returnID: AEReturnID(kAutoGenerateReturnID),
            transactionID: AETransactionID(kAnyTransactionID)
        )
        appleEvent.setParam(NSAppleEventDescriptor(string: url.absoluteString), forKeyword: AEKeyword(keyDirectObject))
        
        // Use the older carbon-style send call or modern Workspace open
        // For local forwarding to our own bundleId, sending a simple event is best.
        _ = try? appleEvent.sendEvent(options: [.noReply], timeout: 0)
    }
    
    private func processCommandLineArguments() {
        let arguments = CommandLine.arguments
        // Index 0 is the executable path, look for arguments starting at index 1
        for i in 1..<arguments.count {
            let arg = arguments[i]
            if let url = URL(string: arg), url.scheme == "http" || url.scheme == "https" {
                print("Processing URL from command line: \(url)")
                route(url: url, sourceAppBundleId: "com.apple.Terminal")
                break // Only process the first valid URL found
            }
        }
    }
    
    @objc func handleURLEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        // Capture frontmost application *immediately* as the source app
        let sourceAppBundleId = NSWorkspace.shared.frontmostApplication?.bundleIdentifier
        
        guard let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue,
              let url = URL(string: urlString) else {
            return
        }
        
        print("Intercepted URL: \(url) from \(sourceAppBundleId ?? "Unknown")")
        route(url: url, sourceAppBundleId: sourceAppBundleId)
    }
    
    private func route(url: URL, sourceAppBundleId: String?) {
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
        let evaluationResult = routingEngine.evaluate(url: url, sourceAppBundleId: sourceAppBundleId, rules: config.rules)
        let targetBrowserId = evaluationResult?.browserId ?? config.defaultBrowserId
        let matchedRuleName = evaluationResult?.ruleName ?? "Default (No Match)"
        
        // 3. Find target browser info
        let targetBrowser = config.browsers.first(where: { $0.id == targetBrowserId })
        
        if let target = targetBrowser {
            // 4. Launch
            processLauncher.launch(url: url, in: target)
            
            // 5. Record History
            let historyItem = HistoryItem(
                url: url,
                sourceAppBundleId: sourceAppBundleId,
                routedToBrowserId: target.id,
                matchedRuleName: matchedRuleName
            )
            historyManager.addLink(historyItem)
        } else {
            print("Target browser ID \(targetBrowserId) not found in config. Falling back.")
            NSWorkspace.shared.open(url)
        }
    }
}
