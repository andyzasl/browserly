# browserly Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-05-29

## Active Technologies

- Swift 5.9+ + AppKit, SwiftUI, Foundation (000-initial-core)
- Universal Binary Architecture (arm64 + x86_64 support)
- Native Dark Mode Support

## Project Structure

```text
Sources/Browserly/   - Main application source code
Tests/BrowserlyTests/ - Unit and integration tests
```

## Commands

- Build: `swift build`
- Run: `swift run Browserly`
- Test (Xcode required): `swift test`
- Test (CLI Only): `swift Tests/Validate.swift`
- Lint (if installed): `swiftlint`

## Code Style

Swift 5.9+: Follow standard Ray Wenderlich/Apple conventions. Use trailing closures where appropriate. Prefer SwiftUI for UI components.

## Recent Changes

- 000-initial-core: Added Swift 5.9+ + AppKit, SwiftUI, Foundation
- 004-browser-profile-integration: Implemented dynamic browser detection on startup and configuration persistence.
- Incognito & History: Added robust incognito mode launching and persistent link history with full test coverage.
- Build System: Switched to **Universal Binary** builds (Apple Silicon + Intel support) and resolved SPM resource warnings.
- CI/CD: Automated GitHub Actions with native UI test reporting and manual CodeQL scanning.
- Documentation: Updated README and GEMINI.md with new architectural features.

<!-- MANUAL ADDITIONS START -->
<!-- MANUAL ADDITIONS END -->
