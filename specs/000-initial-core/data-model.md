# Data Model: Browserly Initial Core

This document outlines the primary data structures, validation rules, and storage mechanisms for the application.

## 1. Rule
Represents a single routing directive.

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `id` | `UUID` | Unique identifier for the rule. | Yes |
| `name` | `String` | Human-readable name (e.g., "Work GitHub"). | No |
| `type` | `Enum (domain, regex, sourceApp)` | The type of matching strategy. | Yes |
| `pattern` | `String` | The value to match against (e.g., "github.com", "^https?://jira\\.", "com.tinyspeck.slackmacgap"). | Yes |
| `targetBrowserId` | `String` | The ID of the `TargetBrowser` this rule resolves to. | Yes |

**Validation Rules:**
- `pattern` must be a valid regex if `type` is `regex`.
- `targetBrowserId` must correspond to an existing `TargetBrowser`.

## 2. TargetBrowser
Represents an installed browser or a specific profile within a browser.

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `id` | `String` | Unique identifier (e.g., "chrome-work", "safari-default"). | Yes |
| `name` | `String` | Display name (e.g., "Chrome (Work)"). | Yes |
| `bundleId` | `String` | The macOS Bundle Identifier (e.g., "com.google.chrome"). | Yes |
| `profileDirectory` | `String` | Specific profile string (e.g., "Profile 1"). Null for non-Chromium apps. | No |
| `isIncognito` | `Bool` | Whether to launch the browser in incognito mode (Chromium only). | Yes (default: `false`) |

## 3. AppConfiguration
The root object persisted to JSON in `Application Support`.

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `defaultBrowserId` | `String` | The fallback browser ID if no rules match. | Yes |
| `browsers` | `[TargetBrowser]` | Array of defined target browsers. | Yes |
| `rules` | `[Rule]` | Sequential array of routing rules. Evaluated top-to-bottom. | Yes |

**State Transitions:**
- Missing config file -> App generates default `AppConfiguration` on launch, pointing to the system's previous default browser.

## 4. HistoryItem (In-Memory / Optional Persistence)
Represents a recently intercepted URL for the Menu Bar UI.

| Field | Type | Description | Required |
|-------|------|-------------|----------|
| `url` | `URL` | The intercepted URL. | Yes |
| `timestamp` | `Date` | When the interception occurred. | Yes |
| `sourceAppBundleId` | `String` | Bundle ID of the app where the link was clicked (if detected). | No |
| `routedToBrowserId`| `String` | The ID of the browser the routing engine selected. | Yes |

## Global State (`UserDefaults`)
- `isPaused`: `Bool` (Default: `false`). When `true`, routing engine bypasses `rules` and sends all URLs to `defaultBrowserId`.