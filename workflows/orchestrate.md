---
name: orchestrate
description: Multi-agent coordination workflow — assign specialists, coordinate parallel work, track handoffs between agents or developers for complex features.
trigger: /orchestrate
---

# Orchestrate Workflow

## Purpose

Use `/orchestrate` when a task is too large or complex for a single agent or developer to handle linearly. This workflow:
- Breaks the work into parallel, independent streams
- Assigns each stream to a specialist role
- Defines handoff points and integration checkpoints
- Tracks progress and blockers across streams

Best for:
- Feature spanning frontend + backend + infrastructure
- Large refactors touching multiple modules
- Features requiring design + API + tests in parallel
- Onboarding a new major capability (e.g., adding a payments system)

## Steps

### 1. Decompose the Task

Break the feature into independent vertical slices:

```markdown
## Feature: User Export (CSV + Excel)

### Stream A: Backend API (2 days)
Dependencies: none
Owner: backend agent / developer

Tasks:
- [ ] Define ExportDto and validation
- [ ] Implement CSV generation service
- [ ] Implement Excel generation service (ExcelJS)
- [ ] Add GET /users/export.csv and GET /users/export.xlsx endpoints
- [ ] Auth guard + admin-only access
- [ ] Rate limiting (max 1 export/minute per user)
- [ ] Unit + integration tests

### Stream B: Frontend UI (1.5 days)
Dependencies: Stream A API contract (can mock with MSW)
Owner: frontend agent / developer

Tasks:
- [ ] Export button in Users page
- [ ] Format selector (CSV / Excel)
- [ ] Loading state + progress indicator
- [ ] Error handling (rate limit, server error)
- [ ] MSW mock for /users/export.csv

### Stream C: Infrastructure (0.5 days)
Dependencies: none (parallel)
Owner: infra agent / developer

Tasks:
- [ ] Add export rate-limiting config to Railway env
- [ ] Increase memory limits for Excel generation (needs ~512MB)
- [ ] Add export-related metrics to Datadog dashboard
```

### 2. Identify Dependencies and Sequencing

```
PARALLEL phase (can start immediately):
  Stream A: Backend
  Stream C: Infrastructure

DEPENDS ON Stream A contracts:
  Stream B: Frontend (needs API response shape)
    → Can start with mocks — unblock after Stream A defines the DTO

INTEGRATION phase (all streams done):
  → E2E tests
  → Smoke test on staging
  → PR review
  → Deploy
```

### 3. Define Contracts (Handoff Points)

Contracts let parallel streams stay unblocked.

```typescript
// CONTRACT — defined by Stream A, consumed by Stream B
// Both teams agree on this before starting

// GET /api/v1/users/export
// Query params: format=csv|xlsx, fields=id,name,email (optional)
// Response on success: binary file download
// Response headers:
//   Content-Type: text/csv | application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
//   Content-Disposition: attachment; filename="users-2026-05-15.csv"
// Rate limit response (429):
//   { "error": { "code": "RATE_LIMIT_EXCEEDED", "retryAfter": 60 } }
```

### 4. Parallel Execution

Launch agents (or assign developers) simultaneously:

```markdown
## Orchestration Plan

| Agent | Stream | Start | ETA | Status |
|-------|--------|-------|-----|--------|
| Agent 1 | Backend API | now | +2d | in_progress |
| Agent 2 | Frontend UI | now (with mocks) | +1.5d | in_progress |
| Agent 3 | Infrastructure | now | +0.5d | done |

## Blocking Dependencies
- Stream B frontend integration (not mocks) blocked until Stream A /export endpoint is deployed to staging
- E2E tests blocked until both Stream A + B are merged

## Next Sync Point
When: Stream A endpoint deployed to staging
Action: Agent 2 switches from MSW mocks to real API integration
```

### 5. Integration Checkpoint

When parallel streams complete:

```markdown
## Integration Checklist

□ Stream A: All tests pass, endpoint on staging
□ Stream B: Component tests pass, API integration verified
□ Stream C: Infrastructure changes deployed

□ E2E test: export flow works end-to-end (CSV download)
□ E2E test: Excel download opens correctly
□ E2E test: Rate limit shows appropriate error message
□ Performance: Export of 10k users completes in < 10s
□ Security: Endpoint requires admin role
□ Monitoring: Export metrics visible in dashboard
```

### 6. Handoff Summary

```markdown
## Handoff — User Export Feature

**All streams complete:** 2026-05-17
**Staging verification:** passed
**PR:** #145 — feat: add user CSV/Excel export

**What was built:**
- Backend: GET /api/v1/users/export with CSV and Excel support
- Frontend: Export dropdown in Users → Actions menu
- Infra: Rate limiting + memory config updated

**Known limitations:**
- Max export size: 50k rows (enforced server-side)
- Export is synchronous — async job queue for >50k is a future ticket (#146)

**Tests:**
- Unit: 12 new tests, all passing
- Integration: 3 new tests
- E2E: 2 new tests
- Coverage: 84% (was 82%)

**Ready for:** production deploy via standard PR process
```

## Agent Roles Reference

| Role | Specialization |
|------|---------------|
| **planner** | Implementation plan, task breakdown, dependency mapping |
| **architect** | System design, module boundaries, data flow |
| **tdd-guide** | Test-first implementation, coverage strategy |
| **code-reviewer** | Quality review, pattern consistency |
| **security-reviewer** | Auth, input validation, OWASP checks |
| **build-error-resolver** | CI failures, type errors, build issues |

## Forbidden Patterns

- Never start integration before streams define their contracts
- Never let streams work in isolation beyond a day without a sync
- Never skip the integration checkpoint — merging untested integrations causes production incidents
- Never assign the same developer to parallel streams — defeats the purpose
