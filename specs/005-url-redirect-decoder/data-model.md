# Data Model: URL Redirector Decoding

## Entities

### RedirectorRule

Represents a known URL redirector pattern.

- **hostPattern**: `String` - The domain or subdomain to match (e.g., `statics.teams.cdn.office.net`). Supports simple wildcard `*` for subdomains.
- **parameterName**: `String` - The query parameter containing the target URL (e.g., `url`, `u`).

### DecodingResult

The result of an attempted decoding operation.

- **originalURL**: `URL` - The input URL.
- **decodedURL**: `URL` - The extracted target URL if found and valid, otherwise same as `originalURL`.
- **isDecoded**: `Bool` - True if a redirector was matched and a target URL was successfully extracted.

## State Transitions

The decoding process is stateless and functional:
`URL` -> `URLRedirectDecoder.decode()` -> `URL`

## Validation Rules

- **Host Matching**: Host must match exactly or match a wildcard pattern.
- **Parameter Extraction**: Parameter must exist and its value must be a valid URL string after decoding.
- **Recursive Decoding**: If the decoded URL is also a known redirector, the system should ideally handle it recursively (limit to 3 levels to prevent infinite loops).
