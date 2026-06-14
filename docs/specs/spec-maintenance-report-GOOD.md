# SPEC-MR-001: Maintenance Activity Report

| | |
|---|---|
| **Status** | Approved (demo) |
| **Owner** | Training session |
| **Compliance** | None referenced |

## Context

The Service Operations Portal already tracks assets and the service notes recorded against them. Operations staff need a read-only report that shows maintenance activity across the fleet: a grouped summary to see where activity is concentrated, and a detail view to inspect individual notes. The report reads existing data; it creates nothing. Storage is in-memory per repository conventions.

To make the report meaningful before any notes have been entered, the application seeds a small, clearly-labelled set of demo data at startup (see "Seed data" below).

## User story

As an operations coordinator, I want a maintenance activity report grouped by asset, with the option to see the underlying notes, so that I can see at a glance which assets are receiving the most attention and then drill into the detail.

## Acceptance criteria

1. `GET /api/reports/maintenance` returns a report with two parts: a `summary` array and a `generatedAt` timestamp (server-set, UTC).
2. The `summary` array has one row per asset that has at least one service note. Each row contains: `assetId`, `assetName`, `noteCount`, and `lastActivityAt` (the newest note's timestamp for that asset).
3. The summary is ordered by `noteCount` descending, then by `lastActivityAt` descending as a tiebreak.
4. Assets with no notes do not appear in the summary.
5. `GET /api/reports/maintenance/{assetId}` returns the detail for one asset: `assetId`, `assetName`, and a `notes` array (newest first) containing each note's `text`, `author` and `createdAt`. Unknown asset returns 404 with a problem-detail body.
6. The report is read-only: there are no create, update or delete endpoints under `/api/reports`.

## Non-functional requirements

- Read-only: the report endpoints must not modify any stored data.
- In-memory storage; safe under concurrent reads per repository conventions.
- Error responses follow RFC 7807 per repository conventions.

## UI

- A report page served as a static view, reachable from the portal home, showing the grouped summary as a table (asset name, note count, last activity), with each row expandable or linking to the per-asset detail (the notes, newest first).
- The page shows a clear empty state if the summary is empty.
- Every interactive element and dynamic list carries a `data-testid` per the conventions register (for example `report-summary-row`, `report-detail-note`).

## Seed data

At application startup, seed a small, clearly-labelled demo dataset so the report is non-empty on first load:
- 3 to 4 assets with recognisable names (for example "OCT Scanner, Clinic A", "Fundus Camera, Clinic B").
- 6 to 10 service notes spread unevenly across those assets (one asset should clearly have the most, to make the grouping visible).
- Seed data is obviously demo data (a comment or constant naming it as such) and is created only when storage is empty, so it never competes with data entered live.

## Out of scope

- Any modification of assets or notes through the report
- Filtering by date range, author or text search
- Pagination
- Export (CSV, PDF)
- Authentication or per-user views
- Persistence of any kind

## Test scenarios

- T1: with seeded data, `GET /api/reports/maintenance` returns summary rows only for assets that have notes, ordered by note count descending.
- T2: the `lastActivityAt` of a summary row equals the newest note timestamp for that asset.
- T3: an asset with no notes is absent from the summary.
- T4: `GET /api/reports/maintenance/{assetId}` returns that asset's notes newest first.
- T5: detail for an unknown asset returns 404.
- T6: calling a report endpoint does not change stored data (a follow-up read returns identical counts).
