import SwiftUI

struct PopoverView: View {
    @ObservedObject var appState = AppState.shared
    @ObservedObject var historyManager = HistoryManager.shared
    
    let configManager = ConfigManager.shared
    let processLauncher = ProcessLauncher()
    
    // For MVP, we'll extract Work/Personal from the config if available, 
    // or just show a general list. Real implementations would bind these 
    // directly back to the ConfigManager and save.
    @State private var defaultBrowserId: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header & Pause
            HStack {
                Text("Browserly")
                    .font(.title2)
                    .bold()
                Spacer()
                Toggle("Pause Routing", isOn: $appState.isPaused)
                    .toggleStyle(.switch)
            }
            
            Divider()
            
            // Browsers (Simplified MVP version)
            if let config = configManager.currentConfig {
                BrowserPicker(
                    title: "Default Fallback",
                    selectedBrowserId: $defaultBrowserId,
                    availableBrowsers: config.browsers
                )
                .onAppear {
                    defaultBrowserId = config.defaultBrowserId
                }
                .onChange(of: defaultBrowserId) { oldValue, newValue in
                    // In a full implementation, save this back to ConfigManager
                    print("Default browser changed from \(oldValue) to: \(newValue)")
                }
            } else {
                Text("No configuration found.")
                    .foregroundColor(.red)
            }
            
            Divider()
            
            // History
            Text("Recent Links")
                .font(.headline)
            
            if historyManager.recentLinks.isEmpty {
                Text("No recent activity")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(historyManager.recentLinks) { item in
                            HistoryRow(
                                item: item,
                                browsers: configManager.currentConfig?.browsers ?? [],
                                onOpenIn: { url, target in
                                    // Bypass RoutingEngine, launch directly
                                    processLauncher.launch(url: url, in: target)
                                }
                            )
                            if item.id != historyManager.recentLinks.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button("Set Default") {
                    let bundleId = Bundle.main.bundleIdentifier ?? "com.browserly.app"
                    LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)
                    LSSetDefaultHandlerForURLScheme("https" as CFString, bundleId as CFString)
                    print("Attempted to set as default handler for http/https")
                }
                .help("Set Browserly as the default system browser")
                
                Spacer()
                
                Button("Settings...") {
                    // Placeholder for future Settings window
                    print("Open Settings")
                }
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding()
        .frame(width: 350)
    }
}
