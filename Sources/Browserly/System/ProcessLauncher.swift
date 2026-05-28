import Foundation
import AppKit

public class ProcessLauncher {
    
    public init() {}
    
    /// Launches the given URL in the specified target browser.
    public func launch(url: URL, in target: TargetBrowser) {
        // If it's a Chromium browser with specific flags
        if target.bundleId.contains("chrome") || target.bundleId.contains("brave") || target.bundleId.contains("msedge") {
            if target.profileDirectory != nil || target.isIncognito {
                launchChromium(url: url, target: target)
                return
            }
        }
        
        // Standard launch via NSWorkspace
        launchStandard(url: url, bundleId: target.bundleId)
    }
    
    private func launchChromium(url: URL, target: TargetBrowser) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: target.bundleId) else {
            print("Failed to find app for bundle ID: \(target.bundleId)")
            // Fallback to standard system open if app is missing
            NSWorkspace.shared.open(url)
            return
        }
        
        // Construct path to the executable inside the .app bundle
        let appName = appURL.deletingPathExtension().lastPathComponent
        let executablePath = appURL.appendingPathComponent("Contents/MacOS/\(appName)").path
        
        var arguments = [String]()
        
        if let profile = target.profileDirectory, !profile.isEmpty {
            arguments.append("--profile-directory=\(profile)")
        }
        
        if target.isIncognito {
            arguments.append("--incognito")
        }
        
        arguments.append(url.absoluteString)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executablePath)
        process.arguments = arguments
        
        do {
            try process.run()
        } catch {
            print("Failed to run Process: \(error.localizedDescription)")
            // Fallback
            launchStandard(url: url, bundleId: target.bundleId)
        }
    }
    
    private func launchStandard(url: URL, bundleId: String) {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) else {
            print("Failed to find app for bundle ID: \(bundleId), falling back to default.")
            NSWorkspace.shared.open(url)
            return
        }
        
        let configuration = NSWorkspace.OpenConfiguration()
        NSWorkspace.shared.open([url], withApplicationAt: appURL, configuration: configuration) { _, error in
            if let error = error {
                print("Failed to open URL in \(bundleId): \(error.localizedDescription)")
                // Absolute fallback
                NSWorkspace.shared.open(url)
            }
        }
    }
}
