---
title: Add a derived maintenanceDue flag to the asset list
status: ready-for-execution
date: 2026-06-16
slug: maintenance-due-flag
---

# Maintenance ticket: Add a derived maintenanceDue flag

## Change description

Add a derived `maintenanceDue` boolean to the asset list response. It is `true` when the asset's `status` is `IN_SERVICE`, and `false` otherwise. The field is computed on read, stored nowhere, and changes no write paths. This is a small Mode 3 maintenance increment on the existing Asset API.

## Acceptance criteria

1. The asset response includes a `maintenanceDue` boolean field.
2. `maintenanceDue` is `true` when the asset's `status` is `IN_SERVICE`.
3. `maintenanceDue` is `false` for every other status (`ACTIVE`, `RETIRED`).
4. `GET /api/assets` returns `maintenanceDue` for every asset in the response body.
5. `GET /api/assets/{id}` returns `maintenanceDue` for the single asset.
6. At least one unit test verifies criterion 2 (an IN_SERVICE asset is due) and at least one verifies criterion 3 (an ACTIVE asset is not due).
7. `docs/changelog.md` is updated with a brief description of the change.

## Out of scope

- Adding new fields to the Asset record (no `lastServiceDate`, no service interval).
- Sending notifications or events when an asset becomes due.
- Filtering or sorting the asset list by `maintenanceDue`.
- A dedicated `/api/assets/due` endpoint.
- Persisting `maintenanceDue`; it is always derived on read.
- Any UI change to the portal page.

## Compliance note

This change adds a derived boolean to the asset response. It adds no PII, touches no authentication surface, and does not affect any audit path. REG-01 check: confirm no audit or maintenance-record trace path is altered (the field is derived from existing state, stored nowhere, so no trace path is affected).

## Areas touched

- Domain or response mapping: wherever the asset is shaped for the API (a derivation from `status`)
- Service layer: the derivation logic, if a service owns asset retrieval
- Tests: unit tests in `src/test/`, covering criteria 2 and 3
- Docs: `docs/changelog.md`
