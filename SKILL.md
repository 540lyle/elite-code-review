---
name: elite-code-review
description: Perform rigorous, high-signal code review for repository changes. Use when the user asks to review changes, a diff, a PR, a commit, or to audit code for bugs, regressions, contract drift, security risks, concurrency issues, missing validation, or insufficient tests. Review staged changes, unstaged changes, branch diffs, or explicit diffs. Prefer actionable findings over style commentary.
---

# Elite Code Review

Review the change set in context, not just the changed lines.

Prioritize production risk over style. Focus on correctness, contract integrity, safety, regression risk, and test adequacy.

## Determine Review Scope

Use explicit user-provided diff, commit, or PR context when available.

Otherwise determine the change set automatically with git. Prefer this order:

1. explicit user-provided diff
2. staged changes
3. branch diff
4. last commit
5. unstaged changes

Try these commands in order:

```bash
git diff --staged --patch --find-renames --find-copies
git diff --patch --find-renames --find-copies
git diff origin/main...HEAD --patch --find-renames --find-copies
git diff origin/master...HEAD --patch --find-renames --find-copies
git show --stat --patch --find-renames --find-copies --format=fuller HEAD
```

If those are empty but `git status --short` shows untracked files, diff each untracked file against `/dev/null` so newly added files are still reviewable.

If useful, run [`scripts/detect_changes.sh`](./scripts/detect_changes.sh) to automate that sequence in Bash-compatible environments. If the environment is not Bash-compatible, run the same git commands directly.

If no meaningful diff can be determined, say so clearly and stop.

## Build Context Before Judging

Inspect repository context relevant to the touched files before making findings.

Determine when possible:

- primary language or languages
- framework or frameworks
- package manager
- test framework
- obvious lint, typecheck, build, or test commands
- whether the repo includes frontend, backend, database, infra, API schema, generated code, or config-sensitive code

Read nearby implementations, interfaces, tests, schemas, route definitions, and call sites as needed to understand intent and blast radius.

Do not assume a change is safe because it is small.

## Classify the Change

Classify the change into one or more categories:

- UI or presentation
- business logic
- API contract
- persistence or database
- auth or permissions
- async or concurrency
- config or environment
- build or CI
- refactor
- test-only
- docs-only

Use the category to assess blast radius and review depth.

## Review Priorities

Prioritize findings in this order.

### P0 Critical correctness or security

Flag issues likely to cause:

- crashes
- data loss
- corrupted state
- broken authentication or authorization
- secrets exposure
- injection vulnerabilities
- unsafe command execution
- broken transactional guarantees
- severe contract mismatches
- invalid assumptions around nullability, timing, retries, or partial failure

### P1 High-risk regressions

Flag issues such as:

- request or response shape mismatches
- changed behavior without matching validation or tests
- broken error handling
- incorrect async usage
- race conditions
- off-by-one or boundary bugs
- incorrect fallback behavior
- cache invalidation mistakes
- stale state assumptions
- incomplete rename or refactor
- missing migration compatibility
- frontend or backend drift
- client or server type drift

### P2 Maintainability and resilience risks

Flag issues such as:

- duplicated logic that creates divergence risk
- hidden side effects
- brittle control flow
- weak naming that obscures intent
- unnecessary coupling
- missing observability for high-risk flows
- weak rollback or recovery assumptions

### P3 Optional improvements

Only include genuinely useful refinements such as:

- small simplifications
- clearer naming
- targeted refactor suggestions
- test suggestions for edge cases

Do not overload the review with trivia.

## Check Contract Drift

When code touches an API layer, schema, DTO, interface, typed client, serialization logic, or validation boundary, check for drift across dependent boundaries.

Inspect mismatches such as:

- frontend request payload vs backend expectation
- backend response shape vs frontend consumption
- server types vs generated client types
- route params vs caller construction
- schema changes vs persistence or migration logic
- validation rules vs UI assumptions
- enum changes vs switches and conditionals
- renamed fields without backward compatibility handling

Treat silent contract drift as high priority.

## Review Tests

For behavior-changing code, determine whether tests changed appropriately.

Consider whether the change should have:

- unit tests
- integration tests
- API tests
- UI tests
- migration tests
- error-path tests
- concurrency or retry-path tests

Do not complain about missing tests for trivial comment or formatting changes.

## Review Validation and Tooling Impact

If validation commands are discoverable, consider whether the change is likely to break them.

Look for:

- type errors
- import or path errors
- build-breaking config changes
- dependency drift
- lint failures from renamed or unused symbols
- generated artifacts that now require regeneration
- CI config mismatches

If commands are not known, say that explicitly rather than implying certainty.

## Review Security

Always inspect touched code for security implications.

Look for:

- committed secrets or secret-like values
- unsafe logging of tokens, headers, cookies, or personal data
- missing auth checks
- trust of client-provided fields
- SQL, shell, template, or path injection risk
- SSRF or open redirect risk
- insecure file handling
- unsafe deserialization
- CORS or CSRF regressions when relevant

Never reproduce secrets in output.

## Review Performance

Raise performance findings only when they are plausible and material.

Look for:

- N+1 queries
- repeated expensive computation
- unnecessary serialization or parsing
- synchronous blocking in hot paths
- overfetching
- cache misuse
- unbounded loops or retries
- memory growth from retained state or oversized payload handling

Ignore hypothetical micro-optimizations.

## Output Format

Produce a structured review with these sections and this order.

### Summary

Write one short paragraph describing what changed and the main risk areas.

### Risk Score

Give a score from 0 to 10 using this scale:

- 0-1: trivial, isolated, very low risk
- 2-3: low risk
- 4-5: moderate risk
- 6-7: high risk
- 8-10: very high risk

Explain the score in 1-3 sentences.

### Findings

Group findings by priority:

- High Priority
- Medium Priority
- Low Priority

For each finding include:

- concise title
- why it matters
- evidence from the diff or surrounding code
- concrete recommendation

Prefer fewer strong findings over many weak ones. If there are no meaningful findings, say so directly.

### Test Coverage Gaps

List only meaningful missing tests.

### Approval Recommendation

Choose exactly one:

- Approve
- Approve with minor changes
- Request changes

### Confidence

Choose exactly one:

- High
- Medium
- Low

Lower confidence when the diff is incomplete, repository context is missing, or validation commands could not be inspected.

## Reviewer Behavior Rules

- Be direct and evidence-based.
- Do not invent repository commands.
- Do not assume a framework unless the repo indicates one.
- Do not give broad architectural advice unless it is directly relevant to the diff.
- Do not suggest unrelated refactors.
- Do not pad the review with compliments.
- Do not block on style nits.
- Do not restate the entire diff.
- Do not claim certainty when context is missing.

## Strong Review Heuristics

Bias toward catching these common failure modes:

- partial rename leaving stale references
- changed backend response shape without updating consumers
- async function introduced without awaited callers
- new nullable value used as non-null
- feature flag logic inverted or incompletely gated
- fallback path no longer preserves old behavior
- optimistic update without rollback
- retry logic causing duplicate writes
- migration that is not backward compatible during rollout
- caching without invalidation
- pagination, sorting, or filtering contract drift
- auth enforced in UI but not server
- server error shape changed without client handling update
- logging of request bodies or auth headers
- tests updated only for the happy path

## Safety Constraints

Never:

- reveal secrets
- suggest destructive git operations as part of the review
- recommend disabling security checks to make code pass
- output environment values

## Tone

Be professional, terse, and useful. Default to high signal.
