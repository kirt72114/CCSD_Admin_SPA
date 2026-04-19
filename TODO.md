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
> The SPA already writes to `CCSD_Notifications` and `CCSD_NotificationReceipts`.
> This flow watches for new notifications, resolves recipient email addresses,
> and sends an email — then stamps the receipt so the SPA knows email was sent.

- [ ] **Build admin config panel for email flow settings** — 💻

- [ ] **Create Power Automate flow: "CCSD – Email Notification Dispatcher"** — 👤

### Flow: CCSD – Email Notification Dispatcher

**Flow type:** Automated cloud flow
**Connection references:** SharePoint (site owner account), Office 365 Outlook

---

#### Trigger

| Setting | Value |
|---|---|
| **Connector** | SharePoint |
| **Trigger** | When an item is created |
| **Site Address** | `https://<tenant>.sharepoint.com/sites/Database` |
| **List Name** | `CCSD_Notifications` |

---

#### Step 1 — Initialize variable: `varRecipientEmails`

| Setting | Value |
|---|---|
| **Action** | Initialize variable |
| **Name** | `varRecipientEmails` |
| **Type** | String |
| **Value** | *(empty)* |

---

#### Step 2 — Initialize variable: `varEmailSubject`

| Setting | Value |
|---|---|
| **Action** | Initialize variable |
| **Name** | `varEmailSubject` |
| **Type** | String |
| **Value** | *(empty)* |

---

#### Step 3 — Initialize variable: `varEmailBody`

| Setting | Value |
|---|---|
| **Action** | Initialize variable |
| **Name** | `varEmailBody` |
| **Type** | String |
| **Value** | *(empty)* |

---

#### Step 4 — Set variable: `varEmailSubject`

| Setting | Value |
|---|---|
| **Action** | Set variable |
| **Name** | `varEmailSubject` |
| **Value** | `CCSD Notification: @{triggerOutputs()?['body/Title']}` |

---

#### Step 5 — Condition: Is Sensitivity Sensitive?

| Left Side | Operator | Right Side |
|---|---|---|
| `@{triggerOutputs()?['body/SensitivityLevel/Value']}` | is equal to | `Sensitive` |

##### If Yes (Sensitive — generic body, no PII)

###### Step 5a — Set variable: `varEmailBody`

| Setting | Value |
|---|---|
| **Action** | Set variable |
| **Name** | `varEmailBody` |
| **Value** | (see HTML below) |

```html
<p>You have a new notification in the CCSD Admin application.</p>
<p><strong>Category:</strong> @{triggerOutputs()?['body/NotificationType/Value']}</p>
<p>For security reasons, notification details are not included in this email.
Please log in to the application to view the full message.</p>
<p><a href="https://<tenant>.sharepoint.com/sites/Database/SitePages/CCSD-Admin.aspx">
Open CCSD Admin</a></p>
```

##### If No (Public/Internal — include body)

###### Step 5b — Set variable: `varEmailBody`

| Setting | Value |
|---|---|
| **Action** | Set variable |
| **Name** | `varEmailBody` |
| **Value** | (see HTML below) |

```html
<p>You have a new notification in the CCSD Admin application.</p>
<p><strong>Category:</strong> @{triggerOutputs()?['body/NotificationType/Value']}</p>
<p><strong>Details:</strong></p>
<p>@{triggerOutputs()?['body/Body']}</p>
<hr/>
<p><a href="https://<tenant>.sharepoint.com/sites/Database/SitePages/CCSD-Admin.aspx">
Open CCSD Admin</a></p>
```

---

#### Step 6 — Condition: Route by AudienceType

> Power Automate does not support `switch` natively in all plans. Use nested
> conditions or a Switch control (available under "Add an action" > "Switch").
> Below uses **Switch** for clarity.

**Switch on:** `@{triggerOutputs()?['body/AudienceType/Value']}`

---

##### Case: `Individual`

###### Step 6a-1 — Get items: Lookup Recipient from CCSD_NotificationReceipts

| Setting | Value |
|---|---|
| **Action** | SharePoint – Get items |
| **Site Address** | `https://<tenant>.sharepoint.com/sites/Database` |
| **List Name** | `CCSD_NotificationReceipts` |
| **Filter Query** | `NotificationIDId eq @{triggerOutputs()?['body/ID']}` |
| **Top Count** | `100` |

