# Feature Specification: Menu Bar UI/UX Interface

**Feature Branch**: `003-menubar-ui-ux`  
**Created**: 2026-05-28  
**Status**: Draft  
**Input**: User description: "# ЗАПРОС: Спецификация UI/UX интерфейса строки меню (MenuBar App Spec) Контекст: Приложение работает как агент в фоне (LSUIElement = UIElement в Info.plist) и управляется через иконку в менюбаре. Задача: Разработать спецификацию интерфейса на SwiftUI. Требования к спецификации: 1. Элементы StatusBar Item: Иконка приложения, динамически меняющая цвет/состояние (активно/выключено). 2. Выпадающее меню (Popover / NSMenu): - Быстрое переключение «Главного рабочего браузера» и «Главного личного браузера». - Список последних 5 перенаправленных ссылок (Log/History) с возможностью переоткрыть их в другом браузере вручную. - Кнопка «Поставить на паузу» (когда все ссылки временно идут в один браузер). - Кнопка перехода в Настройки и Выход. 3. Производительность: Описать требования к отзывчивости интерфейса (время рендеринга меню при клике < 50мс). Выходной формат: UI Component Specification (Спецификация компонентов интерфейса)."

## Clarifications

### Session 2026-05-28
- Q: Which interaction pattern should be used for the Menu Bar interface (Popover vs. NSMenu)? → A: SwiftUI Popover (Rich custom view, stays open during multiple interactions).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Quick Browser Switching (Priority: P1)

As a user, I want to quickly change my primary Work or Personal browser from the menu bar, so that I can adapt to different browsing needs without opening a full settings window.

**Why this priority**: Core interaction for a browser routing tool.
**Independent Test**: Click the menu bar icon, select a different browser from the dropdown. Verify that subsequent links open in the newly selected browser.

**Acceptance Scenarios**:
1. **Given** the app is running in the menu bar, **When** I click the icon, **Then** I see the current Work and Personal browser selections.
2. **Given** the menu is open, **When** I select a new Work browser, **Then** the selection is updated and persisted.

---

### User Story 2 - Managing Recent History (Priority: P2)

As a user, I want to see the last few links that were redirected, so that I can manually re-open them in a different browser if the automatic routing wasn't what I wanted.

**Why this priority**: Provides a safety net for routing mistakes and quick access to recent links.
**Independent Test**: Open several links, click the menu bar icon. Verify the last 5 links appear in the history section.

**Acceptance Scenarios**:
1. **Given** links have been redirected, **When** I open the menu, **Then** I see up to 5 of the most recent links.
2. **Given** the history list, **When** I click a "re-open in..." option for a specific link, **Then** that link opens in the selected browser.

---

### User Story 3 - Pausing Redirection (Priority: P2)

As a user, I want to temporarily disable all routing rules and send all links to a single browser, so that I can focus on one context without interruptions.

**Why this priority**: Essential for "deep work" or temporary exceptions to routing logic.
**Independent Test**: Toggle the "Pause" button. Verify that all links now open in the designated "Personal" browser regardless of rules.

**Acceptance Scenarios**:
1. **Given** the app is active, **When** I click "Pause", **Then** the status bar icon changes color to indicate a disabled/paused state.
2. **Given** the app is paused, **When** I click a "Work" link, **Then** it opens in the "Personal" browser (or the designated fallback).

---

### Edge Cases

- **Empty History**: How does the menu look when no links have been opened yet? (Assumption: History section is hidden or shows "No recent activity").
- **Menu Overlap**: How does the popover behave if the menu bar is crowded? (Assumption: Standard macOS behavior handles placement).
- **Update Frequency**: How often does the history list refresh? (Assumption: Real-time update upon link capture).

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST provide a status bar item that reflects the current operational state (Active/Paused) through visual cues.
- **FR-002**: The system MUST display a popover menu upon clicking the status bar item.
- **FR-003**: The menu MUST allow the user to select the primary application for "Work" and "Personal" contexts from a list of installed browsers.
- **FR-004**: The menu MUST display a history of the last 5 intercepted URLs.
- **FR-005**: For each item in the history, the system MUST provide options to re-open that URL once in any of the available browsers (manual one-time override).
- **FR-006**: The system MUST provide a toggle to "Pause" all routing rules.
- **FR-007**: When "Paused", all incoming URLs MUST be routed to the designated fallback browser.
- **FR-008**: The menu MUST include links to the "Settings" window and a "Quit" option.

### UI Components

- **Status Bar Item**: Dynamic icon using symbol variants or color shifts to indicate active vs. paused states (e.g., system accent for active, monochrome for paused).
- **Custom Popover**: A SwiftUI-based view container hosting the interactive controls.
- **Browser Selector**: Interactive picker or list within the popover for Work/Personal targets.
- **History List**: A list of 5 interactive items with secondary "Open in..." actions.
- **Pause Toggle**: A prominent toggle button with clear state labels.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The menu renders and becomes interactive in under 50ms after a click event.
- **SC-002**: The status bar icon updates its visual state within 100ms of a state change (e.g., toggling Pause).
- **SC-003**: 100% of the last 5 URLs are accurately tracked and displayed in the history section.

## Assumptions

- **Aesthetics**: The UI will follow standard macOS system aesthetics (Standard popover styling, system fonts).
- **Visibility**: The app will not appear in the Dock (LSUIElement set to true).
- **Interactivity**: Clicking a history item will open it in the *original* target browser by default, with a sub-menu for alternatives.
- **Interaction Model**: The popover remains visible until the user clicks outside or manually closes it, facilitating multiple quick configuration changes.
- **Platform**: The interface is built using SwiftUI for modern macOS (14+).
m**: The interface is built using SwiftUI for modern macOS (14+).
n macOS (14+).
