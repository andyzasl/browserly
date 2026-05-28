import SwiftUI

public class AppState: ObservableObject {
    public static let shared = AppState()
    
    @AppStorage("isPaused") public var isPaused: Bool = false
    
    private init() {}
}
