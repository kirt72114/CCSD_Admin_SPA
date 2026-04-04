# CCSD All-Things Administrative SPA — TODO

Master task list for pending features, improvements, and technical debt.
Updated: 2026-04-04

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

---

## 2. Hardware / Software Asset Improvements

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

### Assignment Improvements (P2) — 💻

> **No prerequisites from you. All code-only.**

- [ ] Seat-to-asset auto-suggestion

---

## 3. People Module Improvements — 💻

> **No prerequisites from you. All fields already exist in `CCSD_Personnel`.**

- [ ] **Photo / avatar support** — 👤 decision needed:
  - Option A: Use SharePoint profile photos (automatic if users have O365 profiles with photos)
  - Option B: Add a `PhotoUrl` column to `CCSD_Personnel` for manual upload
  - **Let Claude know which approach you prefer**
- [ ] **Personnel onboarding wizard** — guided flow to create person + seat + assets

---

## 4. Organization Module Improvements — 💻

> **No prerequisites from you. Uses existing `CCSD_Organizations` list.**

- [ ] Org merge / restructure tool
- [ ] Org contact card (expanded info)

---

## 5. Training Module Improvements — 💻

> **No prerequisites from you. Uses existing `CCSD_Training` and `CCSD_TrainingRecords` lists.**

- [ ] Training calendar integration (show on Calendar module)
- [ ] Training request workflow (person requests → supervisor approves → SF182 auto-created)

---

## 6. Requests / Workflow Improvements — 🤝

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

---

## 7. Facilities Module Improvements — 💻

> **No prerequisites from you. All code-only changes.**

- [ ] Room booking integration with Calendar conference room scheduling (depends on Section 1 lists)
- [ ] Floor plan: room boundary overlays (draw room outlines)

---

## 8. Home Dashboard Improvements

- [ ] **Announcements / news banner** — 🤝
  1. 👤 Create `CCSD_Announcements` list (see Section 13 below for columns)
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

- [ ] Undo toast actions
- [ ] Keyboard navigation (arrow keys in calendar, tab through tables)

### Security (P1) — 💻

> **No prerequisites from you.**

- [ ] Audit all CRUD operations (ensure AppAuditLog coverage)
- [ ] Role-based field visibility (hide sensitive fields from non-supervisors)

### Data Integrity (P2) — 💻

> **No prerequisites from you.**

- [ ] Scheduled data quality report (surface on Home)

---

## 10. Reporting (P3) — 💻

> **No prerequisites from you. All code-only.**

- [ ] Scheduled report email — 🤝 (requires Power Automate, see Section 6 notes)

---

### In/Out Processing Column Recommendations (Optional) — 👤

> **Optional columns to persist In/Out Processing fields natively. Currently stored in the Notes field.**

| List | Column | Type | Notes |
|------|--------|------|-------|
| `CCSD_InOutProcessing` | `FromLocation` | Single line of text | Prior base/unit/location |
| `CCSD_InOutProcessing` | `ToLocation` | Single line of text | Gaining base/unit/location |
| `CCSD_InOutProcessing` | `LosingOrgID` | Lookup → CCSD_Organizations | Org member is leaving |
| `CCSD_InOutProcessing` | `GainingOrgID` | Lookup → CCSD_Organizations | Org member is joining |

**How to add**: Site Contents → open `CCSD_InOutProcessing` → Add column. Once created, let Claude know and the code will be updated to write to these columns directly instead of the Notes field.

---

## 11. Security Module (P1) — 🤝

> **Comprehensive security management for a DoD/USAF-aligned civilian personnel support group. Covers personnel security, incident/case management, notifications, training compliance, and (in future phases) physical security, information security, OPSEC, and industrial security. Research-backed by SEAD 3, SEAD 4, DoDM 5200.02, EO 12968, EO 13526, AFI 16-1406, and related directives. See `SECURITY_RESEARCH_SUMMARY.md` for the full regulatory analysis.**

### Regulatory Foundation

> **Key directives governing this module's requirements. Items marked ✦ are confirmed regulatory requirements; items marked ◇ are common practice / best practice.**

| Directive | Scope |
|-----------|-------|
| SEAD 3 (DNI, 2017) | 15 categories of reportable events for cleared personnel |
| SEAD 4 (DNI, 2017) | 13 adjudicative guidelines for clearance determinations |
| SEAD 6 (DNI) | Continuous Vetting replacing periodic reinvestigations |
| EO 12968 | Due process rights: SOR, response, appeal for adverse actions |
| EO 13526 | Classified information handling, violations, and sanctions |
| EO 13556 / DoDI 5200.48 | Controlled Unclassified Information (CUI) program |
| EO 13587 / DoDD 5205.16 | Insider Threat programs |
| DoDM 5200.01 (Vols 1-4) | DoD Information Security Program |
| DoDM 5200.02 (Vols 1-3) | DoD Personnel Security Program |
| DoDI 5240.06 | Counterintelligence Awareness and Reporting (CIAR) |
| AFI 16-1406 / AFMAN 16-1405 | Air Force Personnel & Information Security |
| AFI 10-701 / DoDM 5205.02 | Operations Security |
| 32 CFR 117 (NISPOM) | Industrial Security |
| Privacy Act (5 USC 552a) | PII protections for security records |

### Role Matrix

> **✦ Confirmed: Role-based access is mandated by the Privacy Act and need-to-know principle (DoDM 5200.02). The visibility rules below enforce regulatory privacy requirements, not just UX preferences.**

