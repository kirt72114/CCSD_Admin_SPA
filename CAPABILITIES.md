# CCSD Admin SPA — Current Capabilities

Living technical reference for what the CCSD Admin SPA can do **today**.
Scope is limited to shipped behavior in the current `Index.html` (v2026.04.22a).
Planned work lives in `TODO.md`; history lives in `CHANGELOG.md`.

- App file: `Index.html` (~16,800 lines, single-file SharePoint-safe SPA)
- Host: SharePoint Online (modern pages, via SPFx Script Editor web part)
- Runtime constraint: ES5-compatible, no build step, no npm at runtime
- Current version: `2026.04.22a`
- Deployed sites:
  - `usaf.dps.mil/teams/aetc-lak-cpsg/Database` (production)
  - `patriavirtus.sharepoint.com/sites/CCSDAdminSPA` (replica)

---

## 1. Platform & Technical Capabilities

### 1.1 Hosting & Deployment
- **Single-file SPA** served from SharePoint `SiteAssets/Scripts/Index.html`.
- **SPFx web part** (`spfx-script-editor/`) loads the file via XHR and renders it
  through `iframe.srcdoc` to bypass SharePoint's `Content-Disposition: attachment`
  header on raw `.html` files.
- **Multi-site auto-detection** — the `APP.sites` map chooses the correct root
  URL and site label from `window.location.hostname`, so the same file runs in
  production and replica without edits.
- **ES5-only** — no arrow functions, template literals, `let/const`, `Promise`
  shims are assumed present from the page context.
- **No external build** — CSS, JS, and markup are all in `Index.html`; CDN use
  is avoided on production DoD networks.

### 1.2 SharePoint REST layer
- Central `spGetJson` / `spPost` helpers with:
  - Form digest handling (acquire, cache, refresh on expiry)
  - Paginated list reads (`__next` follow)
  - Throttled retry on 429/503
  - Per-call diagnostic logging (correlation id, duration, status)
- **Schema awareness** — `buildSelectExpand()` inspects a registered column
  list and emits `$select=` / `$expand=` clauses sized to the current schema,
  so missing optional columns don't 500 the query.
- **Write payload builder** — `buildWritePayload()` shapes lookup ids into
  `FieldNameId`, multi-value lookups into `FieldNameId.results`, and person
  fields into the correct `FieldNameId` shape automatically.
- **Validation** — `showValidationErrors()` surfaces REST 400 errors as
  inline form messages instead of raw JSON.

### 1.3 Role-based access control (RBAC)
Roles live in the `CCSD_AppRoles` SharePoint list and are loaded on startup.
The registry (from `APP.roles`):

| Role | Summary |
|---|---|
| **App Admin** | Platform owner. Full configuration, diagnostics, role admin. Implies `Admin`. |
| **Admin** | Broad administrative access across personnel, requests, in/out. |
| **HR** | Edit personnel, drive in/out processing, enterprise personnel view. |
| **Supervisor** | Supervisor Hub, team in/out management. Auto-granted when `Personnel.IsSupervisor = true`. |
| **Training** | Review training submissions, see training-related requests. |
| **Security** | Create/manage security incidents and records. |
| **IT** | Enterprise IT request visibility. |
| **Facilities** | Enterprise facilities request visibility. |

Capability map (`APP.roles.capability`) gates UI and API actions:

| Capability | Allowed roles |
|---|---|
| `editPeople` | HR, Admin, App Admin |
| `reviewTraining` | Training, HR, Supervisor, Admin, App Admin |
| `seeAllRequests` | Admin, App Admin, HR, Training, Security, IT, Facilities |
| `manageInOut` | HR, Admin, App Admin, Supervisor |
| `seeAdmin` | App Admin |
| `manageSecurity` | Security, App Admin |
| `seeSupervisorHub` | Supervisor, App Admin |
| `manageRoles` | App Admin |
| `manageDuties` | Admin, App Admin, HR |

