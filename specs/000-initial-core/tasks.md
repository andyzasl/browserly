# Implementation Tasks: Browserly Initial Core (MVP)

**Feature Branch**: `000-initial-core`
**Context**: This task list covers the MVP for the Browserly macOS application, handling URL interception, routing, and browser integration.

## Implementation Strategy
We will build the application from the inside out: starting with data models, then the core routing and system integration services (foundational tasks), followed by wiring up the URL interception loop (User Story 1), and finally building the Menu Bar UI for manual overrides (User Story 2). This allows components to be tested independently before the UI is attached.

## Dependencies
- **Phase 1** must complete first.
- **Phase 2** (Models, Storage, System integrations) blocks Phase 3.
- **Phase 3** (Interception & Routing) blocks Phase 4.
- **Phase 4** (Menu Bar UI) provides the user-facing controls.

## Parallel Execution Examples
- **Phase 2**: `RoutingEngine` (T007) and `BrowserDetector` (T008) can be built in parallel.
- **Phase 3**: `NSAppleEventManager` logic (T011) and `ProcessLauncher` (T012) can be implemented simultaneously.

---

## Phase 1: Setup & Infrastructure
**Goal**: Initialize the macOS Xcode project and directory structure.

- [x] T001 Initialize macOS SwiftUI App project named "Browserly" in the repository root.
- [x] T002 Modify `Browserly/Info.plist` to set `LSUIElement` to `YES` (Application is agent).
- [x] T003 Create directory structure: `Core/Models`, `Core/Routing`, `Core/Storage`, `System`, `UI/MenuBar`, `UI/Components` inside `Browserly/`.
- [x] T004 Add default `http` and `https` URL scheme definitions to `Browserly/Info.plist` (CFBundleURLTypes).

## Phase 2: Foundational Components
**Goal**: Build the data models, configuration storage, and core utility classes that all stories depend on.

- [ ] T005 [P] Create `Rule`, `TargetBrowser`, and `AppConfiguration` Codable structs in `Browserly/Core/Models/ConfigurationModels.swift`.
- [ ] T006 [P] Implement `ConfigManager` to load/save JSON from `Application Support` and generate defaults in `Browserly/Core/Storage/ConfigManager.swift`.
- [ ] T007 [P] Implement `RoutingEngine` with domain, regex, and source app matching logic in `Browserly/Core/Routing/RoutingEngine.swift`.
- [ ] T008 [P] Implement `BrowserDetector` using `LSCopyAllHandlersForURLScheme` in `Browserly/System/BrowserDetector.swift`.
- [ ] T009 [P] Create `HistoryItem` struct and `HistoryManager` class for in-memory recent links in `Browserly/Core/Storage/HistoryManager.swift`.

## Phase 3: [US1] Full Loop: Intercept to Route
**Goal**: Intercept URLs, identify the source app, evaluate rules, and launch the correct external browser profile.
**Independent Test**: Verify a clicked link opens in the correct Chrome profile based on a JSON config without needing the Menu Bar UI.

- [ ] T010 [US1] Write unit tests for `RoutingEngine` matching scenarios in `BrowserlyTests/RoutingTests/RoutingEngineTests.swift`.
- [ ] T011 [US1] Implement `AppDelegate` with `NSAppleEventManager` to intercept URLs and capture `NSWorkspace.shared.frontmostApplication` in `Browserly/App/AppDelegate.swift`.
- [ ] T012 [US1] Implement `ProcessLauncher` to handle Chromium CLI arguments (`--profile-directory`, `--incognito`) and standard `NSWorkspace` launches in `Browserly/System/ProcessLauncher.swift`.
- [ ] T013 [US1] Connect `AppDelegate` to `RoutingEngine` and `ProcessLauncher` to complete the interception-to-launch loop in `Browserly/App/AppDelegate.swift`.
- [ ] T014 [US1] Add logic to `AppDelegate` to record successfully dispatched URLs to `HistoryManager`.

## Phase 4: [US2] Manual Override via UI
**Goal**: Build the Menu Bar Popover to view history, pause routing, and quickly switch target browsers.
**Independent Test**: Click the Menu Bar icon, view captured history, and manually route a link to a different browser.

- [ ] T015 [P] [US2] Create global `UserDefaults` manager for the `isPaused` state in `Browserly/Core/Storage/AppState.swift`.
- [ ] T016 [US2] Create `HistoryRow` and `BrowserPicker` SwiftUI components in `Browserly/UI/Components/`.
- [ ] T017 [US2] Build the main `PopoverView` combining the Pause toggle, Browser Picker, and History List in `Browserly/UI/MenuBar/PopoverView.swift`.
- [ ] T018 [US2] Wire `PopoverView` "Open In..." actions to the `ProcessLauncher` bypassing the `RoutingEngine` in `Browserly/UI/MenuBar/PopoverView.swift`.
- [ ] T019 [US2] Update `BrowserlyApp.swift` to use `MenuBarExtra` and display the `PopoverView` (handling active/paused icon states).
- [ ] T020 [US2] Update `AppDelegate` URL interception logic to respect the `AppState.isPaused` flag (fallback to default browser).

## Phase 5: Polish & Cross-Cutting
**Goal**: Ensure error handling, startup validation, and system integration are solid.

- [ ] T021 Implement startup validation in `ConfigManager` to block launch with a fatal error dialog if JSON is corrupt in `Browserly/Core/Storage/ConfigManager.swift`.
- [ ] T022 Ensure graceful fallback in `ProcessLauncher` if the target `bundleId` or profile is missing (route to default system browser) in `Browserly/System/ProcessLauncher.swift`.
- [ ] T023 Add a setup button in the `PopoverView` that triggers the macOS system dialog to become the default browser using `LSSetDefaultHandlerForURLScheme`.