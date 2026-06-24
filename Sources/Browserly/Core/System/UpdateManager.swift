import Foundation

public class UpdateManager {
    public static let shared = UpdateManager()
    
    private let repoUrl = "https://api.github.com/repos/andyzasl/browserly/releases/latest"
    
    private init() {}
    
    struct GitHubRelease: Codable {
        let tag_name: String
        let html_url: String
    }
    
    public func shouldCheckForUpdates(enabled: Bool, lastCheckDate: Date?, currentTime: Date) -> Bool {
        guard enabled else { return false }
        if let lastCheck = lastCheckDate,
           currentTime.timeIntervalSince(lastCheck) < 86400 {
            return false
        }
        return true
    }
    
    public func checkForUpdates() {
        guard shouldCheckForUpdates(
            enabled: AppState.shared.checkForUpdatesEnabled,
            lastCheckDate: AppState.shared.lastUpdateCheckDate,
            currentTime: Date()
        ) else { return }
        
        guard let url = URL(string: repoUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to check for updates: \(error?.localizedDescription ?? "No data")")
                return
            }
            
            DispatchQueue.main.async {
                AppState.shared.lastUpdateCheckDate = Date()
            }
            
            do {
                let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
                let version = release.tag_name.replacingOccurrences(of: "v", with: "")
                
                DispatchQueue.main.async {
                    AppState.shared.latestVersion = version
                    AppState.shared.updateUrl = URL(string: release.html_url)
                }
            } catch {
                print("Failed to parse update info: \(error.localizedDescription)")
            }
        }
        
        task.resume()
    }
}


