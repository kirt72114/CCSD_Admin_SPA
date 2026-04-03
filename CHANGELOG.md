# Changelog

All notable changes to the **CCSD All-Things Administrative SPA** are documented here.

---

## [2026.04.03.4] - 2026-04-03

### SPFx Script Editor Web Part & Deployment

- **SPFx Script Editor web part** — Created a SharePoint Framework (SPFx 1.18.2) web part (`spfx-script-editor/`) that loads the CCSD SPA on modern SharePoint pages. Supports configurable Script URL and app height via the property pane.
- **AJAX + srcdoc rendering** — Web part fetches HTML via XHR and renders using `iframe.srcdoc` to bypass SharePoint Online's `Content-Disposition: attachment` headers on `.html` files.
- **Multi-site deployment verified** — App successfully deployed at replica site (`patriavirtus.sharepoint.com`) with auto-detection of hostname working correctly.
- **App Catalog setup** — Documented tenant App Catalog creation and `.sppkg` deployment workflow.

### .aspx Deployment Approach Removed

- **Reverted ASP.NET page directives** — Removed `<%@ Page %>` and `<%@ Register %>` directives from Index.html. The .aspx deployment strategy (uploading to SitePages as Index.aspx) was abandoned after SharePoint Online continued to force-download the file regardless of directives.
- **Cleaned Azure AD redirect URIs** — Updated redirect URI references in Index.html comments and TODO.md from `SitePages/Index.aspx` to `SiteAssets/Scripts/Index.html` to reflect the actual deployment path.
- **Removed ASP.NET directive stripping from SPFx web part** — Deleted the `<%@ %>` regex in `ScriptEditorWebPart.ts` that was added defensively for .aspx content. No longer needed since only `.html` files are served.
- **Deleted `Loader.aspx`** — Removed the iframe-wrapper .aspx page that was created as an intermediate approach before SPFx.

### Environment Review & Schema Gap Analysis

- **SharePoint environment verification** — Cross-referenced app code (`Index.html` list registry, lines 830-859), verification script (`verify-sharepoint-env.js`), provisioning script (`Add-MissingColumns.ps1`), and checklist (`SHAREPOINT_VERIFICATION_CHECKLIST.md`) to produce a full gap inventory.
- **Identified 32 missing columns across 5 lists** — Columns referenced by app code but not yet created in either production or replica SharePoint environments. The `Add-MissingColumns.ps1` script was previously created to address these in the replica; production requires manual creation or a separate provisioning approach.
- **Identified 2 missing lists** — `CCSD_TimeOff` (confirmed missing from both environments; required for Calendar module) and one additional list (not conclusively identified; requires re-running the verification script to confirm).
- **Catalogued 12 optional future columns** — Documented in TODO.md Section 14: columns for planned features (inventory audit, warranty tracking, cost center reporting, In/Out Processing location fields) that are not yet needed by current app code.

---

## [2026.04.03.3] - 2026-04-03

### Bug Fixes & UI Overhaul

