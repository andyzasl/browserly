import Foundation

public class UpdateManager {
    public static let shared = UpdateManager()
    
    private let repoUrl = "https://api.github.com/repos/andyzasl/browserly/releases/latest"
    
    private init() {}
    
    struct GitHubRelease: Codable {
        let tag_name: String
        let html_url: String
    }
    
    public func checkForUpdates() {
        guard let url = URL(string: repoUrl) else { return }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Failed to check for updates: \(error?.localizedDescription ?? "No data")")
                return
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
