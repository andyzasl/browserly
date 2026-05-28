# Feature Specification: Third-Party Browser Integration

**Feature Branch**: `004-browser-profile-integration`  
**Created**: 2026-05-28  
**Status**: Draft  
**Input**: User description: "# ЗАПРОС: Спецификация интеграции со сторонними браузерами (Browser Profiles Integration) Контекст: Приложению необходимо передавать URL в конкретные профили Google Chrome, Brave, Arc или открывать приватные вкладки в Safari. Задача: Описать техническую реализацию запуска браузеров с аргументами. Требования к спецификации: 1. Сбор информации: Как приложение определяет список установленных в системе браузеров (использование LSCopyAllHandlersForURLScheme). 2. Запуск через CLI аргументы: Описать команды запуска для: - Google Chrome / Brave с флагом --profile-directory="Profile 1". - Safari (обычное открытие vs Private Mode через AppleScript). - Arc Browser (открытие в конкретном Space, если поддерживается API). 3. Обработка ошибок: Что делать, если целевой браузер удален или профиль не найден (логика фолбека на системный браузер по умолчанию). Выходной формат: Integration Spec (Спецификация интеграции API/CLI)."

## Clarifications

### Session 2026-05-28
- Q: Should the app automatically discover Chromium profiles or require manual entry? → A: Automatic Discovery (Scan local state files to list profile names/IDs).
- Q: How should we adjust the support for private browsing in the MVP given the strategy change for Safari? → A: Remove Safari Private Mode from MVP scope.
- Q: For Arc Browser integration, should the app support specific Space selection or just open in the active window? → A: Open in currently active Arc window/space (Standard behavior).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Multi-Profile Routing (Priority: P1)

As a developer using multiple Chrome profiles, I want links to open in the correct profile automatically, so that I don't have to manually switch accounts after a link opens.

**Why this priority**: Core value proposition for power users who use browser profiles to separate work and personal accounts.
**Independent Test**: Configure a rule to open `github.com` in Chrome "Profile 1". Click a GitHub link. Verify that Chrome opens specifically with "Profile 1".

**Acceptance Scenarios**:
1. **Given** a rule targets a specific browser profile, **When** a matching link is captured, **Then** the browser launches using the exact profile directory specified.

---

### User Story 2 - Privacy Mode Redirection (Priority: P2)

As a privacy-conscious user, I want specific links (e.g., banking or health sites) to always open in an incognito window in my Chromium-based browser, so that no history is tracked.

**Why this priority**: Enhances security and privacy for sensitive links.
**Independent Test**: Configure a rule for `mybank.com` to open in "Chrome Incognito". Click the link. Verify a new incognito window opens in Chrome.

**Acceptance Scenarios**:
1. **Given** a rule targets "Incognito Mode", **When** the link is opened in a supported Chromium browser, **Then** the browser opens the link in a new Incognito window.

---

### User Story 3 - Missing Browser Fallback (Priority: P1)

As a user, if I have configured a rule for a browser I recently uninstalled, I want the app to handle this gracefully by opening the link in my default browser instead of doing nothing.

**Why this priority**: Reliability is critical; links must never "disappear" or fail to open.
**Independent Test**: Configure a rule for a non-existent browser. Click a matching link. Verify it opens in the system's default browser.

**Acceptance Scenarios**:
1. **Given** a rule targets a browser that is not installed or available, **When** a link is clicked, **Then** the system automatically falls back to the "Personal" or system-default browser.

---

### Edge Cases

- **Profile Not Found**: What if Chrome is installed but the specific "Profile 1" directory has been renamed or deleted? (Assumption: Open in the default Chrome profile or fallback to system default).
- **App Store vs. Direct Safari**: How does the system handle default browser opening if Safari is the target but restricted? (Assumption: Use standard system services).
- **Arc Browser Spaces**: How does the system handle "Spaces" if the Arc API is unavailable? (Assumption: Fallback to the last active space).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST detect all applications capable of handling web links (`http`/`https`) and automatically discover available user profiles for supported browsers (e.g., Chrome, Brave).
- **FR-002**: The system MUST support launching external browsers with specific command-line arguments to select user profiles.
- **FR-003**: The system MUST support Chromium-based browsers (Chrome, Brave) via profile directory flags.
- **FR-004**: The system MUST support triggering incognito modes for supported Chromium-based browsers (Chrome, Brave).
- **FR-005**: The system MUST verify the existence of a target browser before attempting to dispatch a URL.
- **FR-006**: The system MUST implement a fallback mechanism that uses the primary system browser if a specific target is unavailable.

### Integration Patterns

- **Chromium Pattern**: Use `--profile-directory` and `--incognito` arguments.
- **Safari Pattern**: Use standard URL opening (Private mode not supported in MVP).
- **Arc Pattern**: Use available application-specific commands or APIs for space/profile selection.

### Key Entities

- **Browser Profile**: An identifier for a specific set of user data and settings within a browser application.
- **Launch Command**: The sequence of application path, arguments, and URL required to open a link in a specific context.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Detection of installed browsers completes in under 1s.
- **SC-002**: Successful launch of a specific profile occurs in 100% of cases where the profile exists.
- **SC-003**: Fallback to default browser happens within 200ms if the primary target is missing.

## Assumptions

- **Path Resolution**: The system can locate browser binaries using standard macOS metadata services.
- **Argument Compatibility**: Chromium browsers maintain backward compatibility for the `--profile-directory` and `--incognito` flags.
- **Automation Access**: No specialized "Automation" or "Accessibility" permissions are required for the MVP as scripting-based browser control is out of scope.