| Capability | Member | Supervisor | Security Mgr | App Admin |
|------------|--------|------------|--------------|-----------|
| View own security record | ✅ (obscured) | — | — | — |
| Reveal own obscured fields | ✅ (logged) | — | — | — |
| View direct reports summary | ❌ | ✅ (level + status only) | — | — |
| View direct reports details | ❌ | ❌ | — | — |
| View full org roster | ❌ | ❌ | ✅ (scoped by org) | ✅ (all orgs) |
| Edit security records | ❌ | ❌ | ✅ | ✅ |
| Create/manage incidents | ❌ | ❌ | ✅ | ✅ |
| View incident details | Own only (case # + status) | ❌ | ✅ | ✅ |
| Upload DISS Excel | ❌ | ❌ | ✅ | ✅ |
| Export security roster | ❌ | ❌ | ✅ (logged) | ✅ (logged) |
| Send security notifications | ❌ | ❌ | ✅ | ✅ |
| View audit logs | ❌ | ❌ | ❌ | ✅ |

> **✦ Supervisor limited view:** Per DoDM 5200.02 and need-to-know, supervisors see only clearance level + current/expired/suspended status for direct reports. They CANNOT see investigation details, incident records, SF-86 dates, or training specifics. This is a privacy enforcement, not a UX choice.

> **✦ Member self-service restrictions:** Per EO 12968, individuals have the right to know their own security status. However, incident details (descriptions, investigation notes) visible only at Security role level. Members see their own case numbers and statuses only.

---

### PHASE 1: Personnel Security Core (MVP)

> **Builds the foundational clearance tracking, training compliance, and DISS ingestion features. No incident management yet — that's Phase 2.**

#### 11a. Access, Visibility & Privacy Controls — 💻

- [ ] **New "Security" nav tab** — Add to main navigation. Visible to all authenticated users but content scoped by role per the Role Matrix above.
- [ ] **Hash route `#security`** — Guarded by authentication (all users can access their own record). Role check determines which view loads.
- [ ] **Self-view default** — Non-privileged users see ONLY their own security record. No roster, no search, no other members visible.
- [ ] **Obscured-by-default display** — ✦ All security fields masked on initial load (`●●●●●●` or `[Click to reveal]`). Reveal requires explicit click. This enforces need-to-know even for the record owner — prevents shoulder-surfing in shared workspaces.
- [ ] **Security role access** — Users with `Security` role (via `CCSD_AppRoles`) see full searchable/filterable roster. Scoped by `ScopeOrgID` if set (org + descendants only).
- [ ] **App Admin access** — Same as Security role but unscoped (all orgs visible).
- [ ] **Supervisor limited view** — `hasAnyRole(['Supervisor'])` users see a summary card per direct report: name, clearance level, status badge (green/yellow/red). No drill-down into details. No incident data.
- [ ] **Audit logging for ALL access** — ✦ Every view, reveal, edit, export, and search of security data logged to `CCSD_AppAuditLog` with viewer identity, timestamp, record accessed, and action type. Required by Privacy Act for systems containing security PII.
- [ ] **Query-level enforcement** — ✦ Security visibility enforced at the SharePoint REST query level (`$filter=PersonID eq [currentUser]` for members), not just UI hiding. Network inspection must not reveal other members' data.

#### 11b. Member Self-Service Security View — 💻

> **✦ Per EO 12968, individuals have the right to be informed of their security eligibility status.**

- [ ] **Personal security status card** — Dashboard-style card showing the member's own:
  - Current clearance level and eligibility status (Active, Interim, Expired, Suspended, Revoked, Denied, Not Cleared)
  - Investigation type (T1/T2/T3/T4/T5/T5R) and date of last investigation close
  - Continuous Vetting enrollment status (Enrolled / Not Enrolled)
  - SF-86 last submission date and next due date (calculated: `LastSF86Date + 5 years`; display "Enrolled in CV" if `CVEnrolled = Yes`)
  - Access determinations: NIPR / SIPR / JWICS / SCI (boolean badges)
  - SF-312 (NDA) signed date and on-file status
  - Position sensitivity level (Non-sensitive / Noncritical-Sensitive / Critical-Sensitive / Special-Sensitive)
- [ ] **Security training compliance panel** — Shows 6 required trainings with status:
  - Initial Security Briefing — ✦ required before access (DoDM 5200.01)
  - Annual Security Refresher — ✦ every 12 months (DoDM 5200.01)
  - Derivative Classification — ✦ every 24 months (EO 13526 Sec 2.1(d))
  - CI Awareness — ✦ every 12 months (DoDI 5240.06)
  - Insider Threat Awareness — ✦ every 12 months (EO 13587)
  - CUI Training — ✦ every 12 months (DoDI 5200.48)
  - Each shows: completion date, due date, status badge (Current ✅ / Due Soon ⚠️ / Overdue 🔴)
- [ ] **Reveal interaction** — Each field group has a "Show" toggle. Clicking reveals data and logs the event.
- [ ] **Read-only for members** — All fields display-only. No edit capability.
- [ ] **Incident summary (own only)** — Shows own incident records: case number (obscured format), current status, date opened, date closed. NO description, notes, category, or severity visible.
- [ ] **No export for members** — No CSV export, no print capability from self-service view.

#### 11c. Security Admin Management View — 💻

> **The primary working view for the Unit Security Manager. Mirrors the columns they currently track in DISS export spreadsheets.**

- [ ] **Full roster view** — Searchable, filterable, sortable table with columns:
  - Name, Rank/Grade, Org, Position
  - Clearance Level, Eligibility Status (color-coded badge)
  - Investigation Type, Investigation Close Date
  - PR Due Date (or "CV Enrolled"), Days Until Due
  - SF-86 Last Submitted
  - SF-312 On File (Yes/No)
  - Training Compliance (% of 6 trainings current)
  - Open Incidents (count)
  - Last DISS Import Date
- [ ] **Inline status indicators** — ✦ Color-coded per DoDM 5200.02 reporting standards:
  - 🟢 Green = eligibility current, all training current, no overdue PR
  - 🟡 Yellow = PR due within 90 days, or 1+ training expiring within 30 days
  - 🔴 Red = PR overdue, eligibility expired/suspended/revoked, or 2+ trainings overdue
- [ ] **Quick filters** — All | Current | Interim | Expired | Suspended | Overdue PR | Training Delinquent
- [ ] **Edit security record modal** — Full form to create/update a member's security record. All fields editable. Changes logged with before/after snapshots.
- [ ] **Bulk status view** — Summary statistics cards:
  - Total personnel, total cleared, total not cleared
  - By level: Confidential / Secret / TS / TS+SCI
  - Interim count, Expired count, Suspended count, Revoked count
  - PR overdue count, CV enrolled count
  - Training delinquency count (any training overdue)
  - Open incidents count
- [ ] **Security compliance dashboard** — Per-org breakdown: clearance currency rate, training compliance %, open incident count. Drillable to individual records.
- [ ] **Export to CSV** — Full roster export. ✦ Every export logged to audit log (who, when, row count). Export includes a header row noting "CUI — PRIVACY ACT PROTECTED" per DoDM 5400.11.

#### 11d. Monthly DISS Excel Ingestion — 🤝

> **✦ Per DoDM 5200.02, DISS is the authoritative source for clearance data. Most units export monthly to Excel because DISS has limited reporting. This feature ingests those exports.**

- [ ] **Upload interface** — Security role users upload `.xlsx` via file input in admin view.
- [ ] **👤 Provide sample DISS Excel export** — You need to provide one sample file so column headers can be mapped. This is the #1 blocker for this feature.
- [ ] **Column mapping configuration** — Admin-configurable mapping between Excel column headers and `CCSD_SecurityRecords` fields. Stored in `CCSD_Config` list. Supports remapping when DISS export format changes.
- [ ] **Expected DISS columns** (◇ common practice, actual headers may vary):
  - Subject Name (Last, First MI) → matched to `CCSD_Personnel`
  - DoD ID / EDIPI or SSN-last-4 → unique match key
  - Clearance Level → `ClearanceLevel`
  - Eligibility Status → `ClearanceStatus`
  - Investigation Type → `InvestigationType`
  - Investigation Open Date → `InvestigationOpenDate`
  - Investigation Close Date → `InvestigationDate`
  - Eligibility Date → `EligibilityDate`
  - PR Due Date → `NextSF86DueDate`
  - CV Enrolled → `CVEnrolled`
  - SCI Eligible → `SCIAccess`
  - Interim Eligibility → derived from `ClearanceStatus = 'Interim'`
  - SF-312 Signed Date → `NDASignedDate`
- [ ] **Preview before commit** — After upload, show diff table: new records (green), changed records (yellow), unchanged (grey), records in SharePoint but NOT in upload (orange — possible departures). Admin confirms before writing.
- [ ] **Upsert logic** — Match by DoD ID/EDIPI (preferred) or SSN-last-4 + name. Update existing; create new; flag missing.
- [ ] **Upload history** — Each upload logged: date, uploader, filename, row count, created/updated/unchanged/flagged counts.
- [ ] **Excel parsing** — Client-side SheetJS/xlsx library.
  - ⚠️ **CDN dependency:** Verify SheetJS CDN accessible from `usaf.dps.mil`. If blocked, inline the library (~500KB) into Index.html.
  - Existing precedent: the Training module already uses SheetJS for CSV import.

---

### PHASE 2: Incident & Case Management

> **Adds SEAD 3-aligned incident reporting, case lifecycle tracking, SOR/appeal workflow, and the notification framework. Depends on Phase 1 being complete.**

#### 11e. Incident Categories (SEAD 3-Aligned) — 💻

> **✦ SEAD 3 defines 15 categories of reportable events. The incident form must use these categories — they are not arbitrary choices.**

- [ ] **Incident category dropdown** — Aligned to SEAD 3's 15 reportable event categories:

  | # | Category | SEAD 4 Guideline(s) |
  |---|----------|-------------------|
  | 1 | Foreign Travel | B (Foreign Influence) |
  | 2 | Foreign Contacts | B (Foreign Influence) |
  | 3 | Foreign Activities & Interests | B, C (Foreign Preference) |
  | 4 | Financial Issues | F (Financial Considerations) |
  | 5 | Criminal Conduct & Legal Issues | J (Criminal Conduct), E (Personal Conduct) |
  | 6 | Substance Abuse / Illegal Drugs | H (Drug Involvement) |
  | 7 | Alcohol-Related Events | G (Alcohol Consumption) |
  | 8 | Mental Health (reportable scope only) | I (Psychological Conditions) |
  | 9 | Unauthorized Disclosure | K (Handling Protected Information) |
  | 10 | Security Violations & Infractions | K (Handling Protected Information) |
  | 11 | Change in Personal Status | B, C, E |
  | 12 | Associations / Memberships | A (Allegiance), E |
  | 13 | Technology & Cyber | M (Use of IT) |
  | 14 | Subversion of Adjudicative Process | E (Personal Conduct) |
  | 15 | Outside Activities / Employment | L (Outside Activities) |
  | 16 | Information Security Incident | K (separate from personnel incidents) |
  | 17 | Physical Security Incident | E (facility/container violations) |
  | 18 | Other / Uncategorized | — |

- [ ] **⚠️ Mental health carve-out guidance** — ✦ SEAD 3 explicitly exempts voluntary counseling for combat stress, sexual assault, domestic violence, and grief from reporting requirements. When Category 8 is selected, display prominent guidance text: *"Note: Voluntarily seeking counseling related to military combat, sexual assault, domestic violence, or grief is NOT reportable. Only conditions that substantially adversely affect judgment, reliability, or trustworthiness, or court-ordered treatment, are reportable."*
- [ ] **SEAD 4 guideline auto-mapping** — When a category is selected, auto-populate the applicable SEAD 4 adjudicative guideline(s) as metadata. Editable by Security role.
- [ ] **Sub-type selections** — For categories with common sub-types:
  - Category 4 (Financial): Bankruptcy Ch7/Ch11/Ch13, Garnishment, Tax Lien, Delinquency >120 days, Unexplained Affluence
  - Category 5 (Criminal): Arrest, Charge, Conviction, Protective Order, Probation/Parole
  - Category 9 (Unauthorized Disclosure): Loss of Material, Compromise, Media Contact, Spillage
  - Category 10 (Security Violations): Container Left Open, Classified in Unauthorized Area, Prohibited Device in Secure Space, Improper Transmission

#### 11f. Case Lifecycle & Workflow States — 💻

> **✦ The lifecycle reflects confirmed regulatory processes from DoDM 5200.02, AFI 16-1406, and EO 12968. Different incident types follow different paths through these states.**

- [ ] **10-stage lifecycle with type-dependent branching:**

  ```
  ┌─────────────┐
  │  1. Reported │  ← All incidents start here
  └──────┬──────┘
         ▼
  ┌──────────────────┐
  │ 2. Preliminary    │  ← USM initial review
  │    Inquiry        │
  └──────┬───────────┘
         ├──────────────────────┐
         ▼                      ▼
  ┌──────────────┐    ┌────────────────────┐
  │ 3. Reported   │    │ Closed — No Action │  ← Benign/routine
  │    to DISS    │    │ Required           │     (e.g., routine
  └──────┬───────┘    └────────────────────┘     foreign contact)
         ▼
  ┌───────────────────┐
  │ 4. Interim Action  │  ← Commander may suspend access
  │    (if warranted)  │     (EO 12968, Section 4.1)
  └──────┬────────────┘
         ▼
  ┌──────────────────────┐
  │ 5. Under              │  ← DCSA, AFOSI, or
  │    Investigation      │     commander's inquiry
  └──────┬───────────────┘
         ▼
  ┌──────────────────────┐
  │ 6. Investigation      │
  │    Complete           │
  └──────┬───────────────┘
         ▼
  ┌──────────────────┐
  │ 7. Adjudication   │  ← DCSA CAF / AFCAF review
  └──────┬───────────┘     against SEAD 4 guidelines
         ├─────────────────┐
         ▼                  ▼
  ┌────────────┐    ┌──────────────────┐
  │ 8. SOR     │    │ Favorable —      │
  │    Issued  │    │ Closed           │
  └──────┬────┘    └──────────────────┘
         ▼
  ┌──────────────┐
  │ 9. Response / │  ← 30 days to respond (EO 12968)
  │    Appeal     │     → PSAB if sustained
  └──────┬───────┘
         ▼
  ┌───────────────────┐
  │ 10. Final          │  ← Clearance retained,
  │     Resolution     │     revoked, or denied
  └───────────────────┘
  ```

- [ ] **Status enum for `CCSD_SecurityIncidents`:**
  - `Reported` → `Preliminary Inquiry` → `Reported to DISS` → `Interim Action Taken` → `Under Investigation` → `Investigation Complete` → `Adjudication` → `SOR Issued` → `Response/Appeal` → `Resolved` → `Closed`
  - Terminal states: `Closed — No Action Required`, `Closed — Favorable`, `Closed — Adverse Action`, `Referred to External Agency`, `Referred to AFOSI`, `Administrative Withdrawal`
- [ ] **Type-dependent path rules:**
  - **Routine foreign contact (self-report):** Reported → Preliminary Inquiry → Closed — No Action Required (short path)
  - **Spillage:** Reported → Preliminary Inquiry → Interim Action → Under Investigation → Damage Assessment → Resolution (requires containment step)
  - **Criminal conduct:** Reported → Reported to DISS → Interim Action → Under Investigation (parallel to legal proceedings) → Adjudication → SOR if needed
  - **Financial issues:** Reported → Reported to DISS → Adjudication (may allow extended mitigation period before determination)
  - **Substance abuse / positive UA:** Reported → Interim Action (immediate suspension) → Under Investigation → Adjudication (strong presumption against retention per SEAD 4 Guideline H)
- [ ] **Status history tracking** — Each transition stored in `StatusHistoryJSON`: `[{status, changedBy, changedAt, notes}]`. Rendered as a visual timeline in the detail view.
- [ ] **Deadline tracking per stage** — Configurable expected durations per stage. Visual indicator when a case exceeds expected time at a stage.

#### 11g. Case Number Generation & SOR/Appeal Tracking — 💻

##### Case Numbers

- [ ] **Format: `SEC-[YYYY]-[NNNN]`** — Sequential within the year (e.g., `SEC-2026-0001`).
  - ✦ Case number must NOT reveal the subject's identity, org, or incident type (privacy requirement).
  - Generated by the app: query `CCSD_SecurityIncidents` for max case number in the current year, increment.
  - Displayed in all notifications, member-facing views, and correspondence.
- [ ] **Separate sequence for information security incidents:** `ISV-[YYYY]-[NNNN]` (Information Security Violation). Optional — can use unified `SEC-` prefix if preferred.

##### SOR & Appeal Workflow

> **✦ EO 12968, Section 5.2 requires: (a) written Statement of Reasons, (b) opportunity to respond within 30 days, (c) right to appeal to PSAB, (d) right to personal appearance. These are non-optional due process rights.**

- [ ] **SOR issuance tracking** — When an incident reaches `SOR Issued` status, capture:
  - SOR issue date
  - SEAD 4 guidelines cited (multi-select: A through M)
  - Specific allegations (structured text entries, one per allegation)
  - Response deadline (auto-calculated: SOR date + 30 calendar days)
  - Extension granted (Yes/No, new deadline if yes)
- [ ] **Subject response tracking** — Capture:
  - Response received date
  - Response summary (Security role only)
  - Supporting documents attached
  - Result: `Sustained`, `Modified`, `Reversed`
- [ ] **Appeal tracking** — If sustained:
  - Appeal filed date (must be within 30 days of final determination)
  - Appeal body (PSAB or agency equivalent)
  - Personal appearance requested (Yes/No)
  - Appeal outcome: `Upheld`, `Overturned`, `Modified`
  - Appeal closed date
- [ ] **Disposition tracking** — Final outcome fields:
  - Outcome: `No Action`, `Letter of Caution`, `Clearance Retained with Conditions`, `Access Suspended`, `Eligibility Revoked`, `Eligibility Denied`, `Referred to External Agency`, `Administrative Withdrawal`
  - Conditions (if applicable): free text describing conditions (e.g., "Must complete financial counseling")
  - Effective date
  - Debriefing date (if clearance revoked — ✦ SF-312 debriefing required)

#### 11h. Notifications, Reminders & SF-86 Tracking — 🤝

##### SF-86 / Periodic Reinvestigation Due Date Tracking

> **✦ Per DoDM 5200.02, security managers must track PR due dates and initiate reinvestigations timely. Under TW 2.0, CV enrollment changes the model but legacy tracking is still needed during transition.**

- [ ] **Dual-mode tracking:**
  - If `CVEnrolled = No`: Calculate `NextSF86DueDate = LastSF86Date + 5 years` (TS) or `+ 10 years` (Secret) or `+ 15 years` (Confidential). Display countdown.
  - If `CVEnrolled = Yes`: Display "Enrolled in Continuous Vetting" instead of countdown. Retain `NextSF86DueDate` for historical reference but de-emphasize.
- [ ] **PR/SF-86 reminder notifications** — Generated automatically at:
  - 365 days before due (1 year — informational)
  - 180 days before due (6 months — plan submission)
  - 90 days before due (3 months — warning)
  - 30 days before due (1 month — urgent)
  - On the due date (overdue — critical)
  - Weekly after overdue until resolved
- [ ] **Recipients:** The member, their supervisor, and all Security role holders for the member's org.
- [ ] **Training expiration reminders** — Same tiered model for 6 security trainings:
  - 30-day warning, 7-day warning, on expiration date, weekly after overdue
  - Note: Derivative Classification is on a **2-year cycle** (not annual). Compliance logic must account for this.

##### Security Notification Framework

- [ ] **Ad-hoc notifications** — Security role users can send a notification to:
  - **Individual:** Select person from roster
  - **Organization:** Select org from `CCSD_Organizations` (sends to all active members in org + descendants)
  - **All:** Broadcast to entire organization (Security or App Admin only)
- [ ] **Incident-linked notifications** — When related to a case, attach case number. Notification text references ONLY case number, not details. E.g., "Please contact the security office regarding case SEC-2026-0042."
- [ ] **Notification templates:**
  - "Action required: Contact the security office regarding case [CASE_NUMBER]"
  - "Reminder: Your periodic reinvestigation is due in [N] days. Please contact the security office to initiate your SF-86."
  - "Your [TRAINING_NAME] training expires on [DATE]. Please complete renewal before the deadline."
  - "Your security clearance status has changed. Please contact the security office."
  - Custom free-text (500 character limit)
- [ ] **Delivery:** In-app notification panel on Home dashboard. Each notification has: title, body, timestamp, read/unread, sender name, optional link to security record or incident.
- [ ] **Notification log** — All sent notifications logged to `CCSD_Notifications` list for audit.
- [ ] **◇ Email notification (future):** If Power Automate is available, trigger email on critical notifications (PR overdue, clearance suspension, SOR issued). This is a Phase 2+ enhancement dependent on Section 14 (External Integrations).

#### 11i. Audit Logging & Data Retention — 💻

> **✦ The Privacy Act (5 USC 552a) requires audit trails for systems containing security PII. All access, modification, and disclosure of security records must be logged.**

- [ ] **Audit log coverage** — The following events logged to `CCSD_AppAuditLog`:
  - Security record viewed (who viewed whose record)
  - Security record field revealed (obscured → visible)
  - Security record created or edited (before/after field snapshots)
  - Security data exported to CSV (who, when, row count, query filters used)
  - DISS Excel uploaded (who, when, filename, row count, records created/updated/flagged)
  - Incident created, status changed, or closed (with old/new status)
  - SOR issued, response received, appeal filed, disposition recorded
  - Notification sent (sender, recipient(s), notification text, case number if linked)
  - Security roster searched or filtered (who, what search terms/filters — to detect fishing)
- [ ] **Data retention rules:**
  - Security records: retained indefinitely (mirrors DISS retention)
  - Incident records: not hard-deletable. Use `softDeleteItem()` for archival. ✦ Per NARA records disposition, security incident records must be retained per AF RDS (typically 5+ years after case closure).
  - Notification logs: retained 3 years minimum
  - Audit log entries: retained 7 years minimum (◇ best practice for Privacy Act systems)
- [ ] **Session security** — Inherits existing 30-min timeout with 5-min warning overlay.

#### 11j. Reporting & Dashboards — 💻

- [ ] **Security compliance report** — Org-level breakdown:
  - Total personnel, cleared count by level (Confidential/Secret/TS/TS+SCI), not-cleared count
  - PR current / due within 90 days / overdue counts
  - CV enrolled / not enrolled counts
  - Training compliance % (all 6 trainings current vs. any delinquent)
  - Active incident count by category
  - SF-312 on file % 
- [ ] **SF-86 / PR due date report** — Sortable list of all members with upcoming PR due dates, filterable by org, exportable to CSV.
- [ ] **Incident summary report** — Counts by status, category, org, severity, and time period. No PII in summary view. Drillable to individual cases for Security role.
- [ ] **Security training compliance matrix** — Grid: rows = personnel, columns = 6 required trainings. Each cell shows completion date + status badge. Filterable by org. Exportable.
- [ ] **Monthly security status report** — ◇ Pre-formatted report matching common HHQ reporting requirements:
  - Total cleared by level, interim count, suspended count
  - PR/CV status breakdown
  - New incidents this month, closed this month, open carry-over
  - Training delinquency count and names
  - Designed to be printed or exported for submission to Installation Security
- [ ] **Add to Reports module** — Integrate all security reports into existing Reports nav section (Section 10).

---

### PHASE 3: Physical Security (Future — Requires Owner Approval)

> **Governed by DoDM 5200.01 Vol 3, AFI 31-101, AFI 16-1404. These features are appropriate for a unit-level tool because no enterprise system tracks these — they are inherently local. Each sub-feature is independent and can be built incrementally. ⚠️ Critical constraint: NEVER store actual combinations or classified content in this unclassified SharePoint system.**

#### 11k. Key Control & Security Container Management — 🤝

- [ ] **Security container registry** — Track all containers storing classified:
  - Serial number, manufacturer, lock type, GSA rating
  - Location (building/room), assigned org
  - Date placed in service, date combination last changed
  - Persons with access (linked to `CCSD_Personnel`)
  - ✦ Combinations must be changed annually and upon departure of any person with knowledge (DoDM 5200.01 Vol 3). App tracks change dates and generates overdue alerts.
  - ⚠️ **Do NOT store actual combinations.** Track metadata only (combination record exists, where Part 2B is stored).
- [ ] **SF-702 digital check log** — Daily end-of-day check records per container:
  - Date, time checked, checked by, status (Secured / Found Unsecured), comments
  - ✦ Required for every container holding classified (DoDM 5200.01 Vol 3)
  - Alert if a container has no check recorded by close of business
  - Discrepancy auto-creates a security incident (Category 10 or 17)
- [ ] **SF-701 area check log** — End-of-day area security checks:
  - Date, time, area name, checked by, all clear (Yes/No), discrepancies noted
  - Two-person integrity (TPI) tracking where required (Top Secret, COMSEC)
- [ ] **Combination change tracking** — Date changed, reason (annual/departure/compromise), who performed change, who witnessed, new access roster.
- [ ] **Overdue alerts** — Automated alerts for: combination change overdue (>12 months), daily check missed, container not checked after personnel departure.
- [ ] **Requires:** `CCSD_SecurityContainers` list, `CCSD_ContainerChecks` list, `CCSD_AreaChecks` list

#### 11l. Visitor Control & Restricted Area Management — 🤝

- [ ] **Visitor log** — Digital visitor register:
  - Visitor name, organization, date, time in, time out
  - Purpose of visit, government sponsor/escort
  - Clearance verified (Yes/No, date verified, verifier, method — DISS query)
  - Badge number (if issued)
  - ✦ Required for areas where classified is stored/processed (DoDM 5200.01 Vol 3)
- [ ] **Restricted area registry** — Track controlled/restricted/exclusion areas:
  - Area name/number, classification (RA/CA/Exclusion), location, owning org
  - Maximum classification level, access requirements
- [ ] **Access roster management** — Per-area authorized personnel list:
  - Person (linked), authorization date, expiration, authorizing official, basis
  - ✦ AF Form 2586 tracking (Unescorted Entry Authorization)
  - Auto-removal from roster upon personnel departure or clearance change
- [ ] **Requires:** `CCSD_VisitorLog` list, `CCSD_RestrictedAreas` list, `CCSD_AreaAccessRoster` list

---

### PHASE 4: Information Security (Future — Requires Owner Approval)

> **Governed by DoDM 5200.01 Vols 1-4, AFI 16-1404, EO 13526. ⚠️ Critical: Document tracking must use UNCLASSIFIED short titles/control numbers only. No classified content in the SPA.**

#### 11m. Classification Management & CUI Tracking — 🤝

- [ ] **Derivative classifier roster** — Track who is trained to perform derivative classification:
  - Person, training date, expiration (2-year cycle per EO 13526 Sec 2.1(d))
  - ✦ Authority suspended if training lapses — status indicator in app
- [ ] **Security Classification Guide (SCG) registry** — Catalog of applicable SCGs:
  - Title (unclassified), version, date, responsible OCA, distribution, storage location reference
  - Review due date alerts
- [ ] **CUI category reference** — Quick-reference of CUI categories/subcategories the unit handles, with marking requirements per 32 CFR Part 2002
- [ ] **CUI incident tracking** — Improper handling, marking, or transmission of CUI — feeds into the incident management system (Category 16)
- [ ] **Requires:** No new lists — uses `CCSD_SecurityIncidents` (Category 16) and new columns on existing lists

#### 11n. Document Accountability & Destruction Records — 🤝

- [ ] **Classified document registry** (unclassified metadata only):
  - Control number, classification level, date of document, date received
  - Received from, copy number, current custodian, storage location (container ID)
  - ✦ Top Secret requires continuous accountability and annual inventory (DoDM 5200.01 Vol 3)
  - ⚠️ Use unclassified short titles and control numbers ONLY
- [ ] **Annual inventory tracking** — For Top Secret material:
  - Date of last inventory, next due, discrepancies found, inventory conductor
  - Overdue alerts
- [ ] **Destruction records:**
  - Document ID, classification level, date destroyed, method, destroying official, witness(es)
  - ✦ Two witnesses required for Top Secret (DoDM 5200.01 Vol 3)
  - ✦ Top Secret destruction records retained 5 years
- [ ] **Requires:** `CCSD_ClassifiedDocuments` list, `CCSD_DestructionRecords` list

---

### PHASE 5: OPSEC & Industrial Security (Future — Requires Owner Approval)

> **OPSEC governed by DoDD 5205.02E, DoDM 5205.02, AFI 10-701. Industrial Security governed by 32 CFR 117 (NISPOM). These are program management features, not individual personnel tracking.**

#### 11o. OPSEC Program Compliance — 🤝

- [ ] **OPSEC program dashboard:**
  - Coordinator appointed (name, appointment date, letter reference) — ✦ required (AFI 10-701)
  - Critical Information List (CIL) current version, last review date, next review due — ✦ annual review required
  - Last assessment date, next due — ✦ annual assessment required (AFI 10-701)
  - Training compliance rate (all personnel: initial + annual OPSEC awareness)
- [ ] **CIL version tracking** — Version history, approval dates, dissemination tracking. ⚠️ CIL content itself may be sensitive; track metadata only, store actual CIL separately.
- [ ] **Assessment findings tracker** — Finding ID, description, risk level, recommended countermeasure, assigned OPR, due date, status (open/closed)
- [ ] **OPSEC training tracker** — Per person: initial awareness date, annual refresher date. Coordinator specialized training (OPSEC Fundamentals Course) tracked separately.
- [ ] **Requires:** `CCSD_OPSECProgram` list (or repurpose `CCSD_Config` for program metadata)

#### 11p. Industrial Security / Contractor Management — 🤝

- [ ] **DD-254 registry** — Track Department of Defense Contract Security Classification Specifications:
  - Contract number, contractor name, issuing office, date issued, last revision
  - Classification level authorized, SAP required (Yes/No — no details)
  - Expiration date, status (Active/Expired/Revised)
  - Review tracking: last reviewed, next review due
- [ ] **Contractor personnel roster:**
  - Name, company, contract number, DD-254 reference
  - Clearance level (as verified in DISS — record verification, not raw data)
  - Access granted, access start/end dates, escort requirements
  - Clearance verification log: date verified, verified by, method, result
  - ✦ Clearances must be verified in DISS before granting access (32 CFR 117)
- [ ] **Facility Clearance (FCL) tracking:**
  - Company name, CAGE code, FCL level, verification date, verified by
- [ ] **Contractor visitor certification:**
  - Visit request reference, dates authorized, clearance verified, purpose, government sponsor
  - ◇ Long-term recurring visit requests: expiration tracking, renewal alerts
- [ ] **Contractor security briefing/debriefing log** — Date briefed, briefer, topics, date debriefed
- [ ] **Requires:** `CCSD_DD254Registry` list, `CCSD_ContractorPersonnel` list

---

### SharePoint Lists — Data Model

> **Phase 1 requires 3 lists (SecurityRecords, SecurityIncidents, Notifications). Phases 3-5 add up to 10 more lists. Create Phase 1 lists first.**

#### Phase 1 Lists — 👤 (Create Before Building)

##### `CCSD_SecurityRecords` — NEW (expanded from original with 6 additional training fields)

| Column Name | Type | Notes | Source |
|-------------|------|-------|--------|
| Title | Single line (default) | Auto-populated: "Smith, John - TS/SCI" | App logic |
| PersonID | Lookup → CCSD_Personnel | The member this record belongs to | Manual / DISS import |
| ClearanceLevel | Choice | `None`, `Confidential`, `Secret`, `Top Secret` | DISS |
| ClearanceStatus | Choice | `Active`, `Interim`, `Expired`, `Suspended`, `Revoked`, `Denied`, `Not Cleared`, `Administrative Withdrawal` | DISS |
| PositionSensitivity | Choice | `Non-sensitive`, `Noncritical-Sensitive`, `Critical-Sensitive`, `Special-Sensitive` | Position assignment |
| InvestigationType | Choice | `T1`, `T2`, `T3`, `T4`, `T5`, `T5R`, `CV` | DISS |
| InvestigationOpenDate | Date | When investigation was initiated | DISS |
| InvestigationDate | Date | Date of most recent investigation close | DISS |
| EligibilityDate | Date | Date eligibility was formally granted | DISS |
| LastSF86Date | Date | Date of most recent SF-86 submission | DISS / manual |
| NextSF86DueDate | Date | Calculated: LastSF86Date + interval by level. Can be manually overridden. | App logic / DISS |
| CVEnrolled | Yes/No | Enrolled in Continuous Vetting | DISS |
| CVAlertStatus | Choice | `No Alerts`, `Alert Pending Review`, `Alert Resolved` | DISS / manual |
| NIPRAccess | Yes/No | Has NIPR access determination | Manual |
| SIPRAccess | Yes/No | Has SIPR access determination | Manual |
| JWICSAccess | Yes/No | Has JWICS access determination | Manual |
| SCIAccess | Yes/No | Has SCI access (boolean — details in Scattered Castles) | Manual |
| SAPAccess | Yes/No | Has SAP access (boolean — details in program systems) | Manual |
| NDASignedDate | Date | SF-312 NDA signed date | Manual |
| NDAOnFile | Yes/No | SF-312 confirmed on file (for cases where date unknown) | Manual |
| InitialBriefingDate | Date | ✦ Required before access (DoDM 5200.01) | Manual |
| AnnualRefresherDate | Date | ✦ Every 12 months (DoDM 5200.01) | Manual |
| DerivedClassDate | Date | ✦ Every 24 months (EO 13526 Sec 2.1(d)) | Manual |
| CIAwarenessDate | Date | ✦ Every 12 months (DoDI 5240.06) — **NEW** | Manual |
| InsiderThreatDate | Date | ✦ Every 12 months (EO 13587) — **NEW** | Manual |
| CUITrainingDate | Date | ✦ Every 12 months (DoDI 5200.48) — **NEW** | Manual |
| DoDID | Single line of text | DoD ID / EDIPI — match key for DISS imports — **NEW** | DISS |
| SMOCode | Single line of text | Owning Security Management Office code — **NEW** | DISS |
| SourceFile | Single line of text | Name of Excel file this record was last updated from | App logic |
| LastImportDate | Date | When last updated via DISS Excel import | App logic |
| Notes | Multiple lines of text | Security manager notes | Manual |

> **Changes from original schema:** Added `PositionSensitivity`, `InvestigationOpenDate`, `EligibilityDate`, `CVAlertStatus`, `SAPAccess`, `NDAOnFile`, `CIAwarenessDate`, `InsiderThreatDate`, `CUITrainingDate`, `DoDID`, `SMOCode` (11 new columns). Changed `InvestigationType` choice `CE/CV` to just `CV` (CE is deprecated predecessor).

##### `CCSD_SecurityIncidents` — NEW (expanded with SOR/appeal fields)

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Auto-populated with case number |
| CaseNumber | Single line of text | Generated: `SEC-[YYYY]-[NNNN]` or `ISV-[YYYY]-[NNNN]` |
| PersonID | Lookup → CCSD_Personnel | Subject of the incident |
| ReportedBy | Lookup → CCSD_Personnel | Who reported it |
| IncidentCategory | Choice | 18 categories per SEAD 3 alignment (see 11e above) |
| IncidentSubType | Single line of text | Sub-type within category (e.g., "Bankruptcy Ch7") |
| SEAD4Guidelines | Single line of text | Applicable guideline letter(s): "B,C" or "F" or "J,E" |
| IncidentDate | Date | Date the incident occurred |
| ReportedDate | Date | Date the incident was reported |
| ReportingDeadline | Date | Calculated from category + agency policy |
| TimelinessFlag | Choice | `On Time`, `Late`, `Significantly Late` |
| Severity | Choice | `Infraction`, `Violation`, `Compromise`, `Low`, `Medium`, `High`, `Critical` |
| ReportingSource | Choice | `Self-Report`, `Supervisor`, `Commander`, `Automated/CV`, `AFOSI`, `External Agency`, `Anonymous` |
| Status | Choice | `Reported`, `Preliminary Inquiry`, `Reported to DISS`, `Interim Action Taken`, `Under Investigation`, `Investigation Complete`, `Adjudication`, `SOR Issued`, `Response/Appeal`, `Resolved`, `Closed — No Action Required`, `Closed — Favorable`, `Closed — Adverse Action`, `Referred to External Agency`, `Referred to AFOSI`, `Administrative Withdrawal` |
| Description | Multiple lines of text | Visible only to Security role |
| InvestigationNotes | Multiple lines of text | Visible only to Security role |
| DamageAssessment | Multiple lines of text | For spillage/unauthorized disclosure (Security role only) |
| SORIssuedDate | Date | Date Statement of Reasons was issued — **NEW** |
| SORGuidelines | Single line of text | SEAD 4 guidelines cited in SOR (e.g., "F,E") — **NEW** |
| SORResponseDeadline | Date | SOR date + 30 days — **NEW** |
| SORResponseDate | Date | Date subject's response was received — **NEW** |
| SORResult | Choice | `Sustained`, `Modified`, `Reversed`, `Pending` — **NEW** |
| AppealFiledDate | Date | — **NEW** |
| AppealOutcome | Choice | `Upheld`, `Overturned`, `Modified`, `Pending` — **NEW** |
| ResolutionDate | Date | |
| ResolutionSummary | Multiple lines of text | Visible only to Security role |
| Outcome | Choice | `No Action`, `Letter of Caution`, `Clearance Retained with Conditions`, `Corrective Action Taken`, `Access Suspended`, `Eligibility Revoked`, `Eligibility Denied`, `Referred`, `Administrative Withdrawal` |
| Conditions | Multiple lines of text | If outcome includes conditions (e.g., "Complete financial counseling") — **NEW** |
| DebriefingDate | Date | If clearance revoked — SF-312 debriefing date — **NEW** |
| StatusHistoryJSON | Multiple lines of text | JSON array: `[{status, changedBy, changedAt, notes}]` |
| OrgID | Lookup → CCSD_Organizations | Member's org at time of incident |
| Notes | Multiple lines of text | |

> **Changes from original:** Added 10 new columns for SOR/appeal tracking, damage assessment, timeliness, conditions, and debriefing. Expanded Status choices from 10 to 16. Expanded Outcome choices. Added SEAD 4 guideline mapping fields.

##### `CCSD_Notifications` — NEW (unchanged from original)

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
| IsRead | Yes/No | Per-recipient read tracking |
| Notes | Multiple lines of text | |

> **Note:** `IsRead` for broadcast/org notifications requires a separate `CCSD_NotificationReceipts` list (one row per recipient per notification) or a JSON field. Design TBD during implementation.

#### Phase 3-5 Lists — 👤 (Create Only When Approved)

| List | Phase | Purpose | Est. Columns |
|------|-------|---------|-------------|
| `CCSD_SecurityContainers` | 3 | Container registry (SF-700 metadata) | ~12 |
| `CCSD_ContainerChecks` | 3 | SF-702 daily check records (high volume) | ~6 |
| `CCSD_AreaChecks` | 3 | SF-701 area check records | ~7 |
| `CCSD_VisitorLog` | 3 | Visitor entries with in/out times | ~10 |
| `CCSD_RestrictedAreas` | 3 | Area registry | ~8 |
| `CCSD_AreaAccessRoster` | 3 | Personnel authorized per area (junction table) | ~6 |
| `CCSD_ClassifiedDocuments` | 4 | Document accountability (unclassified metadata only) | ~10 |
| `CCSD_DestructionRecords` | 4 | Destruction logs | ~8 |
| `CCSD_DD254Registry` | 5 | DD-254 contract security specifications | ~10 |
| `CCSD_ContractorPersonnel` | 5 | Contractor roster with clearance verification | ~12 |

### Columns to Add to Existing Lists — 👤

| List | Column | Type | Needed For |
|------|--------|------|------------|
| `CCSD_AppRoles` | (no schema changes) | — | Add `Security` as a role value in list data |
| `CCSD_Personnel` | `DoDID` | Single line of text | Match key for DISS imports (optional — can use existing ID) |

> **Note:** The `Security` role is added as a data entry in `CCSD_AppRoles`, not a schema change.

### Implementation Roadmap

| Phase | Scope | Priority | Dependencies | Est. Effort |
|-------|-------|----------|-------------|-------------|
| **Phase 1** | Personnel Security Core: clearance tracking, 6 training types, SF-86 due dates, DISS import, admin roster, self-service view, CSV export | **P1 — Build First** | `CCSD_SecurityRecords` list, `Security` role in `CCSD_AppRoles`, sample DISS Excel file | Large (11a-11d) |
| **Phase 2** | Incident & Case Management: 18 SEAD 3 categories, 10-stage lifecycle, SOR/appeal tracking, case numbers, notifications, audit logging, reporting | **P1 — Build Second** | Phase 1 complete, `CCSD_SecurityIncidents` list, `CCSD_Notifications` list | Large (11e-11j) |
| **Phase 3** | Physical Security: key control, container checks (SF-702), area checks (SF-701), visitor log, restricted area management | **P2 — Owner Approval Needed** | 6 new SharePoint lists (11k-11l) | Medium |
| **Phase 4** | Information Security: classification management, CUI tracking, document accountability, destruction records | **P2 — Owner Approval Needed** | 2 new SharePoint lists (11m-11n) | Medium |
| **Phase 5** | OPSEC & Industrial Security: OPSEC program compliance, CIL tracking, DD-254 registry, contractor management | **P3 — Owner Approval Needed** | 2 new SharePoint lists (11o-11p) | Medium |

### What App Logic Handles vs. SharePoint vs. Power Automate

| Responsibility | Handled By | Examples |
|---------------|-----------|---------|
| **Data storage and retrieval** | SharePoint Lists | All security records, incidents, notifications, audit logs |
| **Role-based access control** | App Logic (Index.html) | Query-level filtering, UI visibility, obscured fields |
| **Case number generation** | App Logic | `SEC-YYYY-NNNN` sequential generation |
| **SF-86 due date calculation** | App Logic | `LastSF86Date + interval` with clearance-level-aware intervals |
| **Training compliance calculation** | App Logic | Date + cycle period, status badges |
| **DISS Excel parsing** | App Logic (SheetJS) | Client-side .xlsx parsing and column mapping |
| **Audit logging** | App Logic → SharePoint | Every security action writes to `CCSD_AppAuditLog` |
| **In-app notifications** | App Logic → SharePoint | Write to `CCSD_Notifications`, render in notification panel |
| **Email notifications (future)** | Power Automate | Triggered by SharePoint list item creation/modification |
| **Scheduled reminders** | App Logic (on page load) | Check due dates on each session, generate notifications if thresholds met |
| **DISS data maintenance** | 👤 Manual (outside app) | Monthly DISS export to Excel, upload to app |
| **Clearance adjudication** | External (DCSA CAF) | App tracks status; adjudication happens outside the app |
| **Investigation conduct** | External (DCSA/AFOSI) | App tracks referral and status; investigation happens outside |

### ⚖️ Legal/Policy-Sensitive Areas Requiring Human Review

> **The following areas involve legal, regulatory, or policy decisions that MUST be reviewed by the project owner, the Unit Security Manager, the Staff Judge Advocate, and/or the Information Security Program Manager before implementation. Claude should NOT make unilateral decisions on these.**

1. **✦ Privacy Act compliance** — The SPA maintaining security PII must operate under an applicable System of Records Notice (SORN). Verify coverage under DoDSORN 0005 or equivalent. **Action: Consult with base Privacy Act officer.**
2. **✦ CUI marking of exports** — CSV exports of security data must include CUI markings per DoDI 5200.48. Determine exact banner/footer text. **Action: Consult with Information Security Program Manager.**
3. **✦ SharePoint permissions alignment** — SharePoint list-level permissions should align with app-level RBAC. App logic enforces role-based queries, but a determined user with direct SharePoint access could bypass the app. Determine whether SharePoint broken inheritance is needed on security lists. **Action: Consult with SharePoint admin.**
4. **✦ Incident category legal implications** — Some incident categories (criminal conduct, substance abuse, mental health) have legal sensitivities. The mental health carve-out from SEAD 3 must be prominently displayed. **Action: Consult with SJA.**
5. **✦ SOR/appeal tracking** — SOR documents contain highly sensitive PII/PHI. Determine whether SOR content should be stored in the app or only tracked by reference (date, guidelines cited, outcome). **Action: Consult with Personnel Security office.**
6. **✦ Data retention periods** — Verify retention periods against AF Records Disposition Schedule (RDS) via AFRIMS for security incident records, notifications, and audit logs. **Action: Consult with Records Manager.**
7. **✦ Classified system boundary** — The SPA runs on unclassified SharePoint Online. Ensure no feature design could inadvertently capture classified information (document titles, incident descriptions referencing classified programs, etc.). **Action: Consult with Information Security Program Manager.**
8. **◇ DISS data replication** — Storing DISS export data in SharePoint creates a secondary copy of security clearance data. Verify this is acceptable under DoDM 5200.02 and local policy. Most units do this via Excel today — the app simply digitizes that existing practice. **Action: Confirm with Unit Security Manager.**
9. **◇ Combination storage prohibition** — Physical security features must NEVER store actual safe/container combinations. UI should display prominent warnings. **Action: Enforce in code and document in user guide.**
10. **◇ Contractor PII** — If tracking contractor personnel, verify PII handling requirements under the applicable contract and FAR/DFARS clauses. **Action: Consult with Contracting Officer.**

### Research Resolution Summary

> **The 10 original "Needs Research" items from the pre-research TODO have been resolved as follows:**

| Original Research Item | Resolution |
|----------------------|------------|
| 🔬 DISS Excel export format | **Partially resolved.** Common DISS export columns documented in 11d. Still need a sample file from the project owner to confirm exact headers. **Remains a blocker.** |
| 🔬 Incident categories | **✅ Resolved.** 18 categories defined in 11e, aligned to SEAD 3's 15 reportable event categories plus 3 additional types (info security, physical security, other). |
| 🔬 Incident resolution steps | **✅ Resolved.** 10-stage lifecycle with type-dependent branching defined in 11f. SOR/appeal workflow defined in 11g. |
| 🔬 Notification delivery method | **✅ Resolved.** In-app notifications for Phase 1-2. Power Automate email as Phase 2+ enhancement (depends on Section 14). |
| 🔬 Continuous Vetting tracking | **✅ Resolved.** Dual-mode tracking defined in 11h: legacy PR countdown for non-CV-enrolled; "Enrolled in CV" display for CV-enrolled. Both models supported during TW 2.0 transition. |
| 🔬 SCI/SAP access tracking | **✅ Resolved.** Boolean fields (`SCIAccess`, `SAPAccess`) appropriate for unit level. Detailed SCI compartment tracking is SSO responsibility (Scattered Castles), not unit-level. |
| 🔬 Physical security features | **✅ Resolved.** Full feature set defined in Phase 3 (11k-11l). Recommended as separate phase requiring owner approval. Key constraint: no combinations in unclassified system. |
| 🔬 Information security features | **✅ Resolved.** Full feature set defined in Phase 4 (11m-11n). Document accountability uses unclassified metadata only. |
| 🔬 OPSEC integration | **✅ Resolved.** Program compliance tracking defined in Phase 5 (11o). CIL metadata tracking only (actual CIL content stored separately). |
| 🔬 Industrial security | **✅ Resolved.** DD-254 registry and contractor management defined in Phase 5 (11p). Unit tracks verification records, not raw DISS/JADE data. |

---

## 12. Supervisor Hub (P1) — 🤝

> **New major feature. Adds a dedicated Supervisor-only section to the SPA that consolidates team oversight, pending actions, people management, and cross-module visibility into a single landing page. Requires new SharePoint lists for some features; many features build on existing data.**

### Known Requirements

> **These are confirmed by the project owner or directly derivable from existing app code and data.**

#### 12a. Role-Based Visibility & Access Control — 💻

> **Existing infrastructure:** The `Supervisor` role is already detected two ways: (1) via `CCSD_AppRoles` where `Role = 'Supervisor'`, and (2) via the `IsSupervisor` boolean flag on `CCSD_Personnel` (see `Index.html:1998,2025`). Both paths push `'Supervisor'` into `APP.state.roleNames`. Existing gate functions `canReviewTraining()` and `canManageInOut()` already include the Supervisor role.

- [ ] **New "Supervisor Hub" nav tab** — Add to main navigation. Only visible when `hasAnyRole(['Supervisor','App Admin'])` returns true. Hidden entirely for non-supervisors (no empty-state placeholder).
- [ ] **New route** — `#supervisor` hash route, guarded by role check. If a non-supervisor navigates directly to `#supervisor`, redirect to `#home` with a toast ("Access restricted to supervisors").
- [ ] **Team scope definition** — The Hub operates on the supervisor's "team," defined as:
  - **Primary:** All active personnel in `CCSD_Personnel` where `SupervisorPersonID.Id` = current user's personnel ID (direct reports).
  - **Extended:** All active personnel in the supervisor's org (`OrgID`) and its descendant orgs (using the existing `getOrgAndDescendants()` function, see `Index.html:4104`).
  - **Toggle:** A scope toggle at the top of the Hub: "My Direct Reports" vs. "My Organization" to switch between primary and extended views.
- [ ] **App Admin sees all** — Users with `App Admin` role see the Hub with access to all personnel (no org/supervisor filter). A dropdown lets them select any org to scope the view.
- [ ] **Keyboard shortcut** — Register `Alt+V` (for superVisor) to navigate to the Hub, gated by role check (same pattern as `Alt+D` for diagnostics in `Index.html`).

#### 12b. Supervisor Landing Page / Overview Dashboard — 💻

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

#### 12c. Team Roster & Status Visibility — 💻

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

#### 12d. People Management & Administrative Tools — 💻

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

#### 12e. Pending Actions, Queues & Alerts — 💻

> **Consolidates all actionable items a supervisor needs to act on across all modules into a single prioritized queue.**

- [ ] **Unified action queue** — Single sortable list combining all pending items from Section 12b, with:
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

#### 12f. Cross-Module Connections — 💻

> **The Supervisor Hub does not replace existing modules — it provides a supervisor-scoped lens into them.**

- [ ] **Link to Calendar** — "View Team Calendar" button that navigates to `#calendar` with the org scope pre-set to the supervisor's org.
- [ ] **Link to Training** — "View Team Training" button that opens the existing team training compliance modal (`getTeamTrainingModel()` at `Index.html:6939`), or navigates to `#training` with the org filter applied.
- [ ] **Link to Requests** — "View Team Requests" button that opens the existing supervisor request dashboard (`openSupervisorRequestDashboard()` at `Index.html:4099`), or navigates to `#requests` with a team filter.
- [ ] **Link to In/Out** — "View In/Out Cases" button that navigates to `#inout` with the org filter applied to show only the supervisor's team's cases.
- [ ] **Link to Assets** — "View Team Assets" button that navigates to `#assets` with a filter showing hardware/software assigned to team members.
- [ ] **Link to Security** — "View Team Security Status" (if Security module is built) navigates to `#security`. Supervisors see limited summary view per Section 11 rules.
- [ ] **Context preservation** — When navigating from the Hub to another module via these links, the module should respect the org/team filter. When the user navigates back to `#supervisor`, the Hub state should be preserved.

#### 12g. Reporting, Dashboards & Drilldowns — 💻

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

#### 12h. Supervisor-Only Workflows & Approvals — 💻

> **Workflows that are exclusive to the Supervisor Hub and do not exist in other modules.**

- [ ] **Leave request approval** — Full approve/deny workflow as described in Section 12e. This is the primary new workflow.
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

## 13. SharePoint Lists to Create — 👤

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

## 14. External Integrations (Future) — 🤝

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

## 15. Column Additions to Existing Lists — 👤

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

## Priority Action Summary

### 🔴 Do First (blockers for existing features)
1. **Create `CCSD_TimeOff` list** — The Calendar module is built but has no data source yet

### 🟡 Do When Ready — Security Module (Section 11)
2. **Create `CCSD_SecurityRecords` list** (30 columns) — Enables Phase 1: Personnel Security Core
3. **Add `Security` role entries to `CCSD_AppRoles`** — Required for Security module role-based access
4. **👤 Obtain sample DISS Excel export** — #1 blocker for the DISS import feature. Provide one monthly export file so column mapping can be built.
5. **👤 Verify SheetJS CDN access** from `usaf.dps.mil` — If blocked, library must be inlined (~500KB)
6. **Create `CCSD_SecurityIncidents` list** (30 columns) — Enables Phase 2: Incident & Case Management
7. **Create `CCSD_Notifications` list** (11 columns) — Enables notification framework
8. **⚖️ Consult Privacy Act officer** — Verify SORN coverage for security PII in SharePoint (see Legal/Policy section)
9. **⚖️ Consult Information Security Program Manager** — Confirm CUI marking requirements for CSV exports

### 🟡 Do When Ready — Other Features
10. **Add `Supervisor` role entries to `CCSD_AppRoles`** — Required for Supervisor Hub (Section 12)
11. **Create `CCSD_ConferenceRooms` + `CCSD_RoomReservations`** — Enables conference room scheduling
12. **Add audit columns** to `CCSD_HardwareAssets` — Enables inventory audit mode
13. **Azure AD App Registration** — Enables Outlook calendar integration (longest lead time)

### 🟢 Low Urgency (nice-to-have prerequisites)
14. **Add `TotalLicenses`** to software assets — Enables license dashboard
15. **Add `WarrantyExpiration`** to hardware assets — Enables warranty alerts
16. **Create `CCSD_Announcements`** — Enables Home dashboard news banner
17. **Set up Teams Incoming Webhook** — Enables Teams notifications
