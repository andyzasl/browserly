import SwiftUI

struct HistoryRow: View {
    let item: HistoryItem
    let browsers: [TargetBrowser]
    let onOpenIn: (URL, TargetBrowser) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.url.host ?? "Unknown Domain")
                .font(.headline)
                .lineLimit(1)
            
            HStack {
                Text(item.url.absoluteString)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                Spacer()
                
                Menu("Open In...") {
                    ForEach(browsers) { browser in
                        Button(browser.name) {
                            onOpenIn(item.url, browser)
                        }
                    }
                }
                .menuStyle(.borderlessButton)
                .fixedSize()
            }
        }
        .padding(.vertical, 4)
    }
}

struct BrowserPicker: View {
    let title: String
    @Binding var selectedBrowserId: String
    let availableBrowsers: [TargetBrowser]
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Picker("", selection: $selectedBrowserId) {
                ForEach(availableBrowsers) { browser in
                    Text(browser.name).tag(browser.id)
                }
            }
            .labelsHidden()
            .frame(maxWidth: 150)
        }
    }
}
