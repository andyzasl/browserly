# browserly Development Guidelines

Auto-generated from all feature plans. Last updated: 2026-06-01

## Active Technologies
- Swift 5.9+ + Foundation (005-url-redirect-decoder)
- N/A (Hardcoded list for v1) (005-url-redirect-decoder)

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
- 005-url-redirect-decoder: Added Swift 5.9+ + Foundation

- 000-initial-core: Added Swift 5.9+ + AppKit, SwiftUI, Foundation
- 004-browser-profile-integration: Implemented dynamic browser detection on startup and configuration persistence.

<!-- MANUAL ADDITIONS START -->
## URL Redirector Decoding

Browserly includes a pre-routing step that extracts target URLs from known enterprise redirectors. This ensures that a link like `https://statics.teams.cdn.office.net/.../?url=https://github.com` is correctly evaluated as `github.com` by your rules.

### Supported Redirectors (v1)
- **Microsoft Teams**: `statics.teams.cdn.office.net`
- **Microsoft Outlook**: `*.safelinks.protection.outlook.com`
- **Proofpoint**: `urldefense.proofpoint.com` (supports v2 custom encoding)
- **Slack**: `slack-redir.net`

The decoding logic is implemented in `URLRedirectDecoder.swift` and supports recursive decoding (up to 3 levels) for nested wrappers.
<!-- MANUAL ADDITIONS END -->
