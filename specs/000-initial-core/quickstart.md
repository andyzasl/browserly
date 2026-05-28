# Browserly MVP - Quickstart

This document provides instructions for developers to run and test the Browserly macOS application.

## Prerequisites

- macOS 14.0 (Sonoma) or later.
- Xcode 15+ (Swift 5.9+).
- At least one external browser installed (e.g., Chrome, Safari) for testing routing.

## Setup & Running

1. Open `Browserly.xcodeproj` in Xcode.
2. Select the `Browserly` target and a local Mac destination.
3. Build and Run (`Cmd + R`).

### Initial Behavior
- Because `LSUIElement` is enabled, no icon will appear in the Dock.
- Look for the Browserly icon in the macOS Menu Bar.
- On first launch, the app will generate a default configuration file in `~/Library/Application Support/Browserly/config.json`.

## Testing URL Interception

1. Set Browserly as the default system browser:
   - macOS Settings > Desktop & Dock > Default web browser -> Select "Browserly".
   - Alternatively, use the prompt inside the Browserly Menu Bar UI if implemented.
2. Open a text editor (like Notes) or a chat app (like Slack).
3. Type a URL (e.g., `https://example.com`) and click it.
4. Browserly will intercept the URL, evaluate the rules in `config.json`, and dispatch it to the target browser.

## Editing Rules

1. Locate the configuration file: `~/Library/Application Support/Browserly/config.json`.
2. Open it in any text editor.
3. Modify the `rules` array. For example:
   ```json
   {
     "id": "1234-...",
     "type": "domain",
     "pattern": "github.com",
     "targetBrowserId": "my-chrome-work-profile"
   }
   ```
4. Save the file. The changes will be loaded by the Routing Engine.

## Testing Profiles
To test Chromium profiles, ensure you have Chrome installed with multiple profiles. The `profileDirectory` in the config maps to the physical folder name in Chrome's application support directory (e.g., `"Profile 1"`, `"Default"`).
