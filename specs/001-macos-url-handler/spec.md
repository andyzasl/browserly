# Feature Specification: macOS URL Scheme Handling

**Feature Branch**: `001-macos-url-handler`  
**Created**: 2026-05-28  
**Status**: Draft  
**Input**: User description: "# ЗАПРОС: Спецификация перехвата URL-схем (HTTP/HTTPS) в macOS Контекст: Разработка нативного аналога Finicky на Swift/SwiftUI для macOS 14+. Задача: Подготовить техническую спецификацию для регистрации приложения в ОС в качестве обработчика URL по умолчанию. Требования к спецификации: 1. Описать конфигурацию Info.plist (параметры CFBundleURLTypes и LSHandlerRank). 2. Описать архитектуру синглтона URLManager, обрабатывающего события NSAppleEventManager (или современный NSApplicationDelegate метод application(_:open:)). 3. Описать логику проверки: является ли наше приложение браузером по умолчанию в системе на данный момент, и механизм вызова системного диалога для его назначения. 4. Предусмотреть обработку ссылок, пришедших во время того, как приложение было закрыто (Cold Start), и когда оно уже запущено в фоне (Warm Start). Выходной формат: Архитектурный документ (Architecture Spec) with examples in Swift."

## Clarifications

### Session 2026-05-28
- Q: How should the application behave if the user cancels or declines the system dialog to become the default browser? → A: Allow app use but show a persistent warning/banner in the UI.
- Q: Should the application also register as a handler for other standard web-related schemes, or strictly limit its scope to HTTP/HTTPS for the MVP? → A: Strictly HTTP and HTTPS for MVP.
- Q: If another application is already the default handler, should the app explicitly name that application in its warning banner, or simply state that "Browserly is not the default browser"? → A: Simply state "Browserly is not the default browser".

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Initial Setup as Default Browser (Priority: P1)

As a new user, I want the application to detect if it is the default browser and help me set it as default, so that my links are intercepted by the app.

**Why this priority**: Without being the default handler, the app cannot perform its primary function of intercepting system-wide links.

**Independent Test**: Can be tested by launching the app for the first time on a system where another browser is default. The app should correctly identify the status and offer to change it.

**Acceptance Scenarios**:

1. **Given** the app is not the default handler for HTTP, **When** the app launches, **Then** it displays a prompt or status indicator suggesting the user set it as default.
2. **Given** the user clicks "Set as Default", **When** the system dialog appears, **Then** confirming the choice makes the app the default handler for both HTTP and HTTPS.
3. **Given** the system dialog is displayed, **When** the user cancels or declines, **Then** the app remains usable but displays a persistent warning banner explaining that link interception is inactive.

---

### User Story 2 - Intercepting External Links (Priority: P1)

As a user, I want clicking a link in any external application (Slack, Mail, Terminal) to open in this app, so that it can be routed according to my rules.

**Why this priority**: This is the core functionality of the application.

**Independent Test**: Can be tested by clicking a link in a third-party app while this app is running.

**Acceptance Scenarios**:

1. **Given** the app is the default browser and is already running, **When** I click a link in Slack, **Then** the app receives the URL and processes it (Warm Start).
2. **Given** the app is the default browser and is CLOSED, **When** I click a link in Slack, **Then** macOS launches the app and the app receives the URL immediately after launch (Cold Start).

---

### Edge Cases

- **Cold Start Delay**: What happens if the app takes too long to initialize? The URL event must be queued and handled as soon as the manager is ready.
- **Multiple URL Events**: How does the system handle multiple URLs clicked in rapid succession?
- **Invalid URL Formats**: How does the system handle malformed or non-HTTP/HTTPS URLs that might be passed?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST register as a handler for `http` and `https` URL schemes in the application metadata.
- **FR-002**: The system MUST specify its relationship to URL schemes using a handler rank to ensure it is considered for default browser status.
- **FR-003**: The system MUST implement a centralized `URLManager` to capture and dispatch incoming URL events.
- **FR-004**: The system MUST support capturing URL events via the operating system's event-dispatching mechanism.
- **FR-005**: The system MUST handle URLs passed during the application launch sequence (Cold Start).
- **FR-006**: The system MUST provide a programmatic way to check if the current application is the default handler for a given scheme.
- **FR-007**: The system MUST be able to trigger the macOS system prompt to become the default browser.
- **FR-008**: The system MUST display a persistent warning in the user interface whenever the application is not the default handler for HTTP/HTTPS schemes.

### Key Entities

- **Incoming URL Event**: Represents a single URL capture event, containing the raw URL and source information.
- **Handler Configuration**: The static registration data required by macOS to recognize the app as a potential browser.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of URLs clicked in external apps are captured by the `URLManager` when the app is the default browser.
- **SC-002**: The delay between clicking a link and the app receiving the URL is under 100ms for Warm Starts.
- **SC-003**: The application correctly identifies its "Default Browser" status with 100% accuracy on launch.

## Assumptions

- **Target OS**: The specification assumes macOS 14 (Sonoma) or newer, utilizing modern Swift and SwiftUI patterns.
- **System Behavior**: It is assumed that macOS will follow standard `LSSetDefaultHandlerForURLScheme` or equivalent modern behaviors for browser selection.
- **Scope**: This spec covers *interception* only; the subsequent *routing* or *opening* in other browsers is part of a separate rule-engine specification.
