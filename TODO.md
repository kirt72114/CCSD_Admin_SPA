# CCSD All-Things Administrative SPA — TODO

Master task list for pending features, improvements, and technical debt.
Updated: 2026-04-03

---

## Legend

- `[ ]` Not started
- `[~]` In progress / partial
- `[x]` Complete

**Priority:** P0 = Critical, P1 = High, P2 = Medium, P3 = Nice-to-have

**Owner Key:**
- 👤 = **You** (SharePoint admin, Azure AD, Power Automate, or manual data steps)
- 💻 = **Claude** (code changes in Index.html)
- 🤝 = **Both** (you do the prerequisite, Claude builds the feature)

---

## 1. Calendar Module Enhancements

### Conference Room Scheduling (P1) — 🤝

> **Prerequisite: You must create 2 SharePoint lists before code can be built.**

- [ ] **Create `CCSD_ConferenceRooms` list** — 👤
  1. Go to **Site Contents** > **New** > **List** > name it `CCSD_ConferenceRooms`
  2. Add these columns:
     | Column Name | Type | Notes |
     |-------------|------|-------|
     | Title | Single line (default) | Auto-generated display name |
     | RoomName | Single line of text | e.g. "Conf Room 201A" |
     | FacilityID | Lookup → CCSD_Facilities | Links room to a building |
     | Floor | Number | Floor number |
     | Capacity | Number | Max occupants |
     | HasProjector | Yes/No | Default: No |
     | HasVTC | Yes/No | Video teleconference capable |
     | HasPhone | Yes/No | Conference phone |
     | HasWhiteboard | Yes/No | |
     | Notes | Multiple lines of text | Plain text |
  3. Verify the list is accessible at `_api/web/lists/getbytitle('CCSD_ConferenceRooms')/items`

- [ ] **Create `CCSD_RoomReservations` list** — 👤
  1. Go to **Site Contents** > **New** > **List** > name it `CCSD_RoomReservations`
  2. Add these columns:
     | Column Name | Type | Notes |
     |-------------|------|-------|
     | Title | Single line (default) | Meeting subject |
     | ConferenceRoomID | Lookup → CCSD_ConferenceRooms | Which room |
     | ReservedBy | Person or Group | Who booked it |
     | StartTime | Date and Time | Include time |
     | EndTime | Date and Time | Include time |
     | Subject | Single line of text | Meeting title |
     | Notes | Multiple lines of text | Plain text |
     | IsRecurring | Yes/No | Default: No |
     | RecurrencePattern | Single line of text | e.g. "Weekly-Mon" (future use) |
     | Status | Choice | Choices: Confirmed, Cancelled |
  3. Verify the list is accessible via REST API

- [ ] **Build room availability grid** — 💻 (after lists exist)
- [ ] **Book / cancel reservation modals** — 💻
- [ ] **Recurring meeting support** — 💻
- [ ] **Conflict detection (double-booking prevention)** — 💻
- [ ] **Room search by capacity and equipment** — 💻
- [ ] **Room calendar view (per-room day/week timeline)** — 💻
- [ ] **Integration with Facilities module** — 💻

### Microsoft Graph API — Outlook Calendar Integration (P2) — 🤝

> **Requires Azure AD tenant admin actions before any code work can begin. This is likely the longest prerequisite chain in the entire TODO.**

