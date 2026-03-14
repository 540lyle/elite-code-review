## Summary

This change adds server-side caching to the user profile endpoint and updates the frontend to consume the cached response path. Main risks are cache invalidation and a possible response-shape mismatch in the error path.

## Risk Score

6/10

The touched code affects both API behavior and client consumption. The happy path looks reasonable, but the cache layer introduces stale-data risk and the client now assumes a field that is not guaranteed on non-200 responses.

## Findings

### High Priority

- **Client assumes `profile.displayName` exists on all responses**
  - The frontend now reads `profile.displayName` immediately after the fetch resolves, but the backend error path still returns `{ error: ... }` without a `profile` object.
  - This can produce a runtime exception when the API returns a non-200 JSON payload.
  - Recommendation: gate access on `response.ok` or normalize the server response shape.

### Medium Priority

- **Cache invalidation is missing on profile update**
  - The new read path uses cached profile data, but the update handler does not evict or refresh the same key.
  - Users may continue seeing stale profile data after a successful save.
  - Recommendation: invalidate on write or use write-through/update-after-write behavior.

### Low Priority

- **No observability on cache misses**
  - This is not blocking, but without miss or hit metrics it will be harder to validate whether the new layer helps in production.
  - Recommendation: add lightweight hit or miss logging or metrics if this endpoint is performance-sensitive.

## Test Coverage Gaps

- Missing test for non-200 response handling in the frontend consumer.
- Missing integration test showing profile updates invalidate or refresh cached reads.

## Approval Recommendation

Request changes

## Confidence

High

The diff includes both the server response construction and the frontend consumer, so the contract mismatch is directly visible.
