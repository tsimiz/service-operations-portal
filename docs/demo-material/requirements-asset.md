# Requirements: Asset API (Demo 3.1 input)

Build an Asset API for a service operations portal.

- Asset has: id, name, type (DEVICE, TOOL, VEHICLE), serial number, status (ACTIVE, IN_SERVICE, RETIRED)
- GET /api/assets returns all assets
- GET /api/assets/{id} returns one asset, 404 if unknown
- POST /api/assets creates an asset; name, type and serial number are required
- Storage is in memory
