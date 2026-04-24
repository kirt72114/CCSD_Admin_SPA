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