###### Step 6a-2 — Apply to each: `value` (from Get items above)

Inside the loop:

**Step 6a-2a — Get item: Lookup personnel email**

| Setting | Value |
|---|---|
| **Action** | SharePoint – Get item |
| **Site Address** | `https://<tenant>.sharepoint.com/sites/Database` |
| **List Name** | `CCSD_Personnel` |
| **Id** | `@{items('Apply_to_each')?['RecipientPersonIDId']}` |

**Step 6a-2b — Condition: Does person have an email?**

| Left Side | Operator | Right Side |
|---|---|---|
| `@{body('Get_item')?['Email']}` | is not equal to | *(empty)* |

If Yes:

**Step 6a-2c — Send an email (V2)**

| Setting | Value |
|---|---|
| **Action** | Office 365 Outlook – Send an email (V2) |
| **To** | `@{body('Get_item')?['Email']}` |
| **Subject** | `@{variables('varEmailSubject')}` |
| **Body** | `@{variables('varEmailBody')}` |
| **Importance** | Normal |
| **Is HTML** | Yes |

**Step 6a-2d — Update item: Stamp receipt with email sent**

| Setting | Value |
|---|---|
| **Action** | SharePoint – Update item |
| **Site Address** | `https://<tenant>.sharepoint.com/sites/Database` |
| **List Name** | `CCSD_NotificationReceipts` |
| **Id** | `@{items('Apply_to_each')?['ID']}` |
| **DeliveryChannel** | `Both` |
| **EmailSentDate** | `@{utcNow()}` |

---

##### Case: `Role`

###### Step 6b-1 — Get items: Lookup personnel by role

| Setting | Value |
|---|---|
| **Action** | SharePoint – Get items |
| **Site Address** | `https://<tenant>.sharepoint.com/sites/Database` |
| **List Name** | `CCSD_NotificationReceipts` |
| **Filter Query** | `NotificationIDId eq @{triggerOutputs()?['body/ID']}` |
| **Top Count** | `500` |

> The SPA already created receipts for all role members when the notification
> was sent. This step retrieves them. The Apply to each loop is identical to
> the Individual case (steps 6a-2a through 6a-2d).

###### Step 6b-2 — Apply to each (same as Step 6a-2)

*(Duplicate the Apply to each block from the Individual case above.)*

---

##### Case: `Organization`

> Same pattern as Role. The SPA resolves all org members into individual
> receipts at send time. Retrieve receipts and loop.

###### Step 6c — Same as Role case (steps 6b-1 and 6b-2)

---

##### Case: `All`

> Same pattern. The SPA creates receipts for every active person.
> ⚠️ For large audiences (500+), consider adding a Concurrency Control
> setting on the Apply to each loop (set Degree of Parallelism to 20)
> to avoid throttling.

###### Step 6d — Same as Role case (steps 6b-1 and 6b-2)

---

##### Default (no match)

No action — log to run history and exit.

---

#### Flow Settings & Notes

| Setting | Recommendation |
|---|---|
| **Concurrency** | Turn on concurrency for Apply to each; set to **20** |
| **Timeout** | Default (30 days) is fine; individual actions timeout at 2 min |
| **Retry policy** | Use default retry for SharePoint connector (4 retries) |
| **Run after** | For Send email: configure "Run after" → "has succeeded" only |
| **Error handling** | Add a parallel branch after Send email with "Run after → has failed" that updates the receipt's DeliveryChannel to `InApp` (email failed, in-app only) |
| **Turn off** | Disable flow when doing bulk imports to avoid email storms |

#### Testing Checklist

- [ ] Create a test notification with AudienceType = `Individual`, SensitivityLevel = `Public` → verify email received with body
- [ ] Create a test notification with SensitivityLevel = `Sensitive` → verify email has generic body only
- [ ] Create a notification with AudienceType = `Role`, RecipientRole = `Admin` → verify all admins receive email
- [ ] Verify `DeliveryChannel` is updated to `Both` and `EmailSentDate` is stamped on each receipt
- [ ] Create a notification for a person with no Email field → verify no error, receipt stays `InApp`

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
