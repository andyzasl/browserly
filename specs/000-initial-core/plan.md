# Implementation Plan: Browserly Initial Core (MVP)

**Branch**: `000-initial-core` | **Date**: 2026-05-28 | **Spec**: [specs/000-initial-core/spec.md](spec.md)
**Input**: Integrated 4 primary components: URL Handling, Routing Engine, Menu Bar UI, and Browser Integration.

## Summary

Browserly MVP is a macOS menu bar agent that acts as the default system browser to intercept HTTP/HTTPS links. It uses a custom JSON configuration file to sequentially match links (by domain, regex, or source app) and dispatch them to specific third-party browsers (including targeting Chromium profiles). It features a SwiftUI popover menu for quick state management (pause routing) and reviewing recent link history.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: AppKit, SwiftUI, Foundation  
**Storage**: `UserDefaults` (App State), `JSON` via `FileManager` (Configuration)  
**Testing**: XCTest (Unit tests for routing logic and URL processing)  
**Target Platform**: macOS 14+ (Sonoma)  
**Project Type**: Desktop App (MenuBar / Agent / LSUIElement)  
**Performance Goals**: < 50ms UI render, < 500ms routing execution  
**Constraints**: Silent background execution (no Dock icon), native Apple Event handling for URL capture  
**Scale/Scope**: Local single-user desktop application

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Library-First/Modular**: The routing engine, browser detection, and config parsing will be separated from the UI layer to allow independent testing.
- **Test-First**: Routing rules and matching algorithms are deterministic and will be test-driven via XCTest.
- **Simplicity**: No complex databases; using JSON and `UserDefaults` keeps persistence lightweight and debuggable.

## Project Structure

### Documentation (this feature)

```text
specs/000-initial-core/
├── plan.md              # This file
├── research.md          # Technical decisions for URL interception and browser launching
├── data-model.md        # Rule, TargetBrowser, and AppConfig structures
├── quickstart.md        # Guide to running the app
├── contracts/
│   └── config-schema.json # JSON schema contract for the configuration file
└── tasks.md             # Implementation steps (Phase 2 output)
```

### Source Code (repository root)

```text
Browserly/
├── App/
│   ├── BrowserlyApp.swift          # App entry point, MenuBarExtra setup
│   └── AppDelegate.swift           # NSAppleEventManager registration
├── Core/
│   ├── Models/                     # Rule, TargetBrowser, Config structs (Codable)
│   ├── Routing/                    # RoutingEngine, Matchers
│   └── Storage/                    # ConfigManager, HistoryManager
├── System/
│   ├── BrowserDetector.swift       # LSCopyAllHandlersForURLScheme wrapper
│   └── ProcessLauncher.swift       # NSWorkspace and Process execution
├── UI/
│   ├── MenuBar/                    # PopoverView, HistoryRow, BrowserPicker
│   └── Components/                 # Shared UI elements
└── Tests/
    ├── RoutingTests/               # Core routing logic tests
    └── IntegrationTests/           # Config parsing tests
```

**Structure Decision**: A single macOS App project broken down into `Core` (business logic), `System` (macOS APIs), and `UI` (SwiftUI views) to maintain separation of concerns and testability.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| Custom `Process` execution for browsers | Chromium `--profile-directory` support | `NSWorkspace.openApplication` does not support arbitrary CLI flags required for profile targeting. |
