# Tasks: Decode URL Redirectors

**Feature Branch**: `005-url-redirect-decoder`
**Status**: Completed
**Plan**: [specs/005-url-redirect-decoder/plan.md](plan.md)

## Implementation Strategy

We follow an MVP-first approach, starting with the core decoding logic and Microsoft Teams Safelinks (US1). We then expand to other enterprise redirectors (US2) and ensure robust edge case handling.

1. **Foundational**: Implement the core `URLRedirectDecoder` component and its unit tests.
2. **US1 (P1)**: Implement Safelinks decoding and integrate it into the `RoutingEngine`.
3. **US2 (P2)**: Expand the ruleset to include Outlook, Proofpoint, and Slack.
4. **Polish**: Handle recursive decoding and malformed URLs.

## Phase 1: Setup
*No specific setup tasks required for this feature as it uses existing core structures.*

## Phase 2: Foundational Logic

- [x] T001 Define `RedirectorRule` and `DecodingResult` structures in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`
- [x] T002 [P] Create unit test suite for the decoder in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`
- [x] T003 Implement basic host matching logic with wildcard support in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`
- [x] T004 Implement query parameter extraction and URL-decoding in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`

## Phase 3: User Story 1 - Decode Safelinks (Priority: P1)
**Goal**: Successfully decode Microsoft Teams Safelinks and route based on the target URL.
**Independent Test**: Verify that a Teams Safelink URL is decoded to its target URL and correctly matched against a domain rule in the routing engine.

- [x] T005 [P] [US1] Add Microsoft Teams Safelinks rule to `URLRedirectDecoder.swift`
- [x] T006 [P] [US1] Add test case for Microsoft Teams Safelinks in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`
- [x] T007 [US1] Integrate `URLRedirectDecoder` as a preprocessing step in `RoutingEngine.evaluate` in `Sources/Browserly/Core/Routing/RoutingEngine.swift`
- [x] T008 [US1] Add integration test in `Tests/BrowserlyTests/RoutingTests/RoutingEngineTests.swift` verifying end-to-end decoding and routing.

## Phase 4: User Story 2 - Extensible Redirector Decoding (Priority: P2)
**Goal**: Support Outlook, Proofpoint, and Slack redirectors.
**Independent Test**: Verify that URLs from these services are correctly decoded.

- [x] T009 [P] [US2] Add rules for Outlook Safelinks, Proofpoint, and Slack in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`
- [x] T010 [P] [US2] Add unit test cases for US2 redirectors in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`

## Phase 5: Polish & Edge Cases
**Goal**: Ensure robustness against recursive wrappers and malformed inputs.

- [x] T011 Implement recursive decoding (up to 3 levels) in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`
- [x] T012 [P] Add tests for recursive decoding in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`
- [x] T013 Implement fallback logic for malformed target URLs in `Sources/Browserly/Core/Routing/URLRedirectDecoder.swift`
- [x] T014 [P] Add tests for edge cases (missing params, invalid URLs) in `Tests/BrowserlyTests/RoutingTests/URLRedirectDecoderTests.swift`

## Dependencies

- All User Stories depend on Phase 2 (Foundational Logic).
- US2 is independent of US1 once the integration (T007) is complete.

## Parallel Execution Examples

### Parallel US1 & US2 Prep (after Phase 2)
- T005 (Teams rule) + T009 (Other rules)
- T006 (Teams tests) + T010 (Other tests)
