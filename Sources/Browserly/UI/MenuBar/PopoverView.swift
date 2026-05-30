import SwiftUI

struct PopoverView: View {
    var appState = AppState.shared
    var historyManager = HistoryManager.shared
    var configManager = ConfigManager.shared

    let processLauncher = ProcessLauncher()
    @State private var defaultBrowserId: String = ""

    var body: some View {
        @Bindable var bAppState = appState

        VStack(alignment: .leading, spacing: 0) {
            // --- HEADER ---
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Browserly")
                        .font(.title2)
                        .bold()
                    Spacer()
                    Toggle("Pause Routing", isOn: $bAppState.isPaused)
                        .toggleStyle(.switch)
                }

                Toggle("Launch at Login", isOn: $bAppState.launchAtLogin)
                    .toggleStyle(.checkbox)
                    .onChange(of: bAppState.launchAtLogin) {
                        (NSApplication.shared.delegate as? AppDelegate)?.syncLaunchAtLogin()
                    }

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
                        configManager.updateDefaultBrowser(id: newValue)
                    }
                } else {
                    Text("No configuration found.")
                        .foregroundColor(.red)
                }
            }
            .padding()

            Divider()

            // --- FIXED CONTENT ---
            VStack(alignment: .leading, spacing: 8) {
                Text("Recent Links")
                    .font(.headline)
                    .padding(.horizontal)
                    .padding(.top, 8)

                if historyManager.recentLinks.isEmpty {
                    VStack {
                        Spacer()
                        Text("No recent activity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                } else {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(historyManager.recentLinks.prefix(5)) { item in
                            HStack(alignment: .center, spacing: 8) {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(item.url.absoluteString)
                                        .font(.system(size: 12, weight: .medium))
                                        .lineLimit(1)
                                        .truncationMode(.tail)

                                    if let source = item.sourceAppBundleId {
                                        let ruleInfo = item.matchedRuleName != nil ? " • \(item.matchedRuleName!)" : ""
                                        Text("from \(source.replacingOccurrences(of: "com.apple.", with: ""))\(ruleInfo)")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    } else if let rule = item.matchedRuleName {
                                        Text("via \(rule)")
                                            .font(.system(size: 10))
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                    }
                                }

                                Spacer()

                                Button(action: {
                                    NSPasteboard.general.clearContents()
                                    NSPasteboard.general.setString(item.url.absoluteString, forType: .string)
                                }) {
                                    Image(systemName: "doc.on.doc")
                                        .font(.system(size: 10))
                                }
                                .buttonStyle(.borderless)
                                .help("Copy URL")
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.primary.opacity(0.04))
                            .cornerRadius(6)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
            }

            Divider()

            // --- FOOTER ---
            HStack {
                Button("Set Default") {
                    let bundleId = Bundle.main.bundleIdentifier ?? "com.browserly.app"
                    LSSetDefaultHandlerForURLScheme("http" as CFString, bundleId as CFString)
                    LSSetDefaultHandlerForURLScheme("https" as CFString, bundleId as CFString)
                }
                .help("Set Browserly as the default system browser")

                Spacer()

                Button("Settings...") {
                    if let url = configManager.configDirectoryURL {
                        NSWorkspace.shared.open(url)
                    }
                }
                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
            }
            .padding()
        }
        .frame(width: 350)
        .onAppear {
            historyManager.reloadHistory()
        }
    }
}

