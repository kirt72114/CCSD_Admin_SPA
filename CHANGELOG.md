# Changelog

All notable changes to the **CCSD All-Things Administrative SPA** are documented here.

---

## [2026.04.01.2] - 2026-04-01

### Seating Chart Overhaul
- **Drag-to-reposition**: Grab any placed seat marker in edit mode and drag it to a new location; saves automatically on drop.
- **Click-to-edit seats**: Click any existing seat in picker mode to open a full edit modal with all fields pre-populated, including a delete option.
- **Live crosshair guides**: Dashed horizontal and vertical crosshair lines follow the cursor during placement mode with a real-time X,Y coordinate readout in the corner.
- **Seat sidebar panel**: Searchable list of all seats displayed alongside the floor plan with color-coded status dots (green = occupied, blue = available, orange = maintenance, gray = unplaced). Click any seat to pan the map and highlight it.
- **Quick-place continuation**: After saving a seat, the app stays in placement mode. Auto-suggests the next seat label number and remembers last-used network config (NIPR/SIPR/JWICS/VTC) for rapid repeat placement.
- **Pinned tooltips**: In view mode, click a seat to pin its tooltip with full details; admins see inline Edit/Delete action buttons.
- **Visual feedback**: New seats get a drop-in animation; selected seats get a glowing ring highlight.
- **Inline sidebar actions**: Edit and delete buttons appear on hover in the sidebar list during edit mode.

---

## [2026.04.01.1] - 2026-04-01

### Fullscreen / Embedded Dual-Mode Support
- **Auto-detection**: `window.self !== window.top` check detects whether the SPA is running inside an iframe (e.g., SharePoint web part embed) or standalone.
- **Embedded mode**: When detected, applies a `.embedded` CSS class to `<body>` that compacts the header, hides the subtitle, shrinks nav tabs, context bar, and buttons.
- **Pop-out button**: A "Full Screen" button appears in embedded mode that opens the SPA in a new browser tab at full viewport size via `?fullscreen=1`.
- **Fullscreen badge**: Standalone mode displays a subtle "Full Screen" indicator badge in the header.

---

## [2026.03.31.3] - 2026-04-01

### Org Chart Visual Improvements
- **L-shaped connector lines**: Hierarchical tree now uses vertical + horizontal CSS pseudo-element connectors for a traditional org chart appearance.
- **Current org highlighting**: The user's own organization is visually identified with a green border and "YOUR ORG" badge via the `isCurrentUserOrg()` function.
- **Inline leadership display**: Each org card shows up to 3 leadership positions with name, role, email, and phone directly on the card.
- **Org email display**: Shows `OrgEmail` field on org cards when available.
- **Auto-select user's org**: Org chart automatically selects and scrolls to the current user's organization on load.
- **Deeper indentation and tighter card styling**: Improved visual hierarchy with increased indent and refined card border-radius/padding.

### Interactive Floor Plan Viewer
- **Image-based floor plans**: Renders seat markers overlaid on building floor plan images at stored X,Y coordinates.
- **Pan and zoom**: Click-drag to pan, scroll-wheel to zoom, with zoom-in/out/reset controls.
- **Seat markers**: Color-coded dots (green = occupied, blue = available, orange = maintenance) with hover labels.
- **Rich tooltips**: Hover a seat to see occupant, port number, phone, network capabilities (NIPR/SIPR/JWICS), VTC status, and notes.
- **Coordinate picker tool** (admin): Enter placement mode, click the floor plan to capture X,Y coordinates, then fill in seat details via a modal form.
- **Pending marker**: Shows a pulsing dashed circle at the clicked position before saving.
- **Floor plan URL management**: Admin modal to set/update the floor plan image URL on facility records.
- **Legend**: Color-coded legend with placed/total seat counts.
- **Facility-level and room-level**: Supports floor plans at both the building level and individual room level.

---

## [2026.03.31.2] - 2026-03-31

### Admin Role Restriction
- **App Admin gating**: Changed `canSeeAdmin()` from `hasAnyRole(['Admin','App Admin'])` to `hasAnyRole(['App Admin'])` — only users with the "App Admin" role can access admin, diagnostics, and telemetry features.
- **Nav filtering**: Admin and Diagnostics tabs hidden from the nav bar for non-App Admin users.
- **Route protection**: Direct navigation to admin/diagnostics routes is blocked with a toast and redirect to home.
- **Header button**: Diagnostics button in the header is hidden by default and only shown for App Admin.
- **Home page gating**: Diagnostics Center button, Health + Queue Signals card, Quick Nav admin tiles, and data quality actions all wrapped in `canSeeAdmin()` checks.
- **Keyboard shortcut**: `Alt+D` for diagnostics only registered when `canSeeAdmin()` is true.

