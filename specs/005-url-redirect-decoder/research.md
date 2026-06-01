# Research: URL Redirector Decoding

## Decision: Pattern-Based Parameter Extraction

For Phase 1, we will implement a list of known redirector domains and the query parameter that contains the target URL.

### Rationale
Most enterprise redirectors (Teams, Outlook, Proofpoint, Slack) follow a standard pattern: they wrap the target URL in a specific query parameter of a dedicated "safe" domain. Extracting and URL-decoding this parameter is the most reliable and performance-efficient way to handle this without executing any remote code or complex HTML parsing.

### Target Redirectors (v1)

| Service | Domain Pattern | Parameter |
|---------|----------------|-----------|
| MS Teams | `statics.teams.cdn.office.net` | `url` |
| MS Outlook | `*.safelinks.protection.outlook.com` | `url` |
| Proofpoint | `urldefense.proofpoint.com` | `u` |
| Slack | `slack-redir.net` | `url` |

### Alternatives Considered

1. **Hardcoded Logic for Each Service**: Rejected as it's not extensible. A pattern-based approach is cleaner.
2. **HTML Parsing (for redirect pages)**: Rejected because it's too slow and complex. Many redirectors use query parameters specifically to avoid the need for the browser (or our app) to load the page first.
3. **Regex for Extraction**: Regex can be brittle with URL encoding. Using `URLComponents` and `queryItems` is safer and more idiomatic in Swift.

## Implementation Strategy

1. Create a `URLRedirectDecoder` struct/class.
2. Define a `RedirectorRule` that contains a host pattern and the parameter name.
3. Implement a `decode(url: URL) -> URL` function that:
   - Checks if the URL host matches any known rule.
   - Extracts the specified query parameter.
   - URL-decodes the value.
   - Returns a new `URL` if successful, otherwise the original URL.
4. Integrate this into `RoutingEngine.evaluate`.

## Best Practices
- Use `URLComponents` for robust URL parsing.
- Ensure all extraction is performed locally (no network requests).
- Performance: The check should be $O(N)$ where $N$ is the number of rules, which will be very small (<10).
