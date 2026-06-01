# Feature Specification: Decode URL Redirectors

**Feature Branch**: `005-url-redirect-decoder`  
**Created**: June 1, 2026  
**Status**: Draft  
**Input**: User description: "I need you to support decoding url redirectors with target URL encoded in URL. Like https://statics.teams.cdn.office.net/evergreen-assets/safelinks/2/atp-safelinks.html, and others known"

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Decode Safelinks (Priority: P1)

As a user clicking on a protected link (like Microsoft Teams Safelinks), I want the application to extract and process the actual target URL rather than the wrapper URL, so that my browser routing rules apply correctly to the final destination.

**Why this priority**: Core request of the feature, ensuring routing rules work correctly for URLs hidden behind known enterprise redirectors.

**Independent Test**: Can be fully tested by providing a Safelink URL to the application and verifying that the final target URL is opened in the correct browser profile according to existing rules.

**Acceptance Scenarios**:

1. **Given** a URL wrapper like `https://statics.teams.cdn.office.net/evergreen-assets/safelinks/2/atp-safelinks.html?url=https%3A%2F%2Fexample.com`, **When** the application receives this URL, **Then** it decodes the payload and routes `https://example.com`.
2. **Given** a URL that is not a known redirector, **When** the application receives it, **Then** it processes the original URL without modification.

---

### User Story 2 - Extensible Redirector Decoding (Priority: P2)

As a system administrator, I want to define or extend the list of known redirectors, so that new or custom URL wrappers can be decoded without requiring an application update.

**Why this priority**: Users will encounter various URL wrappers (Proofpoint, etc.) beyond just Safelinks. Extensibility ensures long-term viability.

**Independent Test**: Can be tested by adding a custom redirector rule to the configuration and verifying that matching URLs are correctly decoded.

**Acceptance Scenarios**:

1. **Given** a newly configured redirector rule for `defense.proofpoint.com`, **When** a matching wrapped URL is received, **Then** the application decodes it using the configured pattern.

### Edge Cases

- What happens when a known redirector URL does not contain the expected target URL parameter?
- How does the system handle multiple nested URL encodings (e.g., doubly encoded target URLs)?
- What happens if the decoded target URL is malformed or invalid?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST identify known URL redirectors before routing rules are evaluated.
- **FR-002**: System MUST extract the embedded target URL from known redirectors.
- **FR-003**: System MUST fully decode (URL-decode) the extracted target URL if it is encoded.
- **FR-004**: System MUST evaluate existing routing rules against the extracted, decoded target URL.
- **FR-005**: System MUST fall back to routing the original URL if extraction fails or the target URL parameter is missing.
- **FR-006**: System MUST include a predefined, hardcoded list of common redirectors for v1 (e.g., Microsoft Teams Safelinks).

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: 100% of tested valid Microsoft Teams Safelinks are correctly decoded to their target URLs.
- **SC-002**: Application startup or routing performance is not degraded by more than 5ms when processing URLs.
- **SC-003**: If a decoded URL is invalid, the system gracefully falls back or errors out without crashing.

## Assumptions

- Redirector payload parameters are standard URL query parameters that can be extracted via standard URL parsing.
- The decoded URL is the intended final destination for routing purposes.
- For v1, the application will ship with a predefined list of common redirectors (e.g., Safelinks), even if extensibility is supported.