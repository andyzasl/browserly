# Browserly

Browserly is a smart browser router for macOS. It intercepts URLs and opens them in the appropriate browser based on rules you define.

## Configuration

Browserly stores its configuration in a JSON file.

### Config File Location

The configuration file is located at:
`~/Library/Application Support/Browserly/config.json`

### Configuration Structure

The configuration consists of three main parts:
1. `defaultBrowserId`: The ID of the browser to use when no rules match.
2. `browsers`: A list of browsers installed on your system.
3. `rules`: Logic to route URLs to specific browsers.

### Example Configuration

```json
{
  "defaultBrowserId": "com-apple-safari",
  "browsers": [
    {
      "id": "com-apple-safari",
      "name": "Safari",
      "bundleId": "com.apple.Safari",
      "isIncognito": false
    },
    {
      "id": "google-chrome",
      "name": "Chrome",
      "bundleId": "com.google.Chrome",
      "isIncognito": false
    },
    {
      "id": "chrome-work",
      "name": "Chrome (Work Profile)",
      "bundleId": "com.google.Chrome",
      "profileDirectory": "Profile 1",
      "isIncognito": false
    }
  ],
  "rules": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Work Domain",
      "type": "domain",
      "pattern": "github.com",
      "targetBrowserId": "chrome-work"
    },
    {
      "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "name": "Social Media (Regex)",
      "type": "regex",
      "pattern": ".*(twitter|facebook|instagram)\\.com",
      "targetBrowserId": "com-apple-safari"
    },
    {
      "id": "7da7b810-9dad-11d1-80b4-00c04fd430c9",
      "name": "Slack Links",
      "type": "sourceApp",
      "pattern": "com.tinyspeck.slackmacgap",
      "targetBrowserId": "chrome-work"
    }
  ]
}
```

### Rule Types

- **domain**: Matches the hostname of the URL (e.g., `google.com`).
- **regex**: Uses a regular expression to match against the full URL.
- **sourceApp**: Matches against the Bundle Identifier of the application that sent the URL (e.g., `com.tinyspeck.slackmacgap` for Slack).

### Browser Options

- `profileDirectory`: (Optional) Specify a profile folder name for Chromium-based browsers (Chrome, Edge, Brave).
- `isIncognito`: Set to `true` to open the URL in a private/incognito window.

## Testing without changing System Default

The easiest way to test Browserly's routing logic is to pass a URL directly to the app via `swift run`. This simulates an interception without needing any installation or registration:

```bash
# Replace 'google.com' with the URL you want to test
swift run Browserly "https://google.com"
```

The app will start, process the URL based on your rules, launch the appropriate browser, and then remain active in your menu bar.

### Manual Injection (While App is Running)
If the app is already running, you can send a test URL using the macOS `open` command:

### Standalone Validation (No Xcode required)

If you are in an environment without a full Xcode installation (e.g., using only Command Line Tools), you can run a standalone validation of the routing logic:

```bash
swift Tests/Validate.swift
```

## Usage

1. Open Browserly.
2. Click the "Set Default" button in the menu bar popover to register Browserly as your system's default browser.
3. Edit `~/Library/Application Support/Browserly/config.json` to customize your routing rules.
4. Restart Browserly to apply changes (or wait for the next URL intercept).
