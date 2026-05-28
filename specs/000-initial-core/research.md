# Research & Decisions: Browserly Initial Core

## 1. URL Event Interception in SwiftUI (macOS 14+)
- **Decision**: Use `NSApplicationDelegate` with `NSAppleEventManager` mapping for the deepest system-level URL interception, rather than solely relying on SwiftUI's `onOpenURL`.
- **Rationale**: While SwiftUI provides `.onOpenURL`, an app acting as the *default system browser* requires highly reliable, low-level event handling to process URLs sent when the app is in various states (Cold Start vs Warm Start). `NSAppleEventManager` combined with `application(_:openFiles:)` or custom event handlers ensures no URLs are dropped and allows precise timing.
- **Alternatives considered**: Using only SwiftUI's `onOpenURL` modifier (simpler, but potentially less reliable for complex default-browser routing edge cases).

## 2. Browser Discovery
- **Decision**: Use `LSCopyAllHandlersForURLScheme("https" as CFString)` via CoreServices to discover installed browsers.
- **Rationale**: This is the official Apple API for querying URL scheme handlers. It guarantees we find all apps that the system recognizes as capable of opening web links, providing their bundle identifiers (e.g., `com.google.chrome`).
- **Alternatives considered**: Manually checking paths in `/Applications` (brittle, misses user-installed apps in `~/Applications`).

## 3. Launching Browsers with CLI Arguments
- **Decision**: Use `Process` (formerly `NSTask`) for launching Chromium-based browsers with CLI flags like `--profile-directory`, and `NSWorkspace.shared.openApplication` for standard launches.
- **Rationale**: `NSWorkspace` is the idiomatic way to open URLs in specific apps (e.g., Safari or Arc), but it does not natively support passing arbitrary CLI arguments like Chromium profiles. `Process` allows executing the browser binary directly (e.g., `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`) with specific flags.
- **Alternatives considered**: Using AppleScript for everything (slow, requires accessibility permissions, brittle across browser updates).

## 4. Menu Bar App Lifecycle (LSUIElement)
- **Decision**: Configure `LSUIElement` to `YES` in `Info.plist` and use `MenuBarExtra` in SwiftUI for the UI. Use `UserDefaults` for the global "Paused" state.
- **Rationale**: `MenuBarExtra` is the modern, native way to build menu bar items in SwiftUI (macOS 13+), supporting custom views (Popovers) easily. `LSUIElement` ensures the app runs silently without a Dock icon.
- **Alternatives considered**: Using legacy `NSStatusItem` with an `NSPopover` (more boilerplate, less declarative than `MenuBarExtra`).

## 5. Identifying Source Application
- **Decision**: Use `NSWorkspace.shared.frontmostApplication` immediately upon receiving the URL event to heuristically determine the source application.
- **Rationale**: Apple Events do not always reliably include the sender's bundle ID in a sandbox-friendly way. Checking the frontmost app at the moment of capture is the most reliable fallback for identifying where the link was clicked.
- **Alternatives considered**: Attempting to extract the `keyEventSource` from the Apple Event descriptor (often null or restricted).