- **Scoped roles** — an Admin assignment can be restricted to a specific Org
  in `CCSD_AppRoles`; the derived scope also grants implicit Admin over all
  descendant organizations. `canAdminOrg()` / `canEditPerson(person)` layer the
  org scope on top of the capability check so a scoped Admin cannot mutate
  rows outside their branch.
- **Derived roles** — an active additional-duty assignment with an "Admin" role
  binding grants scoped Admin for the duration of the assignment.
- **Role chips** in the header surface the current user's roles and any
  derived Admin scopes (with the originating org names in the tooltip).

### 1.4 Audit & telemetry
- **`CCSD_AppAuditLog`** captures create / update / delete / view / export
  events across every module (user, timestamp, list, item id, action, details).
- **`CCSD_AppTelemetry`** captures performance, route changes, and error
  events. Both queues batch-flush on idle and on explicit Admin flush.
- **Self-test** button in Admin walks the most critical REST paths and reports
  pass/fail.

### 1.5 Data-quality engine
- `CCSD_DataQualityRules` defines declarative rules; the app runs them on
  demand from Admin or automatically on page load.
- Built-in checks: orphan org references, orphan person references, missing
  mandatory personnel fields, stale training records, ghost asset assignments,
  assets assigned to departed personnel.
- Home dashboard shows an aggregate **Data Quality** pill (click to open Admin).

### 1.6 UX / platform niceties
- **Dark / light theme** toggle, stored in `localStorage`.
- **Session timeout** — 30-minute inactivity with a 5-minute warning overlay;
  any user interaction resets the timer.
- **Fullscreen API** integration (toggles in/out, no new tab).
- **Responsive breakpoints** at 900 px / 600 px.
- **Print stylesheet** (`@media print`) hides nav chrome and forces page breaks.
- **Loading skeletons** with CSS shimmer animation.
- **Toast notifications** with severity levels (`info`, `warn`, `danger`).
- **Keyboard shortcuts** button exposes a cheat sheet (`?` modal).
- **Input sanitization** — `sanitizeInput()` strips script tags, `javascript:`
  URIs, and inline event handlers before any user input is persisted.
- **Soft delete** — `softDeleteItem()` marks records archived rather than
  destroying them, preserving audit history.
- **Projector-friendly** — intentional high-contrast palette and fuller labels
  (acronyms minimized in the UI layer).

---

## 2. Top-Level Navigation

Tabs rendered in `APP.nav`, in order. Admin, Diagnostics, and Supervisor Hub
are gated by the capability map above.

| Tab | Route | Gating | Purpose |
|---|---|---|---|
| Home | `home` | All users | KPI dashboard, activity, alerts |
| My Status | `mystatus` | All users | Personal profile, training, assets, requests |
| People | `people` | All users; edit gated | Personnel CRUD, onboarding, departure, transfer |
| Organizations | `organizations` | All users; edit gated | Org hierarchy, chart, contact cards |
| Training | `training` | All users | Catalog, submissions, records, SF-182 workflow |
| SF182 | `sf182` | All users | Dedicated SF-182 request workflow |
| Requests | `requests` | Filtered by role | Unified workflow engine for all ticket types |
| In/Out | `inout` | `manageInOut` | Case management + step queue |
| Facilities | `facilities` | All users; edit gated | Floor plans, seat map, POC cards |
| Calendar | `calendar` | All users | Month/Week/List, room scheduling, senior leaders |
| Assets | `assets` | All users; edit gated | Hardware + software inventory and assignment |
| Security | `security` | `manageSecurity` (and self-view) | Personnel security, incidents, SOR tracking |
| Duties | `duties` | All users; edit by `manageDuties` | Additional-duty assignments + letters |
| Reports | `reporting` | All users | Filter-based multi-format exports |
| Supervisor Hub | `supervisor` | `seeSupervisorHub` | Team roll-ups and action queue |
| Admin | `admin` | `seeAdmin` | Role admin, self-test, cache, telemetry |
| Diagnostics | `diagnostics` | `seeAdmin` | Runtime health, schema, recent errors |
| Help | `help` | All users | In-app documentation of roles + capabilities |

