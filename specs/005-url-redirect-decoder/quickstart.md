# Quickstart: URL Redirector Decoding

## Overview

This module allows Browserly to "see through" URL wrappers used by enterprise security tools like Microsoft Teams Safelinks. This ensures that your browser routing rules are applied to the *final* destination of a link.

## Usage in Code

To decode a URL:

```swift
let originalURL = URL(string: "https://statics.teams.cdn.office.net/evergreen-assets/safelinks/2/atp-safelinks.html?url=https%3A%2F%2Fgithub.com")!
let decodedURL = URLRedirectDecoder.shared.decode(originalURL)
// decodedURL is now https://github.com
```

## Integrating with Routing Engine

The `RoutingEngine` now automatically calls the decoder before evaluating rules:

```swift
let engine = RoutingEngine()
let result = engine.evaluate(url: incomingURL, sourceAppBundleId: "com.microsoft.teams", rules: userRules)
// result will be based on the decoded target URL
```

## Adding New Redirectors (Development)

Currently, redirectors are defined in `URLRedirectDecoder.swift`'s `defaultRules` static property. To add a new one:

1. Open `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`.
2. Add a new `RedirectorRule` to the `defaultRules` array.
3. Add a test case in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`.
