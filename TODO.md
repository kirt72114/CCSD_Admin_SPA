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
       - `https://usaf.dps.mil/teams/aetc-lak-cpsg/Database/SitePages/Index.aspx`
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

## 12. SharePoint Lists to Create — 👤

> *Renumbered from 11*

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

## 12. External Integrations (Future) — 🤝

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

## 13. Column Additions to Existing Lists — 👤

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
2. **Create `CCSD_ConferenceRooms` + `CCSD_RoomReservations`** — Enables conference room scheduling
3. **Add audit columns** to `CCSD_HardwareAssets` — Enables inventory audit mode
4. **Azure AD App Registration** — Enables Outlook calendar integration (longest lead time)

### 🟢 Low Urgency (nice-to-have prerequisites)
5. **Add `TotalLicenses`** to software assets — Enables license dashboard
6. **Add `WarrantyExpiration`** to hardware assets — Enables warranty alerts
7. **Create `CCSD_Announcements`** — Enables Home dashboard news banner
8. **Set up Teams Incoming Webhook** — Enables Teams notifications