Hash-based routing (`#people`, `#calendar`…) makes every view linkable.

---

## 3. SharePoint Data Model

All data lives in the Database site. The production schema is **76 lists /
libraries, fully deployed** (audited 2026-04-18 via `database-audit-webpart.html`).

Canonical list registry (`APP.lists`):

### Core identity & structure
- `CCSD_Organizations`, `CCSD_Positions`, `CCSD_Personnel`
- `CCSD_Facilities`, `CCSD_Rooms`, `CCSD_Seats`
- `CCSD_InOutProcessing`, `CCSD_InOutChecklists`, `CCSD_InOutStepStatus`

### Training
- `CCSD_TrainingCatalog`, `CCSD_TrainingRecords`, `CCSD_TrainingSubmissions`
- `CCSD_SF182TrainingRequests`, `CCSD_SF182Library`
- `CCSD_TrainingCourseDataTypeCode`

### Requests & workflow
- `CCSD_AppRequests`, `CCSD_Workflows`, `CCSD_Templates`

### Assets
- `CCSD_HardwareAssets`, `CCSD_HardwareAssignments`
- `CCSD_SoftwareAssets`, `CCSD_SoftwareAssignments`
- `CCSD_Systems`

### Calendar & people operations
- `CCSD_TimeOff`
- `CCSD_ConferenceRooms`, `CCSD_RoomReservations`
- `CCSD_Announcements`

### Security
- `CCSD_SecurityRecords`, `CCSD_SecurityIncidents`
- `CCSD_IncidentStatusHistory`, `CCSD_IncidentActions`
- `CCSD_IncidentNotifications`, `CCSD_IncidentParties`
- `CCSD_SecurityContainers`, `CCSD_ContainerChecks`, `CCSD_AreaChecks`
- `CCSD_VisitorLog`, `CCSD_RestrictedAreas`, `CCSD_AreaAccessRoster`
- `CCSD_ClassifiedDocuments`, `CCSD_DestructionRecords`
- `CCSD_OPSECProgram`, `CCSD_DD254Registry`, `CCSD_ContractorPersonnel`

### Supervisor tooling
- `CCSD_PerformanceTracking`, `CCSD_TeleworkAgreements`, `CCSD_Awards`
- `CCSD_TaskAssignments`, `CCSD_DisciplinaryActions`
- `CCSD_OvertimeAuthorization`

### Additional duties
- `CCSD_DutyTypes`, `CCSD_AdditionalDuties`

### Notifications
- `CCSD_Notifications`, `CCSD_NotificationReceipts`

### Platform
- `CCSD_AppRoles`, `CCSD_AppTelemetry`, `CCSD_AppAuditLog`
- `CCSD_Config`, `CCSD_DataQualityRules`, `CCSD_HowTo`

---

## 4. Module Capabilities

### 4.1 Home Dashboard (`home`)
- KPI strip: active personnel, open requests, overdue trainings, unread
  notifications, version, environment pill.
- **Spotlight** stream mixing: new notifications, training expired / due soon,
  overdue and due-soon requests, ATO expired / expiring software, open
  in/out steps owned by the current user — each clickable, routes to the
  originating module.
- **My Upcoming Time Off** — personal 14-day lookahead widget for the current
  user, links directly to the Calendar.
- **Data Quality** pill — counts total and critical issues, click-through to
  Admin for resolution.
- Admin quick-launch buttons (Admin, Diagnostics) shown only when
  `canSeeAdmin()` returns true.

### 4.2 My Status (`mystatus`)
- Unified personal page for the logged-in user.
- Contact block, org chain with supervisor pill, current status, arrival /
  departure dates, projected losses if any.
- Personal training board: required / completed / due-soon / expired /
  missing with next-action buttons.
- Personal asset panel: hardware + software currently assigned.
- Personal requests: things you filed and things assigned to you.
- Personal time-off history + upcoming window.

### 4.3 People (`people`)
- Full personnel CRUD with schema-aware form.
- **Onboarding wizard** — stepwise intake that covers identity, org
  placement, supervisor, phones, education, AFSC, step, and notes, then
  writes to `CCSD_Personnel` in one pass.
