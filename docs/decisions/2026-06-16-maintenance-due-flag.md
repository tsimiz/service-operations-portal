---
title: Add maintenanceDue flag to Asset
status: ready-for-execution
date: 2026-06-16
slug: maintenance-due-flag
---

# Maintenance ticket: Add maintenanceDue flag to Asset

## Change description

Add a `maintenanceDue` boolean to the Asset domain model. Set it to `true` when the asset's `lastServiceDate` is older than its `serviceIntervalDays`, or when `lastServiceDate` is null and the asset has been registered for longer than the interval. Surface the field in the asset list API response.

This is a read-only derived field: it is computed on read, stored nowhere, and affects no write paths.

## Acceptance criteria

1. `Asset` has a `maintenanceDue` boolean field.
2. `maintenanceDue` is `true` when `lastServiceDate` is more than `serviceIntervalDays` days ago (relative to today).
3. `maintenanceDue` is `true` when `lastServiceDate` is null and `registrationDate` is more than `serviceIntervalDays` days ago.
4. `maintenanceDue` is `false` for all other cases (recently serviced, newly registered).
5. `GET /api/assets` returns `maintenanceDue` in every asset in the response body.
6. At least one unit test verifies criterion 2 (overdue asset) and at least one verifies criterion 3 (never-serviced asset).
7. `docs/changelog.md` is updated with a brief description of the change.

## Out of scope

- Sending notifications or events when maintenance becomes due.
- Filtering or sorting the asset list by `maintenanceDue`.
- A dedicated `/api/assets/overdue` endpoint.
- Storing `maintenanceDue` in memory or persisting it.
- Any UI changes to the portal page.

## Compliance note

This change adds a derived boolean to the asset list response. It does not add PII, does not touch authentication surfaces, and does not affect audit log paths. REG-01 check: verify no maintenance-record trace path is altered by the addition (the field is derived, not stored, so no trace path should be affected).

## Areas touched

- Domain model: `Asset.java` (new field and derivation method)
- API response mapping: `AssetResponse.java` or equivalent DTO
- Service layer: `AssetService.java` (or wherever asset retrieval happens, for derivation logic)
- Tests: unit tests in `src/test/`, covering criteria 2 and 3
- Docs: `docs/changelog.md`
