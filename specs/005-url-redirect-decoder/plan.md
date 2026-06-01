# Implementation Plan: Decode URL Redirectors

**Branch**: `005-url-redirect-decoder` | **Date**: June 1, 2026 | **Spec**: [specs/005-url-redirect-decoder/spec.md](spec.md)
**Input**: Feature specification from `/specs/005-url-redirect-decoder/spec.md`

## Summary

The feature introduces a URL preprocessing step to decode wrapped URLs from known redirectors (like Microsoft Teams Safelinks) before they are processed by the routing engine. This ensures that routing rules are applied to the final destination URL rather than the security wrapper.

## Technical Context

**Language/Version**: Swift 5.9+  
**Primary Dependencies**: Foundation  
**Storage**: N/A (Hardcoded list for v1)  
**Testing**: XCTest  
**Target Platform**: macOS (darwin)
**Project Type**: desktop-app  
**Performance Goals**: < 5ms routing overhead  
**Constraints**: Minimal memory footprint, no network calls for decoding  
**Scale/Scope**: Small utility module within Core/Routing

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- [x] Principle I: Follow standard Ray Wenderlich/Apple conventions (Swift 5.9+)
- [x] Principle II: Maintain Universal Binary compatibility
- [x] Principle III: Test-First (New tests for Safelinks decoding)
- [x] Principle IV: Native Dark Mode (UI components only, N/A for this logic)

## Project Structure

### Documentation (this feature)

```text
specs/005-url-redirect-decoder/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
Sources/Browserly/
├── Core/
│   └── Routing/
│       ├── RoutingEngine.swift       # Update to include preprocessing
│       └── URLRedirectDecoder.swift  # New logic for decoding
```

**Structure Decision**: The logic will be added as a new component `URLRedirectDecoder` in `Core/Routing` and integrated into `RoutingEngine` as a preprocessing step.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| None | | |