- **Person detail modal** — 2-column layout showing contact, org, training
  records, time-off history, and assigned assets together.
- **Departure processing** — modal captures date, reason
  (PCS/Separation/Retirement/Transfer/Other) and notes, then marks the
  person `Departed`.
- **Organization transfer** — modal writes an effective-dated move to a new
  org/position.
- **Personnel CSV export** from the People view.
- Role-gated visibility: non-editors see a read-only roster; `editPeople`
  capability gates the mutation buttons per row, with scoped Admins
  restricted to their branch.

### 4.4 Organizations (`organizations`)
- **Org chart diagram** — interactive visualization built by
  `buildOrgChartIndex()` with focus / expand / collapse, depth-aware layout,
  and search that highlights matches in-place.
- **Above strip** — shows parent / grandparent context bands above the
  currently focused node.
- **Leadership rows** per org summarizing positions and incumbents.
- **Cards** under each org: people, positions, sub-orgs.
- **Contact cards** for orgs and POCs (POC pill renders as a clickable chip).
- **Create / edit organization** modal (admin-gated) with name, code, type,
  parent, email, active status.
- **Org dashboard** — per-org metrics: active personnel, training compliance %,
  active assets, open requests.
- **Merge / restructure** tool (admin-gated).
- **Print view** — dedicated print window with hierarchical layout, leader
  names, personnel counts, AETC-LAK CPSG branding.
- Org chart **search memo** speeds repeat queries.

### 4.5 Training (`training`)
- **Catalog** view of `CCSD_TrainingCatalog`.
- **Submissions** table with review actions for `reviewTraining` capability;
  submissions can include an attached **certificate upload** (PDF, images,
  Word, up to 10 MB via SharePoint REST attachment API).
- **Records** view with status derivation: Completed / Due Soon / Expired /
  Missing, plus expiration date math.
- **Bulk record entry** (admin) — paste a list of person IDs plus training
  + date to create records in bulk.
- **Certification expiration alerts** — utility function + Home widget for
  certs expiring within 60 days.
- **Training gap analysis** modal — compliance % per organization, sorted
  lowest-first.
- **SF-182 launch** — routes into the dedicated SF-182 view.

### 4.6 SF-182 (`sf182`)
- Dedicated view for training requests that require the SF-182 workflow.
- Linked into the unified request model while still maintaining dedicated
  SF-182 records (`CCSD_SF182TrainingRequests`).
- Supports request initiation, lifecycle tracking, role-specific approvals.
- Library list (`CCSD_SF182Library`) is wired for later document generation
  and storage.

### 4.7 Requests (`requests`)
- **Unified request engine** backing IT, hardware, software, seat-move,
  training, SF-182, facilities, security access, HR personnel actions, and
  general admin workflows.
- **6 built-in templates**: IT New Account, IT Hardware Issue, HR Personnel
  Action, Facilities Maintenance, Security Access Request, Training Course
  Request. Each template renders as structured labeled fields (text, select,
  date, textarea) rather than a text blob.
- **Request table** with search, type filter, status badges, priority,
  assignee, due date, and per-row View / Edit actions.
- **Detail view** with comment thread (visible when viewing, not just
  editing), status history, attachments.
- **SLA tracking** — visual indicator with color-coded days remaining /
  overdue.
- **Supervisor request dashboard** — modal showing team's requests with
  KPIs (total, open, overdue).
- Visibility: `seeAllRequests` roles see the full queue; everyone else sees
  their own filed + assigned items.

### 4.8 In / Out Processing (`inout`)
- **Case management** backed by `CCSD_InOutProcessing` with checklist
  templates from `CCSD_InOutChecklists` and per-step state in
  `CCSD_InOutStepStatus`.
- Opens an in- or out-processing case against a person; generates or
  associates the relevant checklist steps.
- **Step queue** view with filters (all / mine / open / overdue) and owner
  filter, visible to member, office, and supervisors.
- Supports in-processing, out-processing, transfers, and similar status
  changes.
