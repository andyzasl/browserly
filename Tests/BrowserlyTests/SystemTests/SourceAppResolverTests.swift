import AppKit
import XCTest
@testable import Browserly

final class SourceAppResolverTests: XCTestCase {
    // macOS reserves keySenderPIDAttr as read-only on real Apple Events.
    private final class SenderEvent: NSAppleEventDescriptor {
        var sender: NSAppleEventDescriptor?

        override func attributeDescriptor(forKeyword keyword: AEKeyword) -> NSAppleEventDescriptor? {
            if keyword == AEKeyword(keySenderPIDAttr) { return sender }
            return super.attributeDescriptor(forKeyword: keyword)
        }
    }

    private func event(sender: NSAppleEventDescriptor? = nil) -> NSAppleEventDescriptor {
        let event = SenderEvent()
        event.sender = sender
        return event
    }

    func testUsesEventSenderForTelegramRouting() {
        let source = SourceAppResolver.bundleIdentifier(from: event(sender: .init(int32: 1234))) { pid in
            XCTAssertEqual(pid, 1234)
            return "ru.keepcoder.Telegram"
        }
        let rule = Rule(id: UUID(), name: "Telegram Links", type: .sourceApp,
                        pattern: "ru.keepcoder.Telegram", targetBrowserId: "safari")
        let result = RoutingEngine().evaluate(url: URL(string: "https://example.com")!,
                                              sourceAppBundleId: source, rules: [rule])
        XCTAssertEqual(result?.browserId, "safari")
        XCTAssertEqual(result?.ruleName, "Telegram Links")
    }

    func testAcceptsUnsignedSenderPIDFromMacOS() {
        var pid: UInt32 = 1234
        let sender = withUnsafeBytes(of: &pid) {
            NSAppleEventDescriptor(descriptorType: DescType(typeUInt32), data: Data($0))!
        }
        XCTAssertEqual(SourceAppResolver.bundleIdentifier(from: event(sender: sender)) { value in
            XCTAssertEqual(value, 1234)
            return "ru.keepcoder.Telegram"
        }, "ru.keepcoder.Telegram")
    }

    func testRejectsUnsignedPIDOutsideSignedProcessIDRange() {
        var pid = UInt32.max
        let sender = withUnsafeBytes(of: &pid) {
            NSAppleEventDescriptor(descriptorType: DescType(typeUInt32), data: Data($0))!
        }
        XCTAssertNil(SourceAppResolver.bundleIdentifier(from: event(sender: sender)) { _ in
            XCTFail("Out-of-range PID must not trigger a process lookup")
            return "com.browserly.app"
        })
    }

    func testMissingEventReturnsUnknownWithoutLookup() {
        XCTAssertNil(SourceAppResolver.bundleIdentifier(from: nil) { _ in
            XCTFail("Missing sender must not trigger a process lookup")
            return "com.browserly.app"
        })
    }

    func testMissingSenderReturnsUnknownWithoutLookup() {
        XCTAssertNil(SourceAppResolver.bundleIdentifier(from: event()) { _ in
            XCTFail("Missing sender must not trigger a process lookup")
            return "com.browserly.app"
        })
    }

    func testInvalidSenderReturnsUnknownWithoutLookup() {
        for sender in [NSAppleEventDescriptor(int32: 0), .init(int32: -1), .init(string: "1234")] {
            XCTAssertNil(SourceAppResolver.bundleIdentifier(from: event(sender: sender)) { _ in
                XCTFail("Invalid sender must not trigger a process lookup")
                return "com.browserly.app"
            })
        }
    }

    func testExitedSenderReturnsUnknown() {
        XCTAssertNil(SourceAppResolver.bundleIdentifier(from: event(sender: .init(int32: 1234))) { _ in nil })
    }

    func testResolvesRunningApplication() {
        let application = NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier != nil }
        guard let application = application else {
            return XCTFail("Expected a running application with a bundle identifier")
        }
        XCTAssertEqual(SourceAppResolver.bundleIdentifier(
            from: event(sender: .init(int32: application.processIdentifier))
        ), application.bundleIdentifier)
    }
}
