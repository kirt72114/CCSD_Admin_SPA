# CCSD All-Things Administrative SPA — TODO

Master task list for pending features and prerequisites.
Updated: 2026-04-19

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

## Schema Audit Status — 2026-04-18 ✅

A full audit of all 76 expected SharePoint lists and their columns was run against
the production Database site using `database-audit-webpart.html`. **All 76 lists
and libraries have been created with all required columns, types, and choice
values. The schema is fully deployed.**

Use `database-audit-webpart.html` any time a new list or column is added to re-verify.

---

## 1. Microsoft Graph API — Outlook Calendar Integration (P2) — 🤝

> **Requires Azure AD tenant admin actions before any code work can begin. This
> is the longest prerequisite chain in the TODO.**

- [ ] **Step 1: Azure AD App Registration** — 👤 (requires Global Admin or Application Admin role)
  1. Log into **Azure Portal** (portal.azure.com) with tenant admin account
  2. Navigate to **Azure Active Directory** > **App registrations** > **New registration**
  3. Name: `CCSD-Admin-SPA-OutlookIntegration`
  4. Supported account types: Single tenant
  5. Redirect URI: Web → SharePoint site URL
  6. Note the **Application (client) ID** and **Directory (tenant) ID**
  7. Under **API permissions** add delegated Graph permissions:
     - `Calendars.Read`
     - `Calendars.ReadWrite`
     - `User.Read.All` (for free/busy lookup)
  8. Grant admin consent for the tenant
  9. Under **Authentication**: Enable "ID tokens" and "Access tokens"

- [ ] **Step 2: Verify network access** — 👤
  - Ensure `login.microsoftonline.com` and `graph.microsoft.com` are reachable
    from SharePoint page context (no CSP/firewall blocks).

- [ ] **Step 3: Provide Client ID and Tenant ID to Claude** — 👤

- [ ] **Step 4: Build MSAL integration** — 💻 (after Step 3)
- [ ] **Step 5: Build free/busy schedule view** — 💻
- [ ] **Step 6: Add admin config panel for IDs** — 💻
- [ ] **Step 7: Token refresh and error handling** — 💻

---

## 2. Barcode / Asset Tag Scanning (P3) — 🤝

- [ ] **Your decision needed**: This requires camera access via the browser.
  SharePoint Online pages *can* use `getUserMedia()` but your network security
  policy may block it. Test by visiting any website that requests camera access
  from a work machine.
  - If camera works: Claude can build a barcode scanner using a JS library (QuaggaJS or ZXing)
  - If camera is blocked: Skip this — manual asset tag entry is the fallback

---

## 3. Photo / Avatar Support (P3) — 👤 decision needed

- [ ] **Choose an approach**:
  - Option A: Use SharePoint profile photos (automatic if users have O365 profiles with photos)
  - Option B: Add a `PhotoUrl` column to `CCSD_Personnel` for manual upload
  - Let Claude know which approach you prefer

---

## 4. Email Notification Integration (P1) — 🤝

> **Requires Power Automate flow. Enables email delivery of in-app notifications.**

- [ ] **Create Power Automate flow** — 👤
  - Trigger: When an item is created in `CCSD_Notifications`
  - Condition: `NotificationType = 'Security'` (or configurable filter)
  - Action: Send an email (V2) via O365 connector
  - For `Sensitive` notifications, use generic email body: "You have a notification. Please log in."
  - Do NOT include PII or notification body in the email

- [ ] **Build admin config panel for email flow settings** — 💻

---

## 5. Scheduled Report Email (P3) — 🤝

- [ ] **Requires Power Automate** — See Section 4 notes. Generate PDF/CSV reports
  on schedule and email to configured recipients.

---

## 6. DISS Excel Ingestion (P2) — 🤝

> **Per DoDM 5200.02, DISS is the authoritative source for clearance data. Most
> units export monthly to Excel because DISS has limited reporting. This feature
> ingests those exports into `CCSD_SecurityRecords`.**

- [ ] **👤 Provide sample DISS Excel export** — You need to provide one sample
  file so column headers can be mapped. This is the #1 blocker for this feature.

Once the sample is provided, Claude will build:

- [ ] **Upload interface** — 💻 Security role users upload `.xlsx` via file input in admin view
- [ ] **Column mapping configuration** — 💻 Stored in `CCSD_Config` list. Supports remapping
- [ ] **Excel parsing** — 💻 Client-side SheetJS/xlsx library
- [ ] **Preview before commit** — 💻 Diff table: new (green), changed (yellow), unchanged (grey), missing (orange). Admin confirms before writing.
- [ ] **Upsert logic** — 💻 Match by DoD ID/EDIPI (preferred) or SSN-last-4 + name
- [ ] **Upload history** — 💻 Each upload logged: date, uploader, filename, counts

---

## 7. Security Module — Future Phases

> **Phases 1 and 2 are complete (Personnel Security Core and Incident Management).
> The phases below require owner approval before any build work.**