- Category, Owning Office, From/To location, Losing/Gaining Org fields are
  structured dropdowns (not free-text).
- Gated by `manageInOut` capability.

### 4.9 Facilities (`facilities`)
- **Facility list** with POC pills (clickable contact cards), supporting
  multiple POCs per building.
- **Room detail** view with associated seats.
- **Seat map** rendering from `CCSD_Seats` with X/Y positioning on the
  room or floor-plan image.
- **Floor-plan view** — overlays an image with interactive seat markers.
- **Seat picker / editor** (admin-only) — drag to position, click to open the
  seat-edit modal, shift-drag for multi-select.
- **Room boundary drawing** — admins can draw room polygons onto a floor
  plan and persist them.
- **Seat tooltip** — on hover or pin-click, shows occupant, port, phone,
  NIPR / SIPR / JWICS indicators, and notes; includes contextual actions.
- **Bulk seat import** (admin) — paste CSV with labels and coordinates for
  any room.
- **Facility capacity report** — per-building occupancy % and vacancy counts.
- Cross-navigation: People → Seat Map deep-link and Seat → Person card.

### 4.10 Calendar (`calendar`)
- **Month / Week / List** views with multi-day event spanning.
- **Drag-to-create** new events directly on the grid.
- **Event types & legend**: Time Off, TDY, Training, Training Expiration,
  LWOP, Conference Room Booking, and configurable general events (each
  with its own color).
- **Conference room scheduling** view with recurring bookings.
- **Senior Leaders** view — filtered availability for leadership.
- **Pending / denied styling** — pending entries show dashed border + 50 %
  opacity; denied entries show line-through + 35 % opacity.
- **CSV + ICS export** of the current view.
- **Bulk time-off import** (admin) — paste CSV to mass-create time-off
  entries.
- Hooks for upcoming Microsoft Graph free/busy overlay (not yet wired; see
  Known Gaps).

### 4.11 Assets (`assets`)
- **Hardware inventory** — assets plus assignment history, so you can see
  both what exists and who currently holds it.
- **Software inventory** — approval status, approved versions, ATO metadata,
  requestability, and assignment status. Unclassified-only per design.
- **People × Assets** view — pick a person, see their hardware and software;
  pick an asset, see its history.
- **Assignment tables** with search across person ↔ asset pairs.
- **Grouped assignment sections** — hardware and software rendered in
  distinct tables per person.
- **Watchlist** — highlights ATO-expiring and ATO-expired software on the
  Home spotlight and in the Assets view.
- **License utilization card** — seats used vs. seats owned per software
  title.
- **Approved software catalog** — filtered view of vendor-approved titles.
- **Warranty tracking view** — hardware approaching end of warranty.
- **Version compliance view** — installed versions vs. approved version.
- **Cost center report** — rollup by cost center / org.
- **Location tracking view** — asset ↔ location map.
- **Depreciation / age tracking** — configurable useful-life thresholds per
  asset type (5 yr laptops, 7 yr desktops, etc.) with an Aging Report modal.
- **Inventory discrepancy report** — detects assets assigned to departed
  personnel and ghost assignments.
- **Assignment history timeline** — visual chronological view per asset.
- **Duplicate-assignment detection** — warns if the asset is already held by
  another person.
- **Inventory audit** step-by-step walker.
- **Bulk asset import** (admin) — paste CSV to mass-create hardware assets.
- **Software request** flow — submit via the unified request model.

### 4.12 Security (`security`)

Phases 1 and 2 (Personnel Security Core, Incident Management MVP) are shipped.
Phases 3–5 are scoped in `TODO.md` and not yet built.

- **Personnel security records roster** (`CCSD_SecurityRecords`) — clearance
  level, investigation type, dates, status.
- **Security supervisor view** — org roll-up of clearance posture.
- **Security member self-view** — any authenticated user can view their own
  record.
