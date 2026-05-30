# AGENTS.md — Browserly

macOS menu bar app (Swift 5.9, SwiftUI + AppKit) that routes URLs to browsers based on user-defined rules. Zero external dependencies, SPM only.

## Commands

| Action | Command |
|---|---|
| Build | `swift build` |
| Build release | `swift build -c release` |
| Run | `swift run Browserly` |
| Run with URL | `swift run Browserly "https://example.com"` |
| Unit tests (requires Xcode) | `swift test` |
| Standalone validation (no Xcode) | `swift Tests/Validate.swift` |
| Performance benchmark | `swift Tests/Performance.swift` |
| Build DMG | `./scripts/build-dmg.sh` |

CI runs: `swift build -c release` → `swift Tests/Validate.swift` → `swift Tests/Performance.swift`. No `swift test` in CI — standalone scripts are the primary gate.

## Architecture

- **Entry point**: `Sources/Browserly/App/BrowserlyApp.swift` — `@main` SwiftUI App with `MenuBarExtra`
- **URL handling**: `AppDelegate.swift` receives system URL events (registered via `Info.plist` as HTTP/HTTPS handler)
- **Routing**: `RoutingEngine.swift` matches URLs against rules (types: `domain`, `regex`, `sourceApp`), returns a target browser ID
- **Config**: `ConfigManager.swift` persists to `~/Library/Application Support/Browserly/config.json`
- **Browser discovery**: `BrowserDetector.swift` finds installed browsers at runtime
- **State**: `AppState.shared` singleton (ObservableObject)

The app is an `LSUIElement` (no Dock icon) — it lives entirely in the menu bar.

## Testing

Two separate test strategies:

1. **Standalone scripts** (`Tests/Validate.swift`, `Tests/Performance.swift`) — self-contained, duplicate model types internally, run with plain `swift` CLI. These are what CI uses.
2. **XCTest** (`Tests/BrowserlyTests/`) — standard SPM test target, requires Xcode. Run with `swift test`.

When adding routing logic tests, update both `Tests/Validate.swift` (standalone) and `Tests/BrowserlyTests/RoutingTests/` (XCTest) to keep them in sync.

## Specs

Feature specs live in `specs/` (managed by speckit). Check existing specs before starting new features.
