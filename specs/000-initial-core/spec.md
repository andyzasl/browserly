# Feature Specification: Browserly Initial Core (MVP)

**Feature Branch**: `000-initial-core`  
**Created**: 2026-05-28  
**Status**: Unified  
**Input**: Integrated 4 primary components: URL Handling, Routing Engine, Menu Bar UI, and Browser Integration.

## Clarifications

### Session 2026-05-28
- Q: Which file format should be used for storing the unified application configuration? → A: Human-readable text format (JSON) that easily supports regex strings and manual editing.
- Q: How should the application manage and persist the global "Paused" state? → A: Store in `UserDefaults` (Standard for simple boolean flags).
- Q: On first launch, if no config exists, should the app generate a default file? → A: Automatically generate a default configuration file on first launch.

## Overview
This specification consolidates the four foundational pillars of the Browserly application into a single development target for the MVP (Minimum Viable Product). The goal is to deliver a functional "silent agent" that intercepts system-wide links and routes them based on user-defined rules.

### Consolidated Components
1.  **URL Interception** ([spec](../001-macos-url-handler/spec.md)): Registration as default browser and capturing HTTP/HTTPS events.
2.  **Routing Engine** ([spec](../002-routing-engine/spec.md)): Logic for matching links against sequential rules (Domain, Regex, Source App).
3.  **Browser Integration** ([spec](../004-browser-profile-integration/spec.md)): Dispatching URLs to specific browser profiles (Chrome, Brave, etc.) and handling fallbacks.
4.  **Menu Bar UI** ([spec](../003-menubar-ui-ux/spec.md)): A SwiftUI popover for quick state management, browser switching, and history.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Full Loop: Intercept to Route (Priority: P1)
As a user, when I click a GitHub link in Slack, I want the link to automatically open in my "Work" Chrome profile without any manual intervention.

**Independent Test**:
1. Configure rule: Slack -> GitHub -> Work Chrome.
2. Click link in Slack.
3. Verify Work Chrome opens the URL.

### User Story 2 - Manual Override via UI (Priority: P1)
As a user, if a link opens in the wrong browser, I want to click the menu bar icon and re-open it in my "Personal" browser from the history list.

**Independent Test**:
1. Intercept a link.
2. Open Menu Bar UI.
3. Click "Open in Personal" for the history item.
4. Verify link opens in Personal browser.

## Requirements *(mandatory)*

### Functional Requirements
- **FR-CORE-001**: System MUST register as the default browser for `http` and `https`.
- **FR-CORE-002**: System MUST process incoming URLs through a sequential matching engine.
- **FR-CORE-003**: System MUST identify the "Source Application" for all incoming URL events.
- **FR-CORE-004**: System MUST launch third-party browsers using CLI profile flags.
- **FR-CORE-005**: System MUST maintain a persistent UI in the macOS menu bar using SwiftUI.
- **FR-CORE-006**: System MUST persist configuration (Rules/Browsers) in `Application Support` using a human-readable text format (JSON) to facilitate manual editing and regex support.
- **FR-CORE-007**: System MUST persist simple global states (e.g., "Paused" status) using `UserDefaults` to ensure separation from routing logic.

## Success Criteria *(mandatory)*
- **SC-CORE-001**: Total time from link click to browser launch is under 500ms.
- **SC-CORE-002**: 100% of URLs are correctly identified by source application.
- **SC-CORE-003**: UI remains responsive (50ms rendering) during background link processing.

## Assumptions
- Target platform is macOS 14+.
- Core browser targets for MVP are Chrome, Brave, and Safari (standard).
- Rules are processed strictly in top-to-bottom order from the configuration file.
- **First Launch**: The system will automatically generate a default JSON configuration file if one is not found in `Application Support` upon startup.