- **Incident management** — tabbed detail modal with:
  - Summary tab (status, classification, parties summary)
  - Timeline tab (status history, actions, notifications)
  - Actions tab (add/edit action items with owner + due date)
  - Comms tab (communications log)
  - Parties tab (subjects, witnesses, reporters, investigators)
  - Attachments tab (SharePoint REST attachment API)
  - **SOR tab** — Statement of Reasons workflow (SOR Issued →
    SOR Response Received → Appeal Filed → Appeal Decision → Resolved →
    Closed Favorable / Unfavorable / Resigned / Admin)
- **Bulk actions** on the incident panel.
- **Security admin panel** — config for security roles, notification
  templates, SOR statuses.
- **Integrated notifications** — 7 incident templates (NT-01 … NT-07) and
  3 SF-86 reminder templates (90 / 60 / 30 days).
- All security-related notifications default to **Sensitive** sensitivity
  and scrub bodies when routed to email.

### 4.13 Duties (`duties`)
- Catalog of duty types (`CCSD_DutyTypes`) and assignments
  (`CCSD_AdditionalDuties`).
- Assign, edit, end, and reappoint additional duties.
- **Letter generation** — `renderLetterHtml()` + `buildDocxFromHtml()` +
  `buildZipStored()` produce downloadable DOCX appointment and revocation
  letters fully client-side (ZIP + DOCX packaging without external libraries).
- Signer selection and custom body override in the generate-letter modal.
- Vacancy alerts feed into the notification center (`DutyVacancy` type).
- Scoped edits: `manageDuties` capability + per-org scope.

### 4.14 Reports (`reporting`)
- **Headcount report** — personnel counts by org / status / position type.
- **Training compliance report** — compliance % per org, overdue lists.
- **Asset inventory report** — hardware + software counts, assignment gaps.
- Filter-driven queries with **multi-format export** (CSV; ICS for calendar
  payloads).
- Same underlying data that feeds dashboards, so numbers reconcile.

### 4.15 Supervisor Hub (`supervisor`)
Gated by `seeSupervisorHub`; the tab is hidden for users who don't have it.

- **Team roster** with filters (status, org level, training posture).
- **Unified action queue** — overdue trainings, open requests, in/out steps,
  due clearances, and pending duty appointments, scoped to the supervisor's
  team.
- **Team availability grid** — calendar-style view of team time off.
- **Supervisor chain** resolver — walks up the `SupervisorID` graph from any
  person.
- **Team training** view with per-member compliance.
- Sub-trackers, each backed by its own list:
  - **DPMAP / Performance Tracking** (`CCSD_PerformanceTracking`)
  - **Manning** rollups
  - **Telework agreements** (`CCSD_TeleworkAgreements`)
  - **Awards** (`CCSD_Awards`)
  - **IDP** (individual development plans)
  - **Disciplinary actions** (`CCSD_DisciplinaryActions`)
  - **Overtime authorization** (`CCSD_OvertimeAuthorization`)
  - **Sponsorship** tracker
- **Reports** tab inside the hub for supervisor-level exports.

### 4.16 Admin (`admin`)
Gated by `seeAdmin` (App Admin only).

- **Exec strip** — environment, version, data-quality count, headcount,
  open requests at a glance.
- **Admin Controls** card with quick actions:
  - Run Self-Test
  - Flush Telemetry
  - Refresh All Caches
  - Data Quality Check
  - Print Current View
- **Runtime KV grid** — queued telemetry, queued audit, cached schemas,
  session id, environment, active site, root URL, hostname, known sites.
- **Role Admin card** — grant, edit, and deactivate role assignments in
  `CCSD_AppRoles`; supports scoped Admin (pick an org).

### 4.17 Diagnostics (`diagnostics`)
Gated by `seeAdmin`.

- Recent errors, REST diagnostics, schema snapshots for cached lists.
- Per-entry detail renderer (`buildDiagnosticDetailHtml`) for expanding a
  captured event.
- App version, root URL, hostname, and known sites.

### 4.18 Help (`help`)
- In-app documentation surfacing `APP.roles.registry` and
  `APP.roles.capabilityDocs` so users can see what their role unlocks.
- How-To library backed by `CCSD_HowTo`.