- **Dark mode contrast** — Significantly boosted: darker backgrounds (#020810), brighter text (#f4f8ff), stronger borders (14-18% opacity), more vivid accent colors
- **App layout condensed** — Reduced all padding, margins, font sizes, gaps, and border-radius to fit at 100% browser zoom without scrollbar
- **Fullscreen API** — "Full Screen" button now uses browser `requestFullscreen()` / `exitFullscreen()` instead of opening a new tab; toggles in/out, always visible
- **Facilities POC fix** — Fixed `[object Object]` display by properly handling Person/Group lookup fields; supports multiple POCs per building; each POC is clickable with a contact card modal
- **Certificate upload** — Training submission form now includes a file upload (PDF, images, Word, max 10MB) using SharePoint REST attachment API
- **In/Out Processing improvements** — Category and Owning Office converted to dropdowns; added From/To location fields; added Losing/Gaining Org dropdowns for transfers
- **Request templates** — Converted from pre-filled text blobs to structured labeled fields (text, select, date, textarea) per template type
- **Organizations print view** — Redesigned to open a dedicated print window with professional hierarchical layout, leader names, personnel counts, and AETC-LAK CPSG branding

---

## [2026.04.03.2] - 2026-04-03

### Major Feature Sprint — All Modules Enhanced

#### People Module
- **Person detail page**: Unified modal with contact, org, training records, time-off history, and assigned assets in a 2-column grid layout.
- **Departure processing**: Modal with date, reason (PCS/Separation/Retirement/Transfer/Other), notes. Marks person as Departed.
- **Org transfer workflow**: Move person to new org/position with effective date tracking.
- **Personnel CSV export**: Download all personnel data as CSV from the People view.

#### Organization Module
- **Create/edit organization modal**: Full form with name, code, type, parent, email, active status. Admin-gated.
- **Org dashboard**: Per-org metrics showing active personnel, training compliance %, active assets, and open requests.
- **Org chart print**: Print button on Branch Explorer uses browser print with print-optimized CSS.

#### Training Module
- **Training gap analysis**: Modal showing compliance % per organization, sorted lowest-first.
- **Bulk training record entry**: Admin can select training + date, paste person IDs to create records in bulk.
- **Certification expiration alerts**: Utility function + Home dashboard widget showing certs expiring within 60 days.

#### Requests Module
- **Comment thread in detail view**: Comments now visible when viewing (not just editing) a request.
- **SLA tracking**: Visual indicator with color-coded days remaining/overdue on request detail.
- **Supervisor request dashboard**: Modal showing team's requests with KPIs (total, open, overdue).
- **Request templates**: 6 built-in templates (IT New Account, IT Hardware Issue, HR Personnel Action, Facilities Maintenance, Security Access Request, Training Course Request).

#### Calendar Improvements
- **CSV/ICS export**: Download current calendar view as CSV or ICS file.
- **Bulk time-off import**: Admin can paste CSV data to mass-create time-off entries.
- **Pending/denied entry styling**: Pending shown with dashed border + 50% opacity; denied with line-through + 35% opacity.
- **Upcoming time off on Home**: Personal 14-day lookahead widget on dashboard.

#### Asset Improvements
- **Depreciation/age tracking**: Configurable useful-life thresholds per asset type (5yr laptops, 7yr desktops, etc.). Aging Report modal.
- **Inventory discrepancy report**: Detects assets assigned to departed personnel and ghost assignments.
- **Assignment history timeline**: Visual chronological timeline for any hardware asset.
- **Duplicate assignment detection**: Utility warns if asset is already assigned to another person.
- **Bulk asset import**: Admin can paste CSV to mass-create hardware assets.

#### Facilities
- **Bulk seat import**: Admin can paste CSV with seat labels and X/Y coordinates for any room.
- **Facility capacity report**: Per-building occupancy % with vacancy counts.
- **Multi-floor navigation**: Utility function for floor number extraction.

#### Platform / Technical
- **Dark/light theme toggle**: Theme button in header, preference saved to localStorage. Full CSS theme with light-theme class.
- **Session timeout**: 30-minute inactivity timeout with 5-minute warning overlay. Resets on any user interaction.
- **Input sanitization**: sanitizeInput() utility strips script tags, javascript: URIs, and inline event handlers.
- **Soft-delete pattern**: softDeleteItem() utility marks records as archived instead of hard delete.
- **Expanded data quality checks**: Validates cross-list references (orphan org/person references).
- **Responsive design**: CSS breakpoints at 900px and 600px for tablet/mobile layouts.
- **Loading skeletons**: CSS shimmer animation classes for placeholder UI.
- **Print styles**: @media print stylesheet hides nav/chrome, forces white background, enables page breaks.

#### Reporting Module (New)
- **New "Reports" nav item** with dedicated route and report selector.
- **Headcount by org**: Table with total/active/departed per organization.
- **Training compliance by org**: Compliance % with color-coded thresholds.
- **Asset inventory**: Breakdown by type and status.
- **Time-off utilization**: Approved entries by month.
- **Request SLA compliance**: On-time rate and currently overdue count.
- **Data quality report**: Expanded checks with cross-list reference validation.

---

## [2026.04.02.2] - 2026-04-02

### Home Dashboard Professional Redesign
- **Welcome banner**: Personalized greeting with user's name, organization, position, grade, and role chips. Quick-action buttons for common tasks (New Request, Add Time Off, View Calendar, Export).
- **KPI strip**: 5-column metrics row showing People count, Open Requests, Training Compliance %, Active Assets, and In/Out Cases — each with colored progress bars and live data.
- **Priority Actions panel**: Displays overdue/urgent items including past-due requests and expiring training, with color-coded severity badges and direct-action links.
- **Team Availability widget**: Shows who in the user's section is out today (leave, TDY, training, telework) using time-off data with color-coded type badges. Integrates with Calendar module data.
- **Training Snapshot card**: At-a-glance view of team training status with compliance percentage, overdue count, and upcoming due items.
- **My Requests card**: Mini table of user's recent/open requests with status badges and priority indicators.
- **In/Out Processing card**: Summary of active in-processing and out-processing cases with step progress.
- **Notifications panel**: Aggregated alerts for items needing attention (expiring ATOs, overdue training, pending requests).
- **Quick Navigation grid**: Tile-based nav to all SPA modules with icons and descriptions, replacing the old plain link list.
- **Admin Health Summary**: Compact diagnostics overview (cache stats, queue depth, data quality) visible only to App Admin role.
- **New CSS system**: Complete `.dash-*` class hierarchy (`.dash-welcome`, `.dash-kpis`, `.dash-kpi`, `.dash-grid`, `.dash-card`, `.dash-action-item`, `.dash-req-row`, `.dash-nav-grid`, `.dash-nav-tile`, `.dash-team-row`) with glass-morphism styling consistent with the SPA's dark theme.

---

## [2026.04.02.1] - 2026-04-02

### Hardware & Software Asset Management Overhaul
- **Hardware asset detail modal**: Full asset view with all properties (name, type, manufacturer, model, serial, environment, portable, purchase date/cost, notes) plus complete assignment history table showing every person who has had the asset, when, and current status.
- **Software asset detail modal**: (accessible from hardware detail's software references)
- **Edit hardware assets** (admin): Modify device name, type, manufacturer, model, serial number, network environment, status, portable flag, purchase date/cost, and notes.
- **Edit software assets** (admin): Modify title, vendor, version, approved version, license type, total licenses, approval status, annual cost, ATO number/expiration, requires ATO, requires admin install, and notes.
- **Edit existing assignments** (admin): Modify environment, status, and notes on both hardware and software assignments without recreating them.
- **Unassign / return hardware**: Full return flow with return date, condition assessment (Good/Fair/Poor/Damaged/Missing), ticket reference, and return notes. Sets status to "Returned" with condition recorded.
- **Unassign software**: Revoke software assignment with date, ticket reference, and notes.
- **Transfer hardware**: One-step transfer from current person to new person. Automatically closes the old assignment (status: "Transferred") and creates a new active assignment for the recipient, preserving chain of custody with condition tracking and transfer notes.
- **Transfer software**: Same one-step transfer flow for software assignments.
- **Assignment detail modals**: Click "View" on any hardware or software assignment row to see full details with all fields, plus action buttons for Edit, Return/Unassign, and Transfer.
- **View buttons on all tables**: Hardware assignment table, software assignment table, and unassigned hardware table all now have View/Detail action buttons per row.
- **Asset status lifecycle**: Assignments now support statuses: Active, Assigned, In Service, Returned, Surplus, Transferred, Revoked.

---

## [2026.04.01.3] - 2026-04-01

### Calendar Module — Time Off, Federal Holidays, Senior Leaders
- **New "Calendar" tab**: Full calendar module added to navigation between Facilities and Assets (Alt+C shortcut).
- **Month view**: Traditional grid calendar showing all approved time-off entries with color-coded badges per person. Federal holidays displayed with red labels. Overflow indicator ("+N more") when days are busy.
- **Week view**: 7-column layout with day headers showing date numbers, full entries per day with name and type, federal holidays highlighted.
- **List view**: Chronological list of all time-off entries and holidays for the current month with color-coded type badges, date ranges, and notes preview.
- **Senior Leaders Calendar**: Dedicated view showing key leadership personnel (based on `IsKeyLeadership` positions or supervisor flag). Each leader card shows current status (In Office, on Leave, TDY, etc.) and upcoming 3 weeks of scheduled time off.
- **Organization scope filtering**: Dropdown to filter by any org/section — defaults to user's current section. Includes all descendant orgs in the filter. "Entire Organization" option shows everyone.
- **Type filtering**: Filter by time-off type (Annual Leave, Sick Leave, TDY, Training, Comp Time, Telework, LWOP, Other).
- **Name search**: Live search input to filter entries by person name.
- **Color-coded legend**: Static legend with consistent colors — Annual Leave (green), Sick Leave (pink), TDY (orange), Training (purple), Comp Time (blue), Telework (teal), Holiday (red), Other (gray).
- **Federal holidays**: Auto-calculated US OPM federal holiday schedule with observed date shifting (weekends → nearest weekday). Includes New Year's, MLK, Presidents' Day, Memorial Day, Juneteenth, Independence Day, Labor Day, Columbus Day, Veterans Day, Thanksgiving, Christmas.
- **Entry detail modal**: Click any entry to see full details (person, type, dates, hours, status, approver, notes).
- **Admin: Add time off entries**: "+" button opens form to create entries with person, type, date range, hours, status, and notes.
- **Admin: Delete entries**: Delete button available in entry detail modal.
- **SharePoint list**: New `CCSD_TimeOff` list with fields: Title, PersonID (lookup), OrgID (lookup), StartDate, EndDate, TimeOffType, Status, Hours, Notes, ApprovedBy, CreatedBy.

### TODO: Conference Room Scheduling
- Commented implementation plan added for `CCSD_ConferenceRooms` and `CCSD_RoomReservations` lists with room availability grid, booking, recurring meetings, and conflict detection.

### TODO: Microsoft Graph API — Outlook Calendar Integration
- Detailed commented implementation guide with Azure AD app registration steps, MSAL.js integration plan, Graph API getSchedule endpoint usage, and admin config panel design.

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
