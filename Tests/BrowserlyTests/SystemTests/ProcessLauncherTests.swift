import XCTest
@testable import Browserly

final class ProcessLauncherTests: XCTestCase {
    
    var launcher: ProcessLauncher!
    
    override func setUp() {
        super.setUp()
        launcher = ProcessLauncher()
    }
    
    func testIsChromium() {
        XCTAssertTrue(launcher.isChromium(bundleId: "com.google.Chrome"))
        XCTAssertTrue(launcher.isChromium(bundleId: "com.brave.Browser"))
        XCTAssertTrue(launcher.isChromium(bundleId: "com.microsoft.edgemac"))
        XCTAssertTrue(launcher.isChromium(bundleId: "org.chromium.Chromium"))
        XCTAssertFalse(launcher.isChromium(bundleId: "com.apple.Safari"))
        XCTAssertFalse(launcher.isChromium(bundleId: "org.mozilla.firefox"))
    }
    
    func testGenerateChromiumArgumentsIncognito() {
        let target = TargetBrowser(
            id: "chrome-incognito",
            name: "Chrome Incognito",
            bundleId: "com.google.Chrome",
            isIncognito: true
        )
        let url = URL(string: "https://example.com")!
        
        let arguments = launcher.generateChromiumArguments(url: url, target: target)
        
        XCTAssertTrue(arguments.contains("--incognito"))
        XCTAssertEqual(arguments.last, "https://example.com")
    }
    
    func testGenerateChromiumArgumentsWithProfileAndIncognito() {
        let target = TargetBrowser(
            id: "chrome-work-private",
            name: "Chrome Work Private",
            bundleId: "com.google.Chrome",
            profileDirectory: "Work",
            isIncognito: true
        )
        let url = URL(string: "https://example.com")!
        
        let arguments = launcher.generateChromiumArguments(url: url, target: target)
        
        XCTAssertTrue(arguments.contains("--incognito"))
        XCTAssertTrue(arguments.contains("--profile-directory=Work"))
        XCTAssertEqual(arguments.last, "https://example.com")
    }
    
    func testGenerateChromiumArgumentsNormal() {
        let target = TargetBrowser(
            id: "chrome-normal",
            name: "Chrome",
            bundleId: "com.google.Chrome",
            isIncognito: false
        )
        let url = URL(string: "https://example.com")!
        
        let arguments = launcher.generateChromiumArguments(url: url, target: target)
        
        XCTAssertFalse(arguments.contains("--incognito"))
        XCTAssertEqual(arguments.last, "https://example.com")
    }
}
