# SPEC-SN-001: Service Notes on Assets

| | |
|---|---|
| **Status** | Approved (demo) |
| **Owner** | Training session |
| **Compliance** | None referenced (see Lab 5 extension) |

## Context

The Service Operations Portal manages assets and their maintenance history. Technicians need to attach free-text service notes to an asset, for example observations made during a site visit. Storage is in-memory per repository conventions.

## User story

As a service technician, I want to add a note to an asset and see the asset's notes newest first, so that the next technician knows what was observed.

## Acceptance criteria

1. `POST /api/assets/{assetId}/notes` creates a note on an existing asset.
2. Creating a note on an unknown asset returns 404 with a problem-detail body.
3. A note has: `text` (required, 1 to 2000 characters) and `author` (required, 1 to 100 characters). Violations return 400 naming the failing fields.
4. The server sets the note's `createdAt` timestamp (UTC). Clients cannot supply it.
5. `GET /api/assets/{assetId}/notes` returns the asset's notes ordered newest first; an asset with no notes returns an empty list, unknown asset returns 404.
6. Notes are immutable: there is no endpoint to edit or delete a note.

## Non-functional requirements

- In-memory storage must be safe under concurrent requests.
- Error responses follow RFC 7807 per repository conventions.

## Out of scope

- Editing or deleting notes
- Attachments, images or rich text
- Authentication and user management (`author` is a plain string supplied by the client)
- Pagination, search and filtering
- Persistence of any kind

## Test scenarios

- T1: create a valid note on an existing asset; response contains the note with a server-set timestamp
- T2: create a note on an unknown asset; 404
- T3: create a note with empty text and missing author; 400 naming both fields
- T4: create a note with text of 2001 characters; 400
- T5: create three notes in sequence; GET returns them newest first
- T6: GET notes for an asset with no notes; 200 with empty list