- [ ] **Step 1: Azure AD App Registration** — 👤 (requires Global Admin or Application Admin role)
  1. Log into **Azure Portal** (portal.azure.com) with your tenant admin account
  2. Navigate to **Azure Active Directory** > **App registrations** > click **New registration**
  3. Fill in:
     - **Name**: `CCSD Administrative SPA`
     - **Supported account types**: "Accounts in this organizational directory only"
     - **Redirect URI**: Select **Single-page application (SPA)** and enter:
       - `https://usaf.dps.mil/teams/aetc-lak-cpsg/Database/SiteAssets/Scripts/Index.html`
     - Click **Register**
  4. On the app's overview page, add a second redirect URI if needed:
     - Go to **Authentication** > **Add URI** > add your dev/test site URL
  5. Go to **API permissions** > **Add a permission** > **Microsoft Graph** > **Delegated permissions**:
     - Search and add: `Calendars.Read.Shared`
     - Search and add: `User.Read`
  6. Click **Grant admin consent for [your tenant name]** (green checkmark should appear)
  7. **Copy and save these two values** (you'll give them to Claude):
     - **Application (client) ID** — on the Overview page
     - **Directory (tenant) ID** — on the Overview page

- [ ] **Step 2: Verify network access** — 👤
  1. From a workstation on the USAF network, open browser dev tools (F12) > Console
  2. Run: `fetch('https://graph.microsoft.com/v1.0/$metadata').then(r => console.log(r.status))`
  3. If you get a CORS error or network block, you'll need to work with your network team to whitelist `graph.microsoft.com` and `login.microsoftonline.com`
  4. **If blocked**: This feature cannot proceed — DoD networks sometimes block Graph API

- [ ] **Step 3: Provide Client ID and Tenant ID to Claude** — 👤
  - Once you have the two IDs from Step 1, share them so Claude can wire them into the APP config

- [ ] **Step 4: Build MSAL integration** — 💻 (after Step 3)
- [ ] **Step 5: Build free/busy schedule view** — 💻
- [ ] **Step 6: Add admin config panel for IDs** — 💻
- [ ] **Step 7: Token refresh and error handling** — 💻

### Calendar General Improvements (P2) — 💻

> **No prerequisites from you. These are all code-only changes.**

- [ ] Drag-to-create time-off entries (click + drag across days)
- [ ] Multi-day entry visual spanning (bar across days instead of per-day pills)
- [x] Print-friendly calendar layout (CSS print stylesheet) ✅ *v2026.04.03.1*
- [x] Export calendar to CSV / ICS format ✅ *v2026.04.03.1*
- [x] Bulk import time-off entries from CSV ✅ *v2026.04.03.1*
- [x] Pending/denied entries with visual distinction (strikethrough, muted) ✅ *v2026.04.03.1*
- [x] Notifications for upcoming time off (14-day lookahead on Home) ✅ *v2026.04.03.2*

---

## 2. Hardware / Software Asset Improvements

### Asset Lifecycle Management (P1)
- [x] Edit hardware asset modal ✅ *v2026.04.02.1*
- [x] Edit software asset modal ✅ *v2026.04.02.1*
- [x] Unassign / return flow with condition check ✅ *v2026.04.02.1*
- [x] Transfer assignment ✅ *v2026.04.02.1*
- [x] Asset status workflow ✅ *v2026.04.02.1*
- [x] Condition tracking ✅ *v2026.04.02.1*

- [x] **Depreciation / age tracking** ✅ *v2026.04.03.1* — Configurable useful-life thresholds per asset type, aging report modal.

### Inventory & Audit (P1) — 🤝

- [ ] **Add `LastAuditDate` column to `CCSD_HardwareAssets`** — 👤
  1. Go to **Site Contents** > open `CCSD_HardwareAssets` list
  2. **Add column** > **Date and Time** > name it `LastAuditDate`
  3. Set "Include Time" to **No** (date only)

- [ ] **Add `LastAuditBy` column to `CCSD_HardwareAssets`** — 👤
  1. Same list > **Add column** > **Person or Group** > name it `LastAuditBy`

- [ ] **Build inventory audit mode** — 💻 (after columns exist)
  - Checklist-style walkthrough of all assets, mark each Verified / Missing / Damaged

- [ ] **Build audit history log** — 💻
  - Records who audited, when, what status was found (uses existing AppAuditLog list)

- [ ] **Barcode / asset tag scanning** — 👤 + 💻
  - **Your decision needed**: This requires camera access via the browser. SharePoint Online pages *can* use `getUserMedia()` but your network security policy may block it. Test by visiting any website that requests camera access from a work machine.
  - If camera works: Claude can build a barcode scanner using a JS library (QuaggaJS or ZXing)
  - If camera is blocked: Skip this — manual asset tag entry is the fallback

- [x] **Inventory discrepancy report** ✅ *v2026.04.03.1* — Detects departed assignees and ghost assignments.

### Software Governance (P2) — 🤝

- [ ] **Add `TotalLicenses` column to `CCSD_SoftwareAssets`** — 👤
  1. Open `CCSD_SoftwareAssets` list
  2. **Add column** > **Number** > name it `TotalLicenses`
  3. This tells the system how many licenses you own per title

- [ ] **License utilization dashboard** — 💻 (after column exists)
- [ ] **Software request workflow** — 💻
- [ ] **ATO expiration alerts on Home** — 💻 (no prereqs)
- [ ] **Approved software catalog view** — 💻 (no prereqs)
- [ ] **Version compliance check** — 💻 (no prereqs)

- [ ] **Add `CostCenter` column to `CCSD_HardwareAssets` and `CCSD_SoftwareAssets`** — 👤
  1. Open each list > **Add column** > **Single line of text** > name it `CostCenter`

- [ ] **Cost center reporting** — 💻 (after columns exist)

### Hardware Tracking (P2) — 🤝

- [ ] **Add `WarrantyExpiration` column to `CCSD_HardwareAssets`** — 👤
  1. Open `CCSD_HardwareAssets` > **Add column** > **Date and Time** > name it `WarrantyExpiration`
  2. Set "Include Time" to **No**

- [ ] **Warranty tracking & alerts** — 💻 (after column exists)

- [ ] **Add `PhysicalLocation` column to `CCSD_HardwareAssets`** — 👤
  1. Open `CCSD_HardwareAssets` > **Add column** > **Single line of text** > name it `PhysicalLocation`
  2. Values like "Bldg 500 / Rm 201" or "Mobile"

- [ ] **Location tracking** — 💻 (after column exists)

- [ ] **Add `ExpectedReturnDate` column to `CCSD_HardwareAssignments`** — 👤
  1. Open `CCSD_HardwareAssignments` > **Add column** > **Date and Time** > name it `ExpectedReturnDate`

- [ ] **Check-out / check-in for portable devices** — 💻 (after column exists)

- [x] Asset detail page ✅ *v2026.04.02.1*

- [x] **Bulk asset import from CSV** ✅ *v2026.04.03.1*

### Assignment Improvements (P2) — 💻

> **No prerequisites from you. All code-only.**

- [x] Edit existing assignments ✅ *v2026.04.02.1*
- [x] Assignment history timeline (visual timeline view) ✅ *v2026.04.03.1*
- [ ] Seat-to-asset auto-suggestion
- [x] Duplicate assignment detection ✅ *v2026.04.03.1*

---

## 3. People Module Improvements — 💻

> **No prerequisites from you. All fields already exist in `CCSD_Personnel`.**

- [x] **Edit personnel modal** ✅ *existed prior*
- [x] **Person detail page** — unified view with assets, training, time off, org chain ✅ *v2026.04.03.1*
- [ ] **Photo / avatar support** — 👤 decision needed:
  - Option A: Use SharePoint profile photos (automatic if users have O365 profiles with photos)
  - Option B: Add a `PhotoUrl` column to `CCSD_Personnel` for manual upload
  - **Let Claude know which approach you prefer**
- [ ] **Personnel onboarding wizard** — guided flow to create person + seat + assets
- [x] **Departure processing** — mark departed with date/reason/notes ✅ *v2026.04.03.1*
- [x] **Org transfer workflow** — move person between orgs ✅ *v2026.04.03.1*
- [x] **Personnel export to CSV** ✅ *v2026.04.03.1*

---

## 4. Organization Module Improvements — 💻

> **No prerequisites from you. Uses existing `CCSD_Organizations` list.**

- [x] Create / edit organization modal (admin only) ✅ *v2026.04.03.1*
- [ ] Org merge / restructure tool
- [x] Org dashboard (headcount, training %, asset count, open requests per org) ✅ *v2026.04.03.1*
- [ ] Org contact card (expanded info)
- [x] Org chart print layout ✅ *v2026.04.03.1* — redesigned with professional print window *v2026.04.03.3*

---

## 5. Training Module Improvements — 💻

> **No prerequisites from you. Uses existing `CCSD_Training` and `CCSD_TrainingRecords` lists.**

- [ ] Training calendar integration (show on Calendar module)
- [x] Bulk training record entry (admin CSV upload) ✅ *v2026.04.03.1*
- [x] Training gap analysis per org ✅ *v2026.04.03.1*
- [x] Certification expiration alerts on Home (60-day warnings) ✅ *v2026.04.03.2*
- [ ] Training request workflow (person requests → supervisor approves → SF182 auto-created)

---

## 6. Requests / Workflow Improvements — 🤝

- [x] **Request comments thread UI** ✅ *v2026.04.03.1* — visible in both detail and edit views

- [ ] **Email notification integration** — 👤 + 💻
  - **Option A — Power Automate (recommended, no code changes needed):**
    1. Go to **Power Automate** (flow.microsoft.com)
    2. Create a new **Automated cloud flow**
    3. Trigger: "When an item is created or modified" → select `CCSD_Requests` list
    4. Condition: Status changed (use "Trigger Conditions" or a Condition action)
    5. Action: "Send an email (V2)" via Office 365 Outlook connector
    6. Repeat for `CCSD_TrainingRecords` (expiry alerts) and `CCSD_SoftwareAssets` (ATO alerts)
  - **Option B — Graph API (requires the Azure AD app from Section 1):**
    - Claude can build in-app email sending, but this requires the same Azure AD setup plus `Mail.Send` permission
  - **Your decision**: Which option do you prefer?

- [x] **Request dashboard for supervisors** ✅ *v2026.04.03.1*
- [x] **SLA compliance tracking** — visual indicator on detail view ✅ *v2026.04.03.1*
- [x] **Request templates** — 6 built-in templates with structured input fields ✅ *v2026.04.03.1, enhanced v2026.04.03.3*

---

## 7. Facilities Module Improvements — 💻

> **No prerequisites from you. All code-only changes.**

- [ ] Room booking integration with Calendar conference room scheduling (depends on Section 1 lists)
- [x] Floor plan: bulk seat import from CSV ✅ *v2026.04.03.1*
- [ ] Floor plan: room boundary overlays (draw room outlines)
- [x] Multi-floor navigation (getFloorNumbers utility) ✅ *v2026.04.03.1*
- [x] Facility capacity reporting (occupancy % per building) ✅ *v2026.04.03.1*

---

## 8. Home Dashboard Improvements

- [x] **My upcoming time off** widget ✅ *v2026.04.03.2*
- [x] My team's availability widget ✅ *v2026.04.02.2*
- [x] My pending requests widget ✅ *v2026.04.02.2*
- [x] My training due soon widget ✅ *v2026.04.02.2*
- [x] Priority Actions panel ✅ *v2026.04.02.2*
- [x] KPI strip ✅ *v2026.04.02.2*
- [x] Quick Navigation tile grid ✅ *v2026.04.02.2*
- [x] Notifications panel ✅ *v2026.04.02.2*
- [x] Admin Health Summary ✅ *v2026.04.02.2*

- [ ] **Announcements / news banner** — 🤝
  1. 👤 Create `CCSD_Announcements` list (see Section 11 below for columns)
  2. 💻 Build the banner component after list exists

- [ ] **Quick links section** — 💻 (no prereqs, can use hardcoded links initially)

---

## 9. Platform / Technical Improvements

### Performance (P2) — 💻

> **No prerequisites from you.**

- [ ] Lazy module loading (query lists only when module first visited)
- [ ] List data pagination (handle 5000+ item lists via paging tokens)
- [ ] Debounced calendar re-render

### UX (P2) — 💻

> **No prerequisites from you.**

- [x] Dark/light theme toggle ✅ *v2026.04.03.2* — persisted to localStorage
- [x] Responsive design audit (tablet/mobile CSS breakpoints) ✅ *v2026.04.03.1*
- [x] Loading skeletons (CSS animations) ✅ *v2026.04.03.1*
- [x] Breadcrumb navigation (CSS) ✅ *v2026.04.03.1*
- [ ] Undo toast actions
- [ ] Keyboard navigation (arrow keys in calendar, tab through tables)

### Security (P1) — 💻

> **No prerequisites from you.**

- [ ] Audit all CRUD operations (ensure AppAuditLog coverage)
- [ ] Role-based field visibility (hide sensitive fields from non-supervisors)
- [x] Session timeout (30min with 5min warning overlay) ✅ *v2026.04.03.2*
- [x] Input sanitization utility (sanitizeInput function) ✅ *v2026.04.03.2*

### Data Integrity (P2) — 💻

> **No prerequisites from you.**

- [x] Expand data quality checks (orphan org/person references) ✅ *v2026.04.03.2*
- [ ] Scheduled data quality report (surface on Home)
- [x] Archive / soft-delete pattern (softDeleteItem utility) ✅ *v2026.04.03.2*

---

## 10. Reporting (P3) — 💻

> **No prerequisites from you. All code-only.**

- [x] Headcount by org report with drill-down ✅ *v2026.04.03.2*
- [x] Training compliance report by org/section ✅ *v2026.04.03.2*
- [x] Asset inventory report (by type, status) ✅ *v2026.04.03.2*
- [x] Time-off utilization report (by month) ✅ *v2026.04.03.2*
- [x] Request SLA compliance report ✅ *v2026.04.03.2*
- [x] Dashboard print view (print-optimized CSS) ✅ *v2026.04.03.1*
- [ ] Scheduled report email — 🤝 (requires Power Automate, see Section 6 notes)

---

## 11. UI/UX & Bug Fixes (v2026.04.03.3) — 💻

> **Completed in this session. All code-only changes.**

- [x] **Dark mode contrast boost** ✅ *v2026.04.03.3* — Significantly darker backgrounds, brighter text, stronger borders
- [x] **App layout condensed** ✅ *v2026.04.03.3* — Reduced padding/margins/fonts to fit at 100% zoom without scrollbar
- [x] **True browser Fullscreen API** ✅ *v2026.04.03.3* — Button uses requestFullscreen/exitFullscreen, always visible
- [x] **Facilities POC [object Object] fix** ✅ *v2026.04.03.3* — Handles Person/Group lookup fields, contact card on click, multiple POCs
- [x] **Certificate upload on training submissions** ✅ *v2026.04.03.3* — File input (PDF/image/Word, 10MB max), SharePoint attachment API
- [x] **In/Out Processing dropdowns** ✅ *v2026.04.03.3* — Category and Owning Office are now dropdowns, added From/To locations and Losing/Gaining Org for transfers
- [x] **Request template structured fields** ✅ *v2026.04.03.3* — Each template type has dedicated labeled input fields instead of text blobs
- [x] **Organizations print view redesign** ✅ *v2026.04.03.3* — Professional print layout in new window with hierarchy, leaders, and personnel counts

### SPFx Script Editor Web Part (v2026.04.03.4)

> **Completed in this session.**

- [x] **SPFx web part created** ✅ *v2026.04.03.4* — `spfx-script-editor/` project scaffolded with SPFx 1.18.2
- [x] **AJAX + srcdoc rendering** ✅ *v2026.04.03.4* — Fetches HTML via XHR, renders with `iframe.srcdoc` to bypass SharePoint download headers
- [x] **ASP.NET directives reverted** ✅ *v2026.04.03.4* — Removed `<%@ Page %>` directives from Index.html
- [x] **Tenant App Catalog deployed** ✅ *v2026.04.03.4* — `.sppkg` uploaded and published
- [x] **Replica site verified** ✅ *v2026.04.03.4* — App loads at patriavirtus.sharepoint.com with hostname auto-detection

### SharePoint Column Recommendations (Optional)

> **These are optional columns to persist the new In/Out Processing fields natively. Currently stored in the Notes field.**

| List | Column | Type | Notes |
|------|--------|------|-------|
| `CCSD_InOutProcessing` | `FromLocation` | Single line of text | Prior base/unit/location |
| `CCSD_InOutProcessing` | `ToLocation` | Single line of text | Gaining base/unit/location |
| `CCSD_InOutProcessing` | `LosingOrgID` | Lookup → CCSD_Organizations | Org member is leaving |
| `CCSD_InOutProcessing` | `GainingOrgID` | Lookup → CCSD_Organizations | Org member is joining |

**How to add**: Site Contents → open `CCSD_InOutProcessing` → Add column. Once created, let Claude know and the code will be updated to write to these columns directly instead of the Notes field.

---

## 12. Security Module (P1) — 🤝

> **New major feature. Adds a full Security section to the SPA covering personnel security status, incident management, notifications, and compliance tracking. Requires new SharePoint lists, new roles, and a monthly data ingestion workflow.**

### Known Requirements

> **These are confirmed by the project owner and can be implemented without further discovery.**

#### 12a. Access, Visibility & Privacy Controls — 💻

- [ ] **New "Security" nav tab** — Add to main navigation between existing modules. Visible to all authenticated users but content is scoped by role.
- [ ] **Self-view default** — When a non-privileged user navigates to Security, they see ONLY their own security record. No list of other members is visible.
- [ ] **Obscured-by-default display** — Sensitive fields (clearance level, investigation dates, eligibility status, incident history) are masked on initial load (e.g., `●●●●●●` or `[Click to reveal]`). User must explicitly click to reveal their own data.
- [ ] **Security role access** — Users with the `Security` role (via `CCSD_AppRoles`) can view and edit security records for anyone in the organization. They see the full member roster with search/filter.
- [ ] **App Admin role access** — Users with `App Admin` role have the same access as the Security role.
- [ ] **Supervisor limited view** — Supervisors can see a summary security status (clearance level + current/expired/suspended) for their direct reports only. They CANNOT see investigation details, incident records, or SF-86 dates.
- [ ] **No cross-org visibility** — Security role holders scoped to an org (via `ScopeOrgID` on `CCSD_AppRoles`) can only see members within that org and its descendants.
- [ ] **Audit logging for all access** — Every view, reveal, edit, and export of security data must be logged to `CCSD_AppAuditLog` with the viewer's identity, timestamp, and which record was accessed.

#### 12b. Member Self-Service Security View — 💻

- [ ] **Personal security status card** — Dashboard-style card showing the member's own:
  - Current clearance level and status (Active, Interim, Expired, Suspended, None)
  - Investigation type (T1/T3/T5) and date of last investigation
  - Continuous Vetting enrollment status
  - SF-86 last submission date and next due date (calculated: last submission + 5 years)
  - Access determinations (NIPR/SIPR/JWICS/SCI access granted)
  - SF-312 (NDA) signed date
  - Security training compliance (Initial briefing, Annual refresher, Derivative classification — dates and current/expired status)
- [ ] **Reveal interaction** — Each sensitive field group has a "Show" toggle. Clicking it reveals the data and logs the reveal event to the audit log.
- [ ] **Read-only for members** — Non-Security, non-Admin users cannot edit any security data. All fields are display-only.
- [ ] **Incident summary (own only)** — Member can see their own incident records (case number, status, date opened, date closed). They CANNOT see the detailed description or investigation notes — only the obscured case number and current status.
- [ ] **No export for members** — Members cannot export or print their security data from the self-service view.

#### 12c. Security Admin Management View — 💻

- [ ] **Full roster view** — Security role users see a searchable, filterable, sortable table of all personnel with key security columns (name, org, clearance level, status, investigation type, PR due date, days until due).
- [ ] **Inline status indicators** — Color-coded: Green = current, Yellow = PR due within 90 days, Red = expired/overdue/suspended.
- [ ] **Edit security record modal** — Full form to create or update a member's security record. All fields editable. Changes logged to audit log with before/after snapshots.
- [ ] **Bulk status view** — Summary statistics: total cleared, by level (Confidential/Secret/TS/SCI), expired count, interim count, PR overdue count.
- [ ] **Security compliance dashboard** — Per-org breakdown of clearance currency, training compliance, and incident counts. Drillable to individual records.
- [ ] **Export capability** — Security role users can export security roster to CSV (with audit log entry for the export event).

#### 12d. Monthly Excel Import / Data Ingestion — 🤝

> **Security data originates from DISS and is provided as a monthly Excel spreadsheet. The app must ingest this data to keep records current.**

- [ ] **Upload interface** — Security role users can upload an Excel file (.xlsx) via a file input in the Security admin view.
- [ ] **👤 Define Excel column mapping** — You (the admin) need to provide a sample Excel file so that column headers can be mapped to SharePoint fields. Claude will build the parser once the format is known.
- [ ] **Column mapping configuration** — Admin-configurable mapping between Excel column headers and `CCSD_SecurityRecords` fields. Stored in `CCSD_Config` so it survives code updates.
- [ ] **Preview before commit** — After upload, show a preview table of parsed rows with a diff indicator (new records, changed records, unchanged records). Admin confirms before writing to SharePoint.
- [ ] **Upsert logic** — Match incoming rows to existing records by a unique key (likely PersonID or SSN-last-4 + name). Update existing records; create new ones; flag records in SharePoint that are NOT in the upload (possible departures).
- [ ] **Upload history** — Log each upload event (date, uploaded by, row count, records created/updated/unchanged) to the audit log.
- [ ] **Excel parsing** — Use client-side JavaScript Excel parsing (SheetJS/xlsx library via CDN or inline). No server-side processing.
  - **⚠️ Dependency:** Verify that the SheetJS CDN is accessible from the production network (`usaf.dps.mil`). If blocked, the library must be inlined into Index.html.

#### 12e. Incident & Case Management — 💻

- [ ] **New incident form** — Security role users can create a new security incident record with:
  - Subject member (lookup to `CCSD_Personnel`)
  - Incident category (choices TBD — see "Needs Research" below)
  - Date of incident / date reported
  - Description (rich text, visible only to Security role)
  - Severity / priority
  - Reporting source (self-report, supervisor, automated/CV alert, external)
  - Initial status: `Reported`
- [ ] **Case number generation** — Each incident gets a unique, obscured case number that does NOT reveal the subject's identity or the nature of the incident. Format: `SEC-[YEAR]-[SEQUENTIAL]` (e.g., `SEC-2026-0042`). This case number is what appears in notifications.
- [ ] **Incident lifecycle / status tracker** — Visual step-by-step progress indicator showing the current phase. States:
  - `Reported` → `Under Review` → `Investigation Initiated` → `Investigation Complete` → `Command Review` → `Adjudication` → `Resolved` → `Closed`
  - Additional terminal states: `No Action Required`, `Referred to External Agency`
  - Each state transition is logged with who changed it, when, and any notes.
- [ ] **Incident detail view** — Full detail modal for Security role users showing all fields, status history timeline, attached documents, and notification log.
- [ ] **Member-facing incident view** — The subject member sees ONLY: case number, current status, date opened, date closed (if applicable). No description, no investigation notes, no category. Displayed on their self-service security card.
- [ ] **Status change notifications** — When an incident's status changes, the subject member receives an in-app notification referencing only the case number and new status (e.g., "Case SEC-2026-0042 status updated to: Under Review").
- [ ] **Incident attachment support** — Ability to attach documents (PDFs, images) to an incident record using the existing `attachFileToListItem()` API pattern from training submissions.
- [ ] **Incident resolution** — When an incident reaches `Resolved` or `Closed`, capture: resolution date, resolution summary, outcome (e.g., No Action, Corrective Action, Access Suspended, Access Revoked, Referred).

#### 12f. Notifications & Recurring Reminders — 🤝

> **The app needs a notification framework that supports scheduled, recurring, and ad-hoc notifications to individuals, branches, or the entire organization.**

##### SF-86 Due Date Tracking

- [ ] **SF-86 due date calculation** — For each member with a security record, calculate: `LastSF86SubmissionDate + 5 years = NextSF86DueDate`. Display on the security card and in the admin roster.
- [ ] **SF-86 reminder notifications** — Generate in-app notifications at configurable intervals before the due date:
  - 365 days before (1 year warning)
  - 180 days before (6 month warning)
  - 90 days before (3 month warning)
  - 30 days before (1 month warning — urgent)
  - On the due date (overdue)
  - Weekly after overdue
- [ ] **SF-86 reminder recipients** — Notifications go to: the member, their supervisor, and the Security role holders for that org.

##### Security Representative → Member Notifications

- [ ] **Daily notification capability** — Security role users can send a notification to a specific member that appears in their in-app notification panel. The notification text is authored by the security representative.
- [ ] **Incident-linked notifications** — When sending a notification related to an incident, the security rep selects the case number. The notification text references only the case number, not incident details.
- [ ] **Notification templates** — Pre-built notification templates for common scenarios:
  - "Action required: Please contact the security office regarding case [CASE_NUMBER]"
  - "Reminder: Your periodic reinvestigation is due in [N] days"
  - "Your security training [TRAINING_NAME] expires on [DATE]"
  - Custom free-text (with character limit)

##### Organization / Branch / Individual Framework

- [ ] **Send to individual** — Select a specific person from the roster and send a notification.
- [ ] **Send to branch/org** — Select an organization from `CCSD_Organizations` and send to all active members in that org and its descendants.
- [ ] **Send to all** — Broadcast to the entire organization (requires Security role or App Admin).
- [ ] **Notification delivery** — All notifications appear in the existing in-app notification panel on the Home dashboard. Each notification has:
  - Title, body text, timestamp, read/unread status, sender name
  - Optional link to the relevant security record or incident
- [ ] **Notification log** — All sent notifications are logged to a new `CCSD_Notifications` list (see SharePoint list requirements below) for audit purposes.

#### 12g. Permissions, Privacy & Audit Logging — 💻

- [ ] **Role enforcement in API calls** — Every REST API call for security data must check the caller's role before returning results. Enforce at the query level (filter by PersonID for members, unfiltered for Security/Admin roles).
- [ ] **No client-side-only gating** — Security visibility rules must be enforced at the data query level, not just by hiding UI elements. If a non-privileged user inspects network traffic, they must not see other members' security data.
- [ ] **Audit log coverage** — The following events must be logged to `CCSD_AppAuditLog`:
  - Security record viewed (who viewed whose record)
  - Security record field revealed (obscured → visible)
  - Security record created or edited (before/after snapshot)
  - Security data exported (who, when, row count)
  - Excel upload performed (who, when, file name, row count, records affected)
  - Incident created, status changed, or closed
  - Notification sent (sender, recipient(s), notification text, case number if applicable)
- [ ] **Data retention** — Incident records and notification logs should not be hard-deletable. Use the existing `softDeleteItem()` pattern for archival.
- [ ] **Session security** — Security module inherits the existing 30-minute session timeout with 5-minute warning overlay.

#### 12h. Reporting & Dashboards — 💻

- [ ] **Security compliance report** — Org-level breakdown: total personnel, cleared count by level, PR current/due/overdue, training compliance %, active incident count.
- [ ] **SF-86 due date report** — List of all members with upcoming PR due dates, sortable by date, filterable by org.
- [ ] **Incident summary report** — Count of incidents by status, category, org, and time period. No PII in the summary view.
- [ ] **Security training compliance matrix** — Grid showing each team member vs. required security trainings (Initial briefing, Annual refresher, Derivative classification, CI awareness, Insider threat, CUI training) with current/expired/due status.
- [ ] **Add to Reports module** — Integrate security reports into the existing Reports nav section (Section 10).

### Needs Research / Validation

> **These items require further discovery — either from the project owner providing details, from reviewing governing regulations (SEAD 3, SEAD 4, DoDM 5200.02, AFI 16-1406), or from inspecting sample DISS Excel exports.**

- [ ] **🔬 DISS Excel export format** — Need a sample monthly Excel file to determine: exact column headers, data types, unique key field, and how to map to SharePoint columns. This blocks the Excel import feature.
- [ ] **🔬 Incident categories** — The specific list of incident categories (SEAD 3 reportable events, security violations, spillages, unauthorized disclosures, etc.) needs to be defined. Placeholder choices will be used until confirmed.
- [ ] **🔬 Incident resolution steps** — The exact step-by-step lifecycle may vary depending on incident type. The current linear status model (`Reported` → `Closed`) may need branching paths (e.g., some incidents go directly to external referral, some require SOR/appeal). Needs validation against SEAD 3/4 processes.
- [ ] **🔬 Notification delivery method** — Currently planned as in-app only. Determine whether email notifications via Power Automate are required in addition. If so, this depends on the Power Automate integration in Section 13.
- [ ] **🔬 Continuous Vetting (CV) tracking** — Under Trusted Workforce 2.0, periodic reinvestigations are being replaced by continuous vetting. Determine whether the 5-year SF-86 cycle still applies to the CPSG population or if CV enrollment changes the tracking model.
- [ ] **🔬 SCI/SAP access tracking** — Determine whether SCI and SAP access eligibility need separate tracking from collateral clearances, and whether the Security module should track these.
- [ ] **🔬 Physical security features** — Determine whether key control, security container (SF-700/702) tracking, or visitor control should be part of this module or a separate future module.
- [ ] **🔬 Information security features** — Determine whether classification management, CUI handling, or spillage tracking should be part of this module.
- [ ] **🔬 OPSEC integration** — Determine whether OPSEC program compliance (Critical Information List, OPSEC assessments) should be tracked here.
- [ ] **🔬 Industrial security / contractor tracking** — Determine whether DD-254 tracking or contractor clearance management is in scope.

### SharePoint Lists Required — 👤

> **These lists must be created before the Security module can be built.**

#### `CCSD_SecurityRecords` — NEW

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Auto-populated, e.g., "Smith, John - TS/SCI" |
| PersonID | Lookup → CCSD_Personnel | The member this record belongs to |
| ClearanceLevel | Choice | `None`, `Confidential`, `Secret`, `Top Secret`, `TS/SCI` |
| ClearanceStatus | Choice | `Active`, `Interim`, `Expired`, `Suspended`, `Revoked`, `Denied`, `Not Cleared` |
| InvestigationType | Choice | `T1`, `T2`, `T3`, `T4`, `T5`, `T5R`, `CE/CV` |
| InvestigationDate | Date | Date of most recent investigation completion |
| LastSF86Date | Date | Date of most recent SF-86 submission |
| NextSF86DueDate | Date | Calculated: LastSF86Date + 5 years (can be manually overridden) |
| CVEnrolled | Yes/No | Enrolled in Continuous Vetting |
| NIPRAccess | Yes/No | Has NIPR access determination |
| SIPRAccess | Yes/No | Has SIPR access determination |
| JWICSAccess | Yes/No | Has JWICS access determination |
| SCIAccess | Yes/No | Has SCI access |
| NDASignedDate | Date | SF-312 NDA signed date |
| InitialBriefingDate | Date | Date of initial security briefing |
| AnnualRefresherDate | Date | Date of most recent annual refresher |
| DerivedClassDate | Date | Date of most recent derivative classification training |
| SourceFile | Single line of text | Name of the Excel file this record was last updated from |
| LastImportDate | Date | When this record was last updated via Excel import |
| Notes | Multiple lines of text | |

#### `CCSD_SecurityIncidents` — NEW

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Auto-populated with case number |
| CaseNumber | Single line of text | Generated: `SEC-[YYYY]-[NNNN]` |
| PersonID | Lookup → CCSD_Personnel | Subject of the incident |
| ReportedBy | Lookup → CCSD_Personnel | Who reported it |
| IncidentCategory | Choice | Placeholder choices — see "Needs Research" above |
| IncidentDate | Date | Date the incident occurred |
| ReportedDate | Date | Date the incident was reported |
| Severity | Choice | `Low`, `Medium`, `High`, `Critical` |
| ReportingSource | Choice | `Self-Report`, `Supervisor`, `Automated/CV`, `External Agency`, `Anonymous` |
| Status | Choice | `Reported`, `Under Review`, `Investigation Initiated`, `Investigation Complete`, `Command Review`, `Adjudication`, `Resolved`, `Closed`, `No Action Required`, `Referred to External Agency` |
| Description | Multiple lines of text | Visible only to Security role |
| InvestigationNotes | Multiple lines of text | Visible only to Security role |
| ResolutionDate | Date | |
| ResolutionSummary | Multiple lines of text | Visible only to Security role |
| Outcome | Choice | `No Action`, `Corrective Action Taken`, `Access Suspended`, `Access Revoked`, `Clearance Denied`, `Referred`, `Other` |
| StatusHistoryJSON | Multiple lines of text | JSON array of status transitions with timestamps and actors |
| OrgID | Lookup → CCSD_Organizations | Member's org at time of incident |
| Notes | Multiple lines of text | |

#### `CCSD_Notifications` — NEW

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Notification title/subject line |
| NotificationType | Choice | `Security`, `SF86 Reminder`, `Incident Update`, `Training Reminder`, `General`, `Broadcast` |
| Body | Multiple lines of text | Notification body text |
| SentBy | Lookup → CCSD_Personnel | Who sent it |
| RecipientType | Choice | `Individual`, `Organization`, `All` |
| RecipientPersonID | Lookup → CCSD_Personnel | If individual (nullable) |
| RecipientOrgID | Lookup → CCSD_Organizations | If organization-scoped (nullable) |
| RelatedCaseNumber | Single line of text | If linked to a security incident (nullable) |
| SentDate | Date and Time | |
| IsRead | Yes/No | Per-recipient read tracking (see note below) |
| Notes | Multiple lines of text | |

> **Note:** `IsRead` tracking for broadcast/org notifications requires either a separate `CCSD_NotificationReceipts` list (one row per recipient per notification) or a JSON field. Detailed design TBD during implementation.

### Columns to Add to Existing Lists — 👤

| List | Column | Type | Needed For |
|------|--------|------|------------|
| `CCSD_AppRoles` | (no changes) | — | Existing `Role` field supports adding `Security` as a new role value |

> **Note:** The `Security` role is added as a data entry in `CCSD_AppRoles`, not as a schema change. No new columns are needed on that list.

---

## 13. Supervisor Hub (P1) — 🤝

> **New major feature. Adds a dedicated Supervisor-only section to the SPA that consolidates team oversight, pending actions, people management, and cross-module visibility into a single landing page. Requires new SharePoint lists for some features; many features build on existing data.**

### Known Requirements

> **These are confirmed by the project owner or directly derivable from existing app code and data.**

#### 13a. Role-Based Visibility & Access Control — 💻

> **Existing infrastructure:** The `Supervisor` role is already detected two ways: (1) via `CCSD_AppRoles` where `Role = 'Supervisor'`, and (2) via the `IsSupervisor` boolean flag on `CCSD_Personnel` (see `Index.html:1998,2025`). Both paths push `'Supervisor'` into `APP.state.roleNames`. Existing gate functions `canReviewTraining()` and `canManageInOut()` already include the Supervisor role.

- [ ] **New "Supervisor Hub" nav tab** — Add to main navigation. Only visible when `hasAnyRole(['Supervisor','App Admin'])` returns true. Hidden entirely for non-supervisors (no empty-state placeholder).
- [ ] **New route** — `#supervisor` hash route, guarded by role check. If a non-supervisor navigates directly to `#supervisor`, redirect to `#home` with a toast ("Access restricted to supervisors").
- [ ] **Team scope definition** — The Hub operates on the supervisor's "team," defined as:
  - **Primary:** All active personnel in `CCSD_Personnel` where `SupervisorPersonID.Id` = current user's personnel ID (direct reports).
  - **Extended:** All active personnel in the supervisor's org (`OrgID`) and its descendant orgs (using the existing `getOrgAndDescendants()` function, see `Index.html:4104`).
  - **Toggle:** A scope toggle at the top of the Hub: "My Direct Reports" vs. "My Organization" to switch between primary and extended views.
- [ ] **App Admin sees all** — Users with `App Admin` role see the Hub with access to all personnel (no org/supervisor filter). A dropdown lets them select any org to scope the view.
- [ ] **Keyboard shortcut** — Register `Alt+V` (for superVisor) to navigate to the Hub, gated by role check (same pattern as `Alt+D` for diagnostics in `Index.html`).

#### 13b. Supervisor Landing Page / Overview Dashboard — 💻

> **This is the main view when a supervisor navigates to the Hub. It consolidates at-a-glance metrics, pending actions, and team status into a single dashboard.**

- [ ] **Team strength summary** — KPI strip at top:
  - Total assigned (count of direct reports or org members depending on scope toggle)
  - Present for duty today (total minus those with `CCSD_TimeOff` entries for today where `Status = 'Approved'`)
  - On leave today (count with `TimeOffType` in `Annual Leave`, `Sick Leave`, `Comp Time`, `LWOP`)
  - TDY today (count with `TimeOffType = 'TDY'`)
  - Telework today (count with `TimeOffType = 'Telework'`)
  - In training today (count with `TimeOffType = 'Training'`)
- [ ] **Pending actions queue** — Prominent card listing items requiring the supervisor's attention, with counts and direct-action links:
  - Leave requests pending approval (`CCSD_TimeOff` where `Status = 'Pending'` for team members)
  - Requests assigned to supervisor (`CCSD_AppRequests` where `AssignedTo` = current user or status includes "Pending Supervisor")
  - Training submissions pending review (`CCSD_TrainingSubmissions` where `Status = 'Pending Review'` and reviewer is supervisor)
  - In-processing cases with overdue steps (from `CCSD_InOutStepStatus` for team members)
  - SF-182 requests pending supervisor approval (from `CCSD_SF182TrainingRequests`)
  - **Security clearance expirations** within 90 days (from `CCSD_SecurityRecords` if Security module exists — graceful degradation if not yet built)
- [ ] **Team readiness scorecard** — Color-coded indicators (green/amber/red):
  - Training compliance: % of team with all mandatory training current (from `CCSD_TrainingRecords` vs. `CCSD_TrainingCatalog` where `IsMandatory = true`)
  - Asset accountability: % of team's assigned hardware verified within 90 days (from `CCSD_HardwareAssignments`)
  - In/Out processing: Count of active cases, any overdue steps highlighted
  - Open requests: Count of open/overdue requests for the team
- [ ] **Recent activity feed** — Last 10 events relevant to the team (new personnel, departures, completed requests, submitted leave, training completions). Sourced from existing lists sorted by `Created` or `Modified` date.

#### 13c. Team Roster & Status Visibility — 💻

> **Existing infrastructure:** The People module (`Index.html:2000+`) already loads all personnel with org/position/supervisor lookups. The Home dashboard already shows a "Team Availability — Today" widget (`Index.html:2508`). The supervisor request dashboard (`Index.html:4099`) already filters requests by org.

- [ ] **Team roster table** — Sortable, filterable table of all team members showing:
  - Name, grade/rank, position title, org
  - Current status (Active, Leave, TDY, Training, Telework, Departed)
  - Today's status (computed from `CCSD_TimeOff` entries for today)
  - Training compliance % (computed per person)
  - Open requests count
  - Last activity date
  - Click row to open person detail modal (existing functionality)
- [ ] **Status filter bar** — Quick filters: All | Present | Leave | TDY | Telework | Training | Departed
- [ ] **Team calendar view** — Week/month grid showing team availability at a glance:
  - Rows = team members, columns = days
  - Color-coded cells: present (green), leave (blue), TDY (orange), telework (teal), training (purple)
  - Summary row at top: "X of Y present" per day
  - Red highlight on any day where present-for-duty drops below 50%
  - Reuses data already loaded by the Calendar module (`CCSD_TimeOff`)
- [ ] **Upcoming departures** — List of team members with `DateDeparted` set in the future or within 90 days, sourced from `CCSD_Personnel`.
- [ ] **Upcoming arrivals** — In-processing cases (`CCSD_InOutProcessing` where `ProcessType = 'In-Processing'` and `Status` is open/in-progress) for the supervisor's org.

#### 13d. People Management & Administrative Tools — 💻

> **Existing infrastructure:** The People module has edit personnel modal (`canEditPeople()` gated to HR/Admin/App Admin), departure processing, org transfer workflow, and personnel CSV export. The Supervisor Hub extends these capabilities specifically for supervisors managing their own team.

- [ ] **Quick actions per team member** — From the roster row or a detail modal, supervisor can:
  - View full person detail (existing modal)
  - View assigned assets (links to Assets module filtered to that person)
  - View training records (links to Training module filtered to that person)
  - View time-off history (links to Calendar module filtered to that person)
  - View/create requests on behalf of team member
  - Initiate in-processing or out-processing case for the team member
- [ ] **Supervisor-initiated leave entry** — Supervisor can create a `CCSD_TimeOff` entry on behalf of a team member (pre-populating `ApprovedBy` with the supervisor's identity).
- [ ] **Supervisor notes** — A free-text notes field visible only to the supervisor for each team member. This would require a new column on `CCSD_Personnel` (`SupervisorNotes`, type: Note) or a separate list.
  - **⚠️ Decision needed:** Store on `CCSD_Personnel` (simpler, but visible to HR/Admin) or in a new `CCSD_SupervisorNotes` list with broken permission inheritance (more private, more complex)?
- [ ] **Newcomer integration tracking** — For team members currently in-processing, show a checklist of supervisor-specific onboarding tasks:
  - Welcome meeting conducted
  - Workspace/seat assigned
  - IT accounts verified
  - Team introduction completed
  - Performance expectations discussed
  - 30/60/90-day check-in schedule set
  - **Note:** These items could be individual steps in `CCSD_InOutStepStatus` assigned to the supervisor, leveraging the existing checklist infrastructure.

#### 13e. Pending Actions, Queues & Alerts — 💻

> **Consolidates all actionable items a supervisor needs to act on across all modules into a single prioritized queue.**

- [ ] **Unified action queue** — Single sortable list combining all pending items from Section 13b, with:
  - Action type (Leave Request, Training Review, Request Assigned, In-Processing Step, SF-182 Approval)
  - Subject (team member name)
  - Submitted/due date
  - Age (days since created)
  - Priority indicator (overdue = red, due within 3 days = yellow, normal = default)
  - One-click action button (Approve, Deny, Review, Open Detail)
- [ ] **Leave approval workflow** — Inline approve/deny for pending leave requests:
  - Show the request details (person, dates, type, hours)
  - Show conflict check: are other team members also off during that period?
  - Show manning impact: "Approving would bring team to X of Y present on [dates]"
  - Approve button → sets `CCSD_TimeOff.Status = 'Approved'`, `ApprovedBy = currentUser`
  - Deny button → requires a reason note, sets `Status = 'Denied'`
- [ ] **Training submission review** — Inline approve/reject for pending training submissions:
  - Show certificate/proof if attached
  - Approve → creates `CCSD_TrainingRecords` entry (existing pattern)
  - Reject → sets `Status = 'Rejected'` with notes
- [ ] **Overdue alerts** — Visual alert badges on the Hub nav tab showing the count of overdue items (red badge, same pattern as notification badges on the Home dashboard).

#### 13f. Cross-Module Connections — 💻

> **The Supervisor Hub does not replace existing modules — it provides a supervisor-scoped lens into them.**

- [ ] **Link to Calendar** — "View Team Calendar" button that navigates to `#calendar` with the org scope pre-set to the supervisor's org.
- [ ] **Link to Training** — "View Team Training" button that opens the existing team training compliance modal (`getTeamTrainingModel()` at `Index.html:6939`), or navigates to `#training` with the org filter applied.
- [ ] **Link to Requests** — "View Team Requests" button that opens the existing supervisor request dashboard (`openSupervisorRequestDashboard()` at `Index.html:4099`), or navigates to `#requests` with a team filter.
- [ ] **Link to In/Out** — "View In/Out Cases" button that navigates to `#inout` with the org filter applied to show only the supervisor's team's cases.
- [ ] **Link to Assets** — "View Team Assets" button that navigates to `#assets` with a filter showing hardware/software assigned to team members.
- [ ] **Link to Security** — "View Team Security Status" (if Security module is built) navigates to `#security`. Supervisors see limited summary view per Section 12 rules.
- [ ] **Context preservation** — When navigating from the Hub to another module via these links, the module should respect the org/team filter. When the user navigates back to `#supervisor`, the Hub state should be preserved.

#### 13g. Reporting, Dashboards & Drilldowns — 💻

- [ ] **Team summary report** — Printable report showing:
  - Roster with current status, position, grade, arrival date
  - Training compliance matrix (person × mandatory training items, with current/expired/due status)
  - Open requests summary
  - Asset inventory per person (count of hardware/software assigned)
  - Time-off utilization (hours approved this month/quarter/year)
- [ ] **Training compliance drilldown** — Click the training compliance KPI to see a per-person × per-training matrix (reuses `getTeamTrainingModel()` data).
- [ ] **Leave utilization chart** — Bar chart or table showing leave usage by team member for the current month/quarter (from `CCSD_TimeOff` aggregations).
- [ ] **Add to Reports module** — Supervisor-specific reports integrated into the existing Reports nav section (Section 10):
  - "Supervisor Team Summary" report type
  - "Team Training Compliance" report type
  - "Team Leave Utilization" report type
  - These reports respect the same role-gating: only visible to supervisors.

#### 13h. Supervisor-Only Workflows & Approvals — 💻

> **Workflows that are exclusive to the Supervisor Hub and do not exist in other modules.**

- [ ] **Leave request approval** — Full approve/deny workflow as described in Section 13e. This is the primary new workflow.
- [ ] **SF-182 supervisor approval step** — When an SF-182 training request is routed to the supervisor (existing `Status = 'Submitted'` flow), the Hub surfaces it as an actionable item. Supervisor can approve (→ `Status = 'Supervisor Approved'`) or return for revision.
- [ ] **In-processing step sign-off** — Supervisor can mark in-processing steps assigned to them as complete (using existing `CompletedBy`/`CompletedOn` fields on `CCSD_InOutStepStatus`).
- [ ] **Request routing** — When a request is assigned to the supervisor (via `AssignedTo` on `CCSD_AppRequests`), the Hub surfaces it for action. Supervisor can update status, add comments, reassign, or close.

### Needs Research / Validation

> **These items require further discovery — either from the project owner providing decisions, from reviewing governing regulations, or from detailed UX design sessions.**

- [ ] **🔬 Performance management (DPMAP/EPR/OPR)** — Determine whether the Hub should track performance review cycles, midpoint reviews, ratings, and performance improvement plans. This is a major sub-feature that would require new SharePoint lists (`CCSD_PerformanceReviews`, `CCSD_PerformanceActions`). Placeholder for future expansion.
- [ ] **🔬 Awards and recognition tracking** — Determine whether the Hub should track award nominations (Time-Off Awards, QSIs, Performance Awards, Quarterly/Annual Awards). Would require a new `CCSD_Awards` list. Placeholder.
- [ ] **🔬 Disciplinary action tracking** — Determine whether the Hub should track LOCs, LOAs, LORs (military) and progressive discipline (civilian). Requires extremely sensitive data handling and likely broken permission inheritance. Would require a new `CCSD_DisciplinaryActions` list. Placeholder.
- [ ] **🔬 Individual Development Plans (IDPs)** — Determine whether the Hub should support creating and tracking IDPs for team members. Would require a new `CCSD_IndividualDevelopmentPlans` list. Placeholder.
- [ ] **🔬 Work schedule management** — Determine whether the Hub should track alternate work schedules (CWS, FWS, Maxiflex, 4-10, 5-4/9), telework agreements (DD Form 2946), and overtime authorization. Would require new lists. Placeholder.
- [ ] **🔬 Newcomer sponsorship program** — Determine whether the Hub should manage sponsor assignments for incoming team members. Would require a new `CCSD_SponsorAssignments` list. Placeholder.
- [ ] **🔬 Duty roster / shift scheduling** — Determine whether the Hub needs a visual duty roster for daily/weekly scheduling. This is common for military units but may be less relevant for a civilian personnel support group. Placeholder.
- [ ] **🔬 GPC (Government Purchase Card) tracking** — Determine whether supervisors need to track/approve GPC transactions for their team. Would require a new list. Placeholder.
- [ ] **🔬 Budget visibility** — Determine whether supervisors need to see budget execution data (allocated vs. obligated vs. expended) for their org. Would require a new list. Placeholder.
- [ ] **🔬 Medical/fitness readiness (military)** — If active duty military are assigned to CPSG, determine whether the Hub should track PHA, dental readiness, fitness assessments, and immunization status. Would require new lists. Placeholder — likely low priority for a civilian-majority organization.
- [ ] **🔬 Deployment readiness (military)** — Similar to above. Determine scope and priority. Placeholder.
- [ ] **🔬 Task assignment and tracking** — Determine whether the Hub should have a Kanban-style task board for assigning action items/suspenses to team members. Would require a new `CCSD_TaskAssignments` list. Placeholder.
- [ ] **🔬 Standup/status notes** — Determine whether the Hub should support recording daily/weekly standup notes (accomplishments, plans, issues). Would require a new list. Placeholder.
- [ ] **🔬 Team announcements** — Determine whether supervisors need org-scoped announcements separate from the planned `CCSD_Announcements` list (Section 13). May be handled by adding a `TargetOrgID` column to that list. Placeholder.

### SharePoint Lists Required — 👤

> **Core Hub features use existing lists. The items below are only needed if specific sub-features are approved during discovery.**

#### No New Lists Required for Core Hub

The core Supervisor Hub (sections 13a-13h) operates entirely on existing lists:
- `CCSD_Personnel` — team roster, supervisor linkage
- `CCSD_Organizations` — org hierarchy, scope filtering
- `CCSD_TimeOff` — leave management, team calendar
- `CCSD_TrainingRecords` / `CCSD_TrainingCatalog` — training compliance
- `CCSD_TrainingSubmissions` — submission review
- `CCSD_AppRequests` — request management
- `CCSD_InOutProcessing` / `CCSD_InOutStepStatus` — in/out processing
- `CCSD_SF182TrainingRequests` — SF-182 approvals
- `CCSD_HardwareAssignments` / `CCSD_SoftwareAssignments` — asset visibility
- `CCSD_SecurityRecords` — security status (if built)
- `CCSD_AppRoles` — role detection (Supervisor role already supported)
- `CCSD_AppAuditLog` — audit logging

#### Future Lists (Only If Research Items Are Approved)

| List | Sub-Feature | Priority |
|------|-------------|----------|
| `CCSD_PerformanceReviews` | Performance management (DPMAP/EPR/OPR) | TBD |
| `CCSD_Awards` | Awards and recognition tracking | TBD |
| `CCSD_DisciplinaryActions` | Disciplinary action tracking | TBD |
| `CCSD_IndividualDevelopmentPlans` | IDP tracking | TBD |
| `CCSD_WorkSchedules` | Alternate work schedule management | TBD |
| `CCSD_TeleworkAgreements` | Telework agreement tracking | TBD |
| `CCSD_OvertimeAuthorization` | Overtime approval workflow | TBD |
| `CCSD_SponsorAssignments` | Newcomer sponsorship program | TBD |
| `CCSD_TaskAssignments` | Task board / suspense tracking | TBD |
| `CCSD_StandupNotes` | Standup/status note history | TBD |
| `CCSD_GPCTransactions` | GPC tracking | TBD |
| `CCSD_BudgetTracking` | Budget visibility | TBD |
| `CCSD_MedicalReadiness` | Medical readiness (military) | TBD |
| `CCSD_FitnessAssessments` | Fitness assessment tracking (military) | TBD |
| `CCSD_LeaveBalances` | Leave balance tracking (manual/periodic) | TBD |

### Columns to Add to Existing Lists — 👤 (Optional)

| List | Column | Type | Needed For | Required? |
|------|--------|------|------------|-----------|
| `CCSD_Personnel` | `SupervisorNotes` | Multiple lines of text | Supervisor-only notes per team member | Optional — see decision note in 13d |
| `CCSD_TimeOff` | `RequestedDate` | Date | Track when leave was originally requested | Optional — enhances leave approval workflow |
| `CCSD_TimeOff` | `SupervisorDecisionDate` | Date | Track when supervisor approved/denied | Optional — enhances leave audit trail |
| `CCSD_TimeOff` | `DecisionNotes` | Multiple lines of text | Reason for denial or conditions | Optional — enhances leave denial workflow |

---

## 14. SharePoint Lists to Create — 👤

> *Renumbered from 13*

> **These are all manual steps you perform in SharePoint.**

### `CCSD_TimeOff` — ⚠️ NEEDS CREATION NOW (Calendar module depends on this)

1. Go to **Site Contents** > **New** > **List** > name it `CCSD_TimeOff`
2. Add these columns:

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Auto-populated, can be "Leave - Smith" |
| PersonID | Lookup → CCSD_Personnel | Who is taking time off |
| OrgID | Lookup → CCSD_Organizations | Their org at time of entry |
| StartDate | Date and Time | First day off (date only) |
| EndDate | Date and Time | Last day off (date only) |
| TimeOffType | Choice | Choices: `Annual Leave`, `Sick Leave`, `TDY`, `Training`, `Comp Time`, `Telework`, `LWOP`, `Other` |
| Status | Choice | Choices: `Approved`, `Pending`, `Denied`, `Cancelled` — Default: `Approved` |
| Hours | Number | Total hours (optional, for tracking) |
| Notes | Multiple lines of text | Plain text |
| ApprovedBy | Person or Group | Supervisor who approved |
| CreatedBy | Person or Group | Who entered it |

3. After creation, verify: go to `[your site]/_api/web/lists/getbytitle('CCSD_TimeOff')/items` — you should get an empty `<feed>` response
4. **Add a test entry** to verify columns work — you can delete it after

### `CCSD_ConferenceRooms` — Planned (for conference room scheduling)

See Section 1 above for full column definitions. Create when ready to build that feature.

### `CCSD_RoomReservations` — Planned (for conference room scheduling)

See Section 1 above for full column definitions. Create when ready to build that feature.

### `CCSD_Announcements` — Planned (for Home dashboard news banner)

1. Go to **Site Contents** > **New** > **List** > name it `CCSD_Announcements`
2. Add these columns:

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Announcement headline |
| Body | Multiple lines of text | Rich text or plain text |
| StartDate | Date and Time | When to start showing |
| EndDate | Date and Time | When to stop showing |
| Priority | Choice | Choices: `Normal`, `Important`, `Critical` |
| Audience | Choice | Choices: `All`, `Admin`, `Supervisors` |
| IsActive | Yes/No | Default: Yes |

---

## 15. External Integrations (Future) — 🤝

> **Each of these requires setup on your end before code can be built.**

### Microsoft Graph API — Outlook Calendar (P2)
- **Your steps**: See Section 1 (Azure AD App Registration) — this is the blocker
- **Claude builds**: MSAL auth, free/busy view, token management

### Power Automate — Email Notifications (P2)
- **Your steps**:
  1. Go to **Power Automate** (flow.microsoft.com) and verify you have a license
  2. Confirm you can create flows that connect to your SharePoint site
  3. Let Claude know — Claude can provide the exact flow configuration JSON or you can build manually per Section 6 instructions
- **Claude builds**: Nothing in Index.html (Power Automate runs server-side)

### SharePoint Search API — Global Search (P3)
- **Your steps**: None — SharePoint Search API is available by default on SPO
- **Claude builds**: Unified search bar using `_api/search/query`

### Teams Integration — Channel Notifications (P3)
- **Your steps**:
  1. Create an **Incoming Webhook** in the target Teams channel:
     - Open Teams > channel > **…** menu > **Connectors** > **Incoming Webhook** > name it "CCSD Admin SPA"
     - Copy the webhook URL and provide it to Claude
  2. Verify webhook URLs are not blocked by your network firewall
- **Claude builds**: POST notifications to the webhook URL on critical events

### PDF Generation (P3)
- **Your steps**: None — this uses client-side JS (jsPDF library via CDN)
- **Claude builds**: PDF export for SF182 forms, inventory reports, org charts
- **Note**: Verify that CDN scripts (cdnjs.cloudflare.com or similar) are not blocked on your network. Test by adding `<script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>` to a test page.

---

## 16. Column Additions to Existing Lists — 👤

> **Summary of all new columns needed on existing lists (referenced throughout this document).**

| List | Column | Type | Needed For |
|------|--------|------|------------|
| `CCSD_HardwareAssets` | `LastAuditDate` | Date | Inventory audit |
| `CCSD_HardwareAssets` | `LastAuditBy` | Person | Inventory audit |
| `CCSD_HardwareAssets` | `WarrantyExpiration` | Date | Warranty tracking |
| `CCSD_HardwareAssets` | `PhysicalLocation` | Text | Location tracking |
| `CCSD_HardwareAssets` | `CostCenter` | Text | Cost center reporting |
| `CCSD_HardwareAssignments` | `ExpectedReturnDate` | Date | Portable check-out |
| `CCSD_SoftwareAssets` | `TotalLicenses` | Number | License utilization |
| `CCSD_SoftwareAssets` | `CostCenter` | Text | Cost center reporting |

**How to add a column:**
1. Go to **Site Contents** > open the list
2. Click **+ Add column** (or go to List Settings > Create column)
3. Select the type, enter the name exactly as shown, save

---

## Quick Reference: Recently Completed

- [x] Sortable tables, request lifecycle, in/out completion, team training, SF182 edit
- [x] Hardware and software assignment creation
- [x] Supervisor chain display
- [x] Admin/diagnostics restricted to App Admin role
- [x] Interactive floor plan viewer with coordinate picker
- [x] Org chart visual hierarchy with connector lines, leadership info, current-org highlight
- [x] Fullscreen/embedded dual-mode support
- [x] Seating chart overhaul (drag-reposition, edit, delete, sidebar, crosshairs)
- [x] Calendar module (month/week/list/leaders views, federal holidays, org scope filter)
- [x] Asset lifecycle overhaul: edit assets, edit assignments, unassign/return with condition, transfer, asset detail pages
- [x] Home dashboard professional redesign: welcome banner, KPI strip, priority actions, team availability, training/requests/in-out cards, notifications, quick nav, admin health

---

## Priority Action Summary

### 🔴 Do First (blockers for existing features)
1. **Create `CCSD_TimeOff` list** — The Calendar module is built but has no data source yet

### 🟡 Do When Ready (enables new features)
2. **Create `CCSD_SecurityRecords` + `CCSD_SecurityIncidents` + `CCSD_Notifications`** — Enables Security module (Section 12)
3. **Add `Security` role entries to `CCSD_AppRoles`** — Required for Security module role-based access
4. **Obtain sample DISS Excel export** — Blocks the Excel import feature for Security module
5. **Add `Supervisor` role entries to `CCSD_AppRoles`** — Required for Supervisor Hub role-based access (Section 13)
6. **Create `CCSD_ConferenceRooms` + `CCSD_RoomReservations`** — Enables conference room scheduling
7. **Add audit columns** to `CCSD_HardwareAssets` — Enables inventory audit mode
8. **Azure AD App Registration** — Enables Outlook calendar integration (longest lead time)

### 🟢 Low Urgency (nice-to-have prerequisites)
9. **Add `TotalLicenses`** to software assets — Enables license dashboard
10. **Add `WarrantyExpiration`** to hardware assets — Enables warranty alerts
11. **Create `CCSD_Announcements`** — Enables Home dashboard news banner
12. **Set up Teams Incoming Webhook** — Enables Teams notifications