---

## [2026.03.31.1] - 2026-03-31

### Major Functional Features
- **Sortable tables**: Click any `th[data-sort]` column header to sort ascending/descending. Supports text, numeric, and date types with visual sort indicators.
- **Request lifecycle management**: Full edit modal for requests with status transitions (New, In Progress, On Hold, Completed, Closed), priority changes, due dates, and threaded comments parsed from `WorkflowJson`.
- **Close request**: One-click close action that sets status to Closed with `ClosedOn` timestamp.
- **In/Out process completion**: Mark individual checklist steps as Completed with `CompletedOn`/`CompletedBy` tracking. Auto-advances the parent case's `CurrentStep` and `Status`.
- **In/Out detail modal**: Full step checklist view with progress bar for each in-processing or out-processing case.
- **Team training compliance**: Builds a compliance model for the current supervisor's team. Renders a grid with per-person compliance bars showing training status.
- **SF182 edit modal**: Edit SF182 records including status changes, dates, accommodation requests, and rejection comments.
- **Hardware asset assignments**: Create modal to assign hardware assets to personnel with serial number, condition, and location fields.
- **Software asset assignments**: Create modal to assign software titles to personnel with license key and environment fields.
- **Supervisor chain**: Walks the `SupervisorID` chain up to 10 levels and renders a clickable badge chain.
- **Org people stats**: Calculates total and active member counts for any organization.

---

## [2026.03.31.0] - 2026-03-31

### Multi-Site Support
- **Hostname-based site detection**: Automatically resolves `APP.rootUrl` based on `window.location.hostname` matching against configured sites (`usaf.dps.mil` and `patriavirtus.sharepoint.com`).
- **Site configuration object**: `APP.sites` maps hostnames to root URLs, labels, and environment tags.
- **Seamless replication**: Same `Index.html` file works across both USAF production and Patria Virtus replica sites without code changes.

---

## [2026.03.30.1] - 2026-03-30

### Major Upgrade
- **Bug fixes**: Resolved issues across data loading, rendering, and state management.
- **Form validation framework**: Centralized validation with `runValidation()` and `showValidationErrors()` helpers.
- **Accessibility improvements**: ARIA labels, roles, keyboard navigation support across all modules.
- **Facilities module**: Full CRUD for facilities and rooms with detail views, seat management, and room type categorization.
- **Admin enhancements**: Diagnostics panel, telemetry logging, data quality checks, cache management, and queue monitoring.
- **Toast notifications**: Styled notification system with auto-dismiss and severity levels.
- **Modal system**: Reusable modal framework with title, body, footer, and close actions.
- **Context bar**: User context display with role chips, environment indicator, and quick actions.
- **Export functionality**: CSV export for table data across modules.
- **No-scroll SPA layout**: Viewport-height flex layout with internal scrolling in `viewHost` only.

---

## [2026.03.30.0] - 2026-03-30

### SharePoint List Schema
- **List creation script**: PowerShell/manual creation guide for all 25+ SharePoint lists.
- **Column definitions**: Field types, lookup relationships, and choice values for Personnel, Organizations, Training, SF182, Requests, InOutCases, InOutSteps, Facilities, Rooms, Seats, Hardware, Software, HardwareAssignments, SoftwareAssignments, AppRoles, Telemetry, and supporting lists.

---

## [2026.03.29.0] - 2026-03-29

### Initial Release
- **Single-file SPA**: Vanilla ES5 JavaScript application in a single `Index.html` file for SharePoint Online deployment.
- **Hash-based routing**: Client-side routing across Home, People, Organizations, Training, SF182, Requests, In/Out, Facilities, Assets, Admin, and Diagnostics modules.
- **SharePoint REST API integration**: OData query building, form digest handling, CRUD operations against SharePoint lists.
- **RBAC**: Role-based access control via `CCSD_AppRoles` list with `hasAnyRole()` and `canSeeAdmin()` gating.
- **Global state management**: Centralized `APP` object for state, cache, configuration, and navigation.
- **Event delegation**: Click handling via `data-action` attributes and central `handleClick` dispatcher.
- **Dark theme UI**: Glass-morphism design with gradient backgrounds, blur effects, and animated accent blobs.
- **Responsive grid layouts**: CSS Grid-based card layouts with breakpoint-aware column counts.
- **README**: Detailed project overview with architecture, deployment, and usage documentation.