### Phase 3: Physical Security — 🤝

> **Governed by DoDM 5200.01 Vol 3, AFI 31-101, AFI 16-1404. Appropriate for a
> unit-level tool because no enterprise system tracks these — they are inherently
> local. ⚠️ Critical constraint: NEVER store actual combinations or classified
> content in this unclassified SharePoint system.**

#### 7a. Key Control & Security Container Management

- [ ] **Security container registry** — Track containers storing classified:
  - Container ID, location, classification level, custodian
  - Last combination change date, next scheduled change (annual)
  - SF-700 on file (Yes/No), SF-700 location pointer (safe name, not contents)
- [ ] **SF-702 digital check log** — Daily end-of-day check records per container
- [ ] **SF-701 area check log** — End-of-day area security checks
- [ ] **Combination change tracking** — Date, reason, performer, witness, new access roster
- [ ] **Overdue alerts** — Combination change overdue, daily check missed, unchecked after personnel departure

#### 7b. Visitor Control & Restricted Area Management

- [ ] **Visitor log** — Digital visitor register with escort tracking
- [ ] **Restricted area registry** — Controlled/restricted/exclusion areas
- [ ] **Access roster management** — Per-area authorized personnel list

### Phase 4: Information Security — 🤝

#### 7c. Classification Management & CUI Tracking

- [ ] **Derivative classifier roster** — Training-current personnel authorized to derivatively classify
- [ ] **Security Classification Guide (SCG) registry** — Catalog of applicable SCGs
- [ ] **CUI category reference** — Quick-reference per 32 CFR Part 2002
- [ ] **CUI incident tracking** — Improper handling/marking/transmission (feeds into existing incident system as Category 16)

#### 7d. Document Accountability & Destruction Records

- [ ] **Classified document registry** (unclassified metadata only): Control number, classification, custodian, location
- [ ] **Annual inventory tracking** — For Top Secret material
- [ ] **Destruction records** — Date, method, witness, SF-135 references

### Phase 5: OPSEC & Industrial Security — 🤝

#### 7e. OPSEC Program Compliance

- [ ] **OPSEC program dashboard** — CIL status, recent assessments, training status
- [ ] **CIL version tracking** — ⚠️ Track metadata only, store actual CIL separately
- [ ] **Assessment findings tracker** — Finding ID, risk level, countermeasure, OPR, due date, status
- [ ] **OPSEC training tracker** — Initial awareness, annual refresher, coordinator training

#### 7f. Industrial Security / Contractor Management

- [ ] **DD-254 registry** — Contract security classification specifications
- [ ] **Contractor personnel roster** — Clearance level, expiration, sponsor, contract
- [ ] **Facility Clearance (FCL) tracking** — Contractor facility clearance levels
- [ ] **Contractor visitor certification** — Visit authorization letters
- [ ] **Contractor security briefing/debriefing log**

---

## 8. Completed Feature Summary

All standalone code-only features have been built. Major completed modules:

### Core Infrastructure ✅
- SharePoint REST API with audit logging, form digest handling, pagination
- Role-based access control (RBAC) via `CCSD_AppRoles` with scope support
- Notification Framework (16 templates, 3-list architecture, PII detection)
- Audit log coverage for all create/update/delete/view/export actions

### Modules ✅
- **Calendar** — Month/Week/List views, multi-day spanning, drag-to-create,
  conference room scheduling with recurring bookings
- **People** — Full CRUD, onboarding wizard, role-gated visibility
- **Organizations** — Hierarchy, merge tool, contact cards
- **Training** — Catalog, submissions, records, SF-182 workflow, compliance
- **Requests** — Workflow-driven request processing
- **Facilities** — Seat mapping with floor plan overlays, room boundary drawing
- **Assets** — Hardware/software inventory, version compliance, cost center,
  location tracking, inventory audit, software request
- **Security Module (Phases 1-2 MVP)** — Personnel records roster, incident
  management with full tabbed detail modal, SOR tracking, bulk actions
- **Supervisor Hub** — Team roster with filters, unified action queue, reports,
  DPMAP/manning/telework/awards/IDP/disciplinary/overtime/sponsorship trackers
- **Reporting** — Multi-format export, filter-based queries
- **Home Dashboard** — KPI strip, recent activity, notifications

---

## Priority Action Summary

### 🔴 Do First — Unblocks Features
1. **Azure AD App Registration** (Section 1) → unblocks Outlook Calendar integration
2. **Power Automate email flow** (Section 4) → unblocks email notifications
3. **Sample DISS Excel file** (Section 6) → unblocks DISS ingestion

### 🟡 Do When Ready — Future Phases
- Security Phase 3-5 (Physical, Information, OPSEC, Industrial) — requires owner approval

### 🟢 Low Urgency
- Barcode scanning (hardware decision)
- Photo/avatar approach (policy decision)
- Scheduled report email (Power Automate)
