# CCSD All-Things Administrative SPA — TODO

Master task list for pending features, improvements, and technical debt.
Updated: 2026-04-18

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
the production Database site using `database-audit-webpart.html` (pasted into a
Modern Script Editor Web Part). **All 76 lists and libraries have been created with
all required columns, types, and choice values. The schema is fully deployed.**

Four audit-script mismatches were investigated and resolved as follows — all were
false positives on the script side, not problems in SharePoint:

| List | Finding | Resolution |
|------|---------|------------|
| `CCSD_TrainingCatalog` | Script expected `SF182` but actual display name is `SF182 Required` (internal name `_x053_F182`) | Audit script updated to expect `SF182 Required`. App code already queries correctly by internal name. |
| `CCSD_AppRoles` | `Role` column was flagged as type mismatch (Choice vs MultiChoice) | SharePoint list is correctly MultiChoice (a person can hold multiple roles). Audit script updated. App code already handles multi-value via `normalizeRoleValues()`. |
| `CCSD_PersonnelDataCall_Staging` | `Step` column flagged as type mismatch (Number vs Choice) | Staging list intentionally uses Choice with values 1–12 to constrain input. Audit script updated. App never performs arithmetic on Step. |
| `CCSD_OvertimeAuthorization` | `Type` column missing choices | Column was renamed to `OvertimeType` because `Type` is a SharePoint reserved word. Audit script updated. No app code depends on this (future module). |

**Next time the audit runs, these lists should all report as ✅ green.** Use
`database-audit-webpart.html` any time a new list or column is added to re-verify.

---

## 1. Calendar Module Enhancements

### Conference Room Scheduling (P1) — 🤝

> **Prerequisite: You must create 2 SharePoint lists before code can be built.**

- [x] **Create `CCSD_ConferenceRooms` list** — 👤 ✅ Created 2026-04-18
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

- [x] **Create `CCSD_RoomReservations` list** — 👤 ✅ Created 2026-04-18
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

- [x] **Build room availability grid** — 💻 ✅ Done 2026-04-18. `renderRoomSchedulingView()` added as "Rooms" tab in Calendar module. Time grid (7AM–6PM, 30-min slots) with color-coded availability per room. Date picker, capacity/equipment filters.
- [x] **Book / cancel reservation modals** — 💻 ✅ Done 2026-04-18. `openBookRoomModal()` with room/date/time selectors, subject/notes. `saveRoomBooking()` creates reservation. `cancelRoomReservation()` sets status to Cancelled.
- [ ] **Recurring meeting support** — 💻
- [x] **Conflict detection (double-booking prevention)** — 💻 ✅ Done 2026-04-18. `getRoomConflicts()` checks overlapping reservations. Booking is blocked with visible warning if conflict exists.
- [x] **Room search by capacity and equipment** — 💻 ✅ Done 2026-04-18. Filter controls for min capacity and equipment (Projector/VTC/Phone/Whiteboard) on the Rooms view.
- [x] **Room calendar view (per-room day/week timeline)** — 💻 ✅ Done 2026-04-18. Single-day grid view integrated into Calendar module as the "Rooms" tab. Shows all rooms with 30-min time slots. Upcoming reservations table below grid.
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

- [x] **Add `LastAuditDate` column to `CCSD_HardwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Go to **Site Contents** > open `CCSD_HardwareAssets` list
  2. **Add column** > **Date and Time** > name it `LastAuditDate`
  3. Set "Include Time" to **No** (date only)

- [x] **Add `LastAuditBy` column to `CCSD_HardwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Same list > **Add column** > **Person or Group** > name it `LastAuditBy`

- [x] **Build inventory audit mode** — 💻 ✅ Done 2026-04-18. `openInventoryAuditMode()` creates step-by-step walkthrough of all assets. `renderAuditStep()` shows per-asset modal with Verified/Missing/Damaged/Skip buttons and progress bar. `finalizeAudit()` shows summary with counts and issues table.

- [x] **Build audit history log** — 💻 ✅ Done 2026-04-18. `saveAuditResults()` updates LastAuditDate/LastAuditBy on verified assets and logs audit metadata via `logAudit()`.

- [ ] **Barcode / asset tag scanning** — 👤 + 💻
  - **Your decision needed**: This requires camera access via the browser. SharePoint Online pages *can* use `getUserMedia()` but your network security policy may block it. Test by visiting any website that requests camera access from a work machine.
  - If camera works: Claude can build a barcode scanner using a JS library (QuaggaJS or ZXing)
  - If camera is blocked: Skip this — manual asset tag entry is the fallback

### Software Governance (P2) — 🤝

- [x] **Add `TotalLicenses` column to `CCSD_SoftwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Open `CCSD_SoftwareAssets` list
  2. **Add column** > **Number** > name it `TotalLicenses`
  3. This tells the system how many licenses you own per title

- [x] **License utilization dashboard** — 💻 ✅ Done 2026-04-18. `renderLicenseUtilizationCard()` added to Assets view. Sorts titles by utilization %, shows used/total, color-coded bar (green/orange/red), Over Limit / Near Cap / Healthy / Underutilized status.
- [ ] **Software request workflow** — 💻
- [x] **ATO expiration alerts on Home** — 💻 ✅ Done 2026-04-18. `getNotifications()` now surfaces software titles with ATO expired (danger) or expiring within 90 days (warn). `ensureAssetsLoaded()` added to `renderHome()` data load. Honors `RequiresATO` flag.
- [x] **Approved software catalog view** — 💻 ✅ Done 2026-04-18. `renderApprovedSoftwareCatalog()` shows approved/standard software titles in a searchable modal table with vendor, version, license type, network, ATO requirement, and requestable status. "SW Catalog" button added to Assets toolbar.
- [ ] **Version compliance check** — 💻 (no prereqs)

- [x] **Add `CostCenter` column to `CCSD_HardwareAssets` and `CCSD_SoftwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Open each list > **Add column** > **Single line of text** > name it `CostCenter`

- [ ] **Cost center reporting** — 💻 (after columns exist)

### Hardware Tracking (P2) — 🤝

- [x] **Add `WarrantyExpiration` column to `CCSD_HardwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Open `CCSD_HardwareAssets` > **Add column** > **Date and Time** > name it `WarrantyExpiration`
  2. Set "Include Time" to **No**

- [x] **Warranty tracking & alerts** — 💻 ✅ Done 2026-04-18. `renderWarrantyTrackingView()` shows all hardware assets with warranty dates in a modal. KPI strip (Expired / Expiring ≤90 days / Active) with color-coded status badges per asset. "Warranties" button added to Assets toolbar.

- [x] **Add `PhysicalLocation` column to `CCSD_HardwareAssets`** — 👤 ✅ Created 2026-04-18
  1. Open `CCSD_HardwareAssets` > **Add column** > **Single line of text** > name it `PhysicalLocation`
  2. Values like "Bldg 500 / Rm 201" or "Mobile"

- [ ] **Location tracking** — 💻 (after column exists)

- [x] **Add `ExpectedReturnDate` column to `CCSD_HardwareAssignments`** — 👤 ✅ Created 2026-04-18
  1. Open `CCSD_HardwareAssignments` > **Add column** > **Date and Time** > name it `ExpectedReturnDate`

- [x] **Check-out / check-in for portable devices** — 💻 ✅ Done 2026-04-18. `openCheckOutModal()` / `confirmCheckOut()` for portable device check-out with expected return date. `openCheckInModal()` / `confirmCheckIn()` for check-in with condition notes.

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

- [x] **Announcements / news banner** — 🤝 ✅ Done 2026-04-18. `ensureAnnouncementsLoaded()` queries `CCSD_Announcements`. `getActiveAnnouncements()` filters by date range, audience (All/Admin/Supervisors), and IsActive flag. Priority-sorted (Critical/Important/Normal) with color-coded icons. Renders on Home between welcome banner and KPIs.

- [x] **Quick links section** — 💻 ✅ Done 2026-04-18. Quick link buttons (New Request, Calendar, Training, My Assets, Facilities, Supervisor Hub) rendered on Home dashboard. Supervisor Hub link gated by `canSeeSupervisorHub()`.

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

### Notification Framework (P1) — 🤝

> **Reusable notification infrastructure for the entire SPA. This is cross-cutting platform capability — not specific to any single module. Security, Training, Requests, Supervisor Hub, and future modules all route notifications through this framework. Designed to coexist with the existing computed-notification pattern (`getNotifications()` at line 1834) while adding persistent, auditable, audience-targeted notifications.**

#### Design Principles

1. **Two notification channels coexist:**
   - **Computed notifications** — The existing pattern. `getNotifications()` checks training expirations and request due dates on every page load. Zero storage. These continue unchanged.
   - **Persistent notifications** — New. Stored in `CCSD_Notifications` + `CCSD_NotificationReceipts`. Created by app logic, security workflows, admin broadcasts, scheduled checks. Auditable, read-trackable, archivable.

2. **Audience-first design** — Every notification targets an audience type (Individual, Organization, Role, All). The framework resolves the audience to specific recipients at send-time and creates receipt records for each.

3. **Privacy-tiered content** — Notifications carry a `SensitivityLevel` (`Public`, `Internal`, `Sensitive`). Sensitive notifications (security incidents, SOR correspondence) have restricted content in the notification body and require the recipient to navigate to the source module for details.

4. **Module-agnostic** — Any module can create notifications by calling `sendNotification(options)`. The framework handles audience resolution, receipt creation, privacy enforcement, and audit logging.

5. **No email in Phase 1** — In-app panel only. Email delivery via Power Automate is a future enhancement (Section 14) triggered by list item creation.

#### Data Model — 3-List Architecture

##### List 1: `CCSD_Notifications` (Notification Records) — REVISED

> **One row per notification sent. This is the "master record" of what was communicated. Replaces the original 11-column schema with a more complete design.**

| Column Name | Type | Required | Notes |
|-------------|------|----------|-------|
| Title | Single line (default) | Yes | Notification subject line |
| NotificationType | Choice | Yes | `Security`, `SF86 Reminder`, `Incident Update`, `Training Reminder`, `Request Update`, `Supervisor Alert`, `System`, `Broadcast`, `General` |
| SourceModule | Choice | Yes | `Security`, `Training`, `Requests`, `Calendar`, `Assets`, `Facilities`, `SupervisorHub`, `System`, `Admin` |
| Body | Multiple lines of text | Yes | Notification body text. For `Sensitive` notifications, this contains only the redacted/generic version. |
| SensitivityLevel | Choice | Yes | `Public` (visible to all recipients), `Internal` (visible to recipients, not logged in full), `Sensitive` (vague body only — recipient must navigate to source for details) |
| AudienceType | Choice | Yes | `Individual`, `Organization`, `Role`, `All` |
| RecipientPersonID | Lookup → CCSD_Personnel | Conditional | Required if AudienceType = `Individual` |
| RecipientOrgID | Lookup → CCSD_Organizations | Conditional | Required if AudienceType = `Organization` |
| RecipientRole | Single line of text | Conditional | Required if AudienceType = `Role`. Value matches `CCSD_AppRoles` role name (e.g., `Security`, `HR`, `Supervisor`) |
| SentBy | Lookup → CCSD_Personnel | Yes | Who sent / triggered the notification |
| SentDate | Date and Time | Yes | When the notification was created |
| ExpiresDate | Date and Time | No | Optional. After this date, notification is no longer shown in the panel (but remains in the list for audit). Useful for time-bound announcements. |
| RelatedEntityType | Choice | No | `SecurityIncident`, `SecurityRecord`, `TrainingRecord`, `Request`, `Asset`, `Announcement`, `Other` |
| RelatedEntityID | Number | No | SharePoint item ID of the related entity (nullable) |
| RelatedCaseNumber | Single line of text | No | If linked to a security incident — case number for cross-reference |
| ActionURL | Single line of text | No | Hash route to navigate to on click (e.g., `#security`, `#training`). If null, notification is informational only. |
| IsSystemGenerated | Yes/No | Yes | `true` if auto-generated by app logic (threshold checks, status transitions). `false` if manually authored by a user. |
| TemplateID | Single line of text | No | If generated from a template, the template code (e.g., `NT-01`, `SF86-REMIND-90`). Null for free-text. |
| Notes | Multiple lines of text | No | Internal notes (not shown to recipient). Audit context. |

**Total: 19 columns** (up from 11 in the original schema).

##### List 2: `CCSD_NotificationReceipts` (Per-Recipient Read Tracking) — NEW

> **One row per recipient per notification. Solves the broadcast/org read-tracking problem identified in the original schema note. For Individual-audience notifications, exactly 1 receipt. For Organization/Role/All, one receipt per resolved recipient.**

| Column Name | Type | Required | Notes |
|-------------|------|----------|-------|
| Title | Single line (default) | Auto | Auto: "NR-{NotificationID}-{PersonID}" |
| NotificationID | Lookup → CCSD_Notifications | Yes | Which notification this receipt is for |
| RecipientPersonID | Lookup → CCSD_Personnel | Yes | The specific person who received this notification |
| IsRead | Yes/No | Yes | Default: No. Set to Yes when recipient marks as read. |
| ReadDate | Date and Time | No | When the recipient marked it as read |
| IsDismissed | Yes/No | Yes | Default: No. Whether the recipient dismissed it from their panel. Security notifications are NOT dismissable (enforced by app logic, not schema). |
| DismissedDate | Date and Time | No | When dismissed |
| DeliveryChannel | Choice | Yes | `InApp`, `Email`, `Both` — tracks how this notification was delivered to this recipient |
| EmailSentDate | Date and Time | No | If delivered via email, when the email was sent (set by Power Automate) |

**Total: 9 columns.**

**Volume estimate:** For an organization of ~200 people, a weekly all-hands broadcast creates ~200 receipt rows. At 1 broadcast/week + ~50 individual notifications/week, expect ~450 rows/week ≈ 23,000/year. Well within SharePoint's 5,000-item threshold for indexed queries. Add indexed columns on `RecipientPersonID` and `IsRead` for performance.

##### List 3: `CCSD_IncidentNotifications` (Case Communication Log) — UNCHANGED

> **Already designed in Section 11 (D1, Entity 4). 14 columns. This list is specific to security incident case files and is SEPARATE from the general notification framework. When an incident notification is sent, it writes to BOTH `CCSD_IncidentNotifications` (case file record) AND `CCSD_Notifications` + `CCSD_NotificationReceipts` (user-facing delivery). The `MirroredToGeneralNotifications` flag on `CCSD_IncidentNotifications` tracks this dual-write.**

No schema changes needed — the existing 14-column design in D1 Entity 4 is correct.

#### Audience Resolution Logic

When `sendNotification(options)` is called, the framework resolves the audience to specific recipients:

```
sendNotification({
  title, body, notificationType, sourceModule,
  sensitivityLevel, audienceType,
  recipientPersonId,   // if Individual
  recipientOrgId,      // if Organization
  recipientRole,       // if Role
  relatedEntityType, relatedEntityID, relatedCaseNumber,
  actionURL, templateId, expiresDate, notes
})
```

**Resolution rules:**

| AudienceType | Resolution | Receipt Count |
|-------------|------------|---------------|
| `Individual` | Direct lookup — single person | 1 |
| `Organization` | Query `CCSD_Personnel` where `OrgID eq {recipientOrgId}` and `IsDeleted ne true` | N (org size) |
| `Role` | Query `CCSD_AppRoles` where `RoleName eq {recipientRole}`, get all `PersonID` values | N (role members) |
| `All` | Query `CCSD_Personnel` where `IsDeleted ne true` | N (all active personnel) |

**Implementation detail:** Audience resolution happens client-side at send-time. The app:
1. Creates 1 row in `CCSD_Notifications` (the master record)
2. Resolves the audience to a list of PersonIDs
3. Batch-creates receipt rows in `CCSD_NotificationReceipts` (SharePoint batch API: `$batch` endpoint, up to 100 operations per batch)
4. Calls `logAudit('NotificationSent', 'Notification', null, {notificationId, recipientCount, audienceType})`

**Cap:** If resolved audience exceeds 500 recipients, warn the sender and require confirmation. This prevents accidental mass notifications and keeps batch operations manageable.

#### Scheduling & Recurrence

The framework supports three notification generation patterns:

##### Pattern 1: On-Demand (User-Initiated)
- A user with appropriate permissions clicks "Send Notification" in a module
- Opens a notification composer modal
- User selects audience, writes content (or picks a template), sends
- **Used by:** Security ad-hoc notifications, admin broadcasts, supervisor alerts

##### Pattern 2: Event-Driven (Status Transitions)
- App logic creates notifications automatically when certain actions occur
- Examples: incident status change → notify subject; training approved → notify person; request assigned → notify assignee
- **Used by:** Security incident lifecycle (D2 side effects), request workflow, training approvals
- `IsSystemGenerated = true`, `TemplateID` set to the template code

##### Pattern 3: Threshold-Computed (On Page Load)
- Checked on each session start (page load or route change)
- App logic queries for conditions and generates persistent notifications if they don't already exist
- **Deduplication:** Before creating, check if a notification with the same `TemplateID + RelatedEntityID + RecipientPersonID` already exists and is unresolved. If so, skip.
- Examples:
  - SF-86/PR due in 90/60/30 days → `SF86-REMIND-90`, `SF86-REMIND-60`, `SF86-REMIND-30`
  - Training expiring in 30 days → `TRAIN-EXPIRE-30`
  - Clearance eligibility expiring → `CLR-EXPIRE-60`
- **Runs in:** `initNotificationChecks()` called from `loadAppData()` after data is loaded
- **Frequency control:** Checks run at most once per session. A session-level flag (`APP.state.notificationChecksRun`) prevents redundant checks on route changes.

##### Recurrence for Pattern 3 — Deduplication Strategy

Recurring notifications (e.g., "SF-86 due in 90 days" generated monthly) use `TemplateID + RelatedEntityID` as a composite dedup key:

- `SF86-REMIND-90` + PersonID 42 → only one active notification at a time
- When the 60-day threshold hits, a NEW notification (`SF86-REMIND-60` + PersonID 42) is created
- The 90-day notification remains (already read or not) — it does not update
- If the underlying condition is resolved (SF-86 submitted), remaining unread reminders can be soft-expired by setting `ExpiresDate` to now

**No Power Automate needed for scheduling in Phase 1.** All threshold checks run client-side on page load. This is sufficient because the SPA is used daily by admin staff. For future email reminders, Power Automate can run on a schedule and create `CCSD_Notifications` items that the app then renders.

#### Delivery Methods

##### Method 1: In-App Notification Panel (Phase 1)

The existing notification panel on the Home dashboard (`renderNotificationCenter()` at line 1853) is the primary delivery channel. It currently renders computed notifications only. The framework extends it:

- [ ] **Extend `getNotifications()` to merge computed + persistent notifications** — 💻
  - Query `CCSD_NotificationReceipts` where `RecipientPersonID eq {currentPersonId}` and `IsRead eq false` and `IsDismissed eq false`
  - Expand `NotificationID` to get Title, Body, NotificationType, SensitivityLevel, ActionURL, SentDate, ExpiresDate
  - Filter out expired notifications (ExpiresDate < now)
  - Merge with existing computed items (training, requests)
  - Sort all by date descending
  - Cap at 50 items in the panel

- [ ] **Visual differentiation by source module** — 💻
  - Security notifications: 🔒 icon prefix
  - Training notifications: 📋 icon prefix (or existing style)
  - System/broadcast: 📢 icon prefix
  - Computed (existing): retain current styling (no icon change)

- [ ] **Mark as Read** — 💻
  - Click notification → set `IsRead = true`, `ReadDate = now()` on the receipt row
  - Security notifications: mark-as-read only (NOT dismissable)
  - Other notifications: mark-as-read AND dismissable (sets `IsDismissed = true`)
  - If `ActionURL` is set, navigate to that route after marking as read

- [ ] **Notification badge count** — 💻
  - Red badge on the notification bell icon showing unread count
  - Count = computed unread (existing) + persistent unread (from receipts query)
  - Badge refreshes on page load and after any mark-as-read action

##### Method 2: Email via Power Automate (Future — Section 14)

- Power Automate flow triggers on `CCSD_Notifications` item creation
- Flow checks `SensitivityLevel`:
  - `Public` or `Internal`: email body = notification body
  - `Sensitive`: email body = "You have a notification in the CCSD Admin system. Please log in to view." (NO content in email)
- Flow resolves recipients from `CCSD_NotificationReceipts` and sends via O365 connector
- Flow updates `EmailSentDate` on each receipt row
- **Not implemented in Phase 1.** Documented here for future Power Automate setup.

##### Method 3: Teams Webhook (Future — Section 14)

- POST to Incoming Webhook URL for channel-level notifications (announcements, system alerts)
- Only `Public` sensitivity notifications are eligible for Teams delivery
- **Not implemented in Phase 1.**

#### Permissions Model

| Action | Any User | Module Role | Admin / App Admin |
|--------|----------|-------------|-------------------|
| View own notifications | ✅ | ✅ | ✅ |
| Mark own notifications as read | ✅ | ✅ | ✅ |
| Dismiss own notifications | ✅ (non-security only) | ✅ (non-security only) | ✅ |
| Send notification to individual | ❌ | ✅ (within module scope) | ✅ |
| Send notification to organization | ❌ | ❌ | ✅ |
| Send notification to role | ❌ | ❌ | ✅ |
| Send broadcast (All) | ❌ | ❌ | ✅ (App Admin only) |
| View notification audit log | ❌ | ✅ (own module) | ✅ (all) |
| View all receipts for a notification | ❌ | ✅ (notifications they sent) | ✅ |

**Module-scoped send permissions:**
- `Security` role → can send `Security`, `SF86 Reminder`, `Incident Update` types
- `Training` role → can send `Training Reminder` types
- `HR` role → can send `General` types to individuals
- `Supervisor` role → can send `Supervisor Alert` types to their direct reports only (filtered by `OrgID`)

**Implementation:** `canSendNotification(notificationType, audienceType)` function checks `hasRole()` against the permission matrix above.

#### Sensitive Content Handling

##### Sensitivity Levels

| Level | Body Content | In-App Display | Email (Future) | Audit Log |
|-------|-------------|----------------|-----------------|-----------|
| `Public` | Full content, no restrictions | Full body shown | Full body in email | Full body logged |
| `Internal` | Full content, organization-internal | Full body shown | Full body in email | Title + type logged (body omitted) |
| `Sensitive` | **Redacted/vague only.** Generic instruction to contact the relevant office. | Vague body shown + "Click to view details" link to source module | "You have a notification. Please log in." | Title + type logged (body omitted) |

##### Sensitive Content Rules (Mandatory)

These rules are **hardcoded in app logic** — not configurable:

1. **All security incident notifications to the subject** are `Sensitive`. The body contains ONLY: case number + generic instruction. Example: *"Please contact the security office regarding case SEC-2026-0042."*
2. **SOR-related notifications** are `Sensitive`. No SOR content, allegations, or guideline references appear in any notification.
3. **SF-86 reminders** are `Internal`. They reference the person's clearance type and due date but no investigation details.
4. **Training reminders** are `Public`. No sensitive content.
5. **Broadcast/system announcements** are `Public`.
6. **Supervisor alerts** about subordinate security matters are `Sensitive`. Supervisor sees only: *"An action may affect a member of your organization. Contact the security office."*

##### PII Detection Guard

- [ ] **`containsPII(text)` utility function** — 💻
  - Scans notification body text for patterns: SSN (`\d{3}-\d{2}-\d{4}`), DoD ID (`\d{10}`), and specific allegation keywords (configurable list)
  - If PII is detected in a `Sensitive` notification body, **block the send** and warn the author
  - If PII is detected in a `Public` or `Internal` notification, **warn but allow** (author must confirm)
  - This is a safety net — templates should prevent PII inclusion by design

#### Notification Templates

Predefined templates ensure consistent, privacy-compliant messaging. Templates are hardcoded in `APP.config.notificationTemplates`:

| Template ID | Type | Sensitivity | Subject | Body Pattern |
|-------------|------|-------------|---------|-------------|
| `NT-01` | Incident Update | Sensitive | Case Update | "Please contact the security office regarding case {caseNumber}." |
| `NT-02` | Incident Update | Sensitive | Access Status Change | "Your access status has changed. Contact the security office." |
| `NT-03` | Incident Update | Sensitive | SOR Correspondence | "You have received correspondence from the adjudicative authority regarding case {caseNumber}. Contact the security office if you have questions." |
| `NT-04` | Incident Update | Sensitive | Case Resolution | "Case {caseNumber} has been resolved. Contact the security office for details." |
| `NT-05` | Incident Update | Sensitive | Case Closed | "Case {caseNumber} has been closed." |
| `NT-06` | Incident Update | Sensitive | Debriefing Required | "You are required to complete a security debriefing. Contact the security office to schedule." |
| `NT-07` | Incident Update | Sensitive | Daily Check-In | "Please contact the security office at your earliest convenience regarding an ongoing matter." |
| `SF86-REMIND-90` | SF86 Reminder | Internal | SF-86 Due in 90 Days | "Your {clearanceType} periodic reinvestigation is due in approximately 90 days. Contact the security office to begin the SF-86 process." |
| `SF86-REMIND-60` | SF86 Reminder | Internal | SF-86 Due in 60 Days | "Your {clearanceType} periodic reinvestigation is due in approximately 60 days. Please initiate your SF-86 if you have not already done so." |
| `SF86-REMIND-30` | SF86 Reminder | Internal | SF-86 Due in 30 Days | "Your {clearanceType} periodic reinvestigation is due in approximately 30 days. This is urgent — contact the security office immediately if your SF-86 has not been submitted." |
| `TRAIN-EXPIRE-30` | Training Reminder | Public | Training Expiring Soon | "{trainingName} expires in {daysRemaining} days. Please complete the training before {expirationDate}." |
| `TRAIN-EXPIRED` | Training Reminder | Public | Training Expired | "{trainingName} has expired as of {expirationDate}. Complete this training immediately." |
| `REQ-ASSIGNED` | Request Update | Public | Request Assigned | "You have been assigned request {requestId}: {requestTitle}. Due date: {dueDate}." |
| `REQ-OVERDUE` | Request Update | Public | Request Overdue | "Request {requestId} is overdue. Original due date: {dueDate}." |
| `SUP-TEAM-ALERT` | Supervisor Alert | Internal | Team Compliance Alert | "{count} member(s) in your organization have overdue training or expiring clearances. Review the Supervisor Hub for details." |
| `SYS-BROADCAST` | Broadcast | Public | (user-defined) | (user-defined) |

**Template rendering:** `renderTemplate(templateId, variables)` substitutes `{variableName}` placeholders with provided values. Templates with `Sensitive` level cannot have their body overridden — only the placeholder values are substituted.

#### Audit & Logging

All notification operations are logged via the existing `logAudit()` function:

| Event | Action Type | Entity Type | Metadata |
|-------|------------|-------------|----------|
| Notification created | `NotificationCreated` | `Notification` | `{notificationId, type, audienceType, recipientCount, sensitivityLevel, templateId}` |
| Notification read | `NotificationRead` | `NotificationReceipt` | `{receiptId, notificationId, personId}` |
| Notification dismissed | `NotificationDismissed` | `NotificationReceipt` | `{receiptId, notificationId, personId}` |
| Notification send blocked (PII) | `NotificationBlocked` | `Notification` | `{reason: 'PII detected', templateId, audienceType}` |
| Bulk notification sent | `BulkNotificationSent` | `Notification` | `{notificationId, audienceType, resolvedCount, batchCount}` |

**Retention:** Notification records and receipts are retained indefinitely (soft-delete via `IsDeleted` if cleanup is ever needed). Security-related notifications follow the 3-year minimum retention from the Security Module (Section 11).

#### Integration with Existing Code

##### Extending `getNotifications()` (line 1834)

Current function returns computed items only. The extended version:

```
function getNotifications() {
  var items = [];

  // --- Existing computed notifications (unchanged) ---
  var training = [];
  try { training = getMyTrainingModel(); } catch (e) {}
  // ... existing training + request logic ...

  // --- NEW: Persistent notifications from CCSD_NotificationReceipts ---
  var receipts = APP.state.data.myNotificationReceipts || [];
  receipts.forEach(function(r) {
    var n = r.NotificationID;  // expanded lookup
    if (!n) return;
    if (n.ExpiresDate && new Date(n.ExpiresDate) < new Date()) return;
    items.push({
      type: mapSensitivityToType(n.SensitivityLevel, n.NotificationType),
      icon: mapModuleIcon(n.SourceModule),
      title: n.Title,
      detail: n.Body,
      time: formatDate(n.SentDate),
      route: n.ActionURL || 'home',
      persistent: true,
      receiptId: r.Id,
      notificationId: n.Id,
      isDismissable: n.NotificationType !== 'Incident Update' && n.SourceModule !== 'Security'
    });
  });

  // Sort by date descending, cap at 50
  items.sort(function(a, b) { /* date comparison */ });
  return items.slice(0, 50);
}
```

##### New Data Loading

Add to `loadAppData()` (or the security-module init):
- Query `CCSD_NotificationReceipts` where `RecipientPersonID eq {currentPersonId}` and `IsRead eq false` and `IsDismissed eq false`, expanding `NotificationID`
- Store in `APP.state.data.myNotificationReceipts`

##### New Functions to Implement

| Function | Purpose |
|----------|---------|
| `sendNotification(options)` | Core send function. Creates notification record, resolves audience, creates receipts, logs audit. |
| `markNotificationRead(receiptId)` | Sets IsRead + ReadDate on a receipt. Calls logAudit(). |
| `dismissNotification(receiptId)` | Sets IsDismissed + DismissedDate. Blocked for security notifications. |
| `renderTemplate(templateId, vars)` | Substitutes template placeholders. |
| `containsPII(text)` | Scans for SSN, DoD ID, allegation keywords. Returns boolean. |
| `canSendNotification(type, audience)` | Permission check based on current user's roles. |
| `initNotificationChecks()` | Runs threshold checks (SF-86, training, clearance) and creates persistent notifications if dedup check passes. |
| `openNotificationComposer(defaults)` | Opens modal for manual notification authoring. Pre-fills from defaults if provided. |
| `resolveAudience(audienceType, targetId)` | Returns array of PersonIDs for the given audience. |
| `batchCreateReceipts(notificationId, personIds)` | Creates receipt rows in batches of 100 via SharePoint $batch API. |

#### Implementation Tasks (NF-01 through NF-16)

> **Ordered by dependency. NF = Notification Framework. These are separate from the IM (Incident Management) tasks in Section 11, though NF tasks are prerequisites for several IM tasks.**

##### Phase A: Lists & Infrastructure (Prerequisites — 👤)

- [x] **NF-01: Create `CCSD_Notifications` list** — 👤 ✅ Created 2026-04-18. 19 columns per schema above. Add indexed columns on: `NotificationType`, `SourceModule`, `SentDate`.
- [x] **NF-02: Create `CCSD_NotificationReceipts` list** — 👤 ✅ Created 2026-04-18. 9 columns per schema above. Add indexed columns on: `RecipientPersonID`, `IsRead`, `NotificationID`.
- [x] **NF-03: Add notification-related role entries to `CCSD_AppRoles`** — 👤 ✅ Done 2026-04-18. Ensure `Security`, `Training`, `HR`, `Supervisor` roles exist (most should already exist from other modules). No new roles needed — the framework uses existing roles.

##### Phase B: Core Framework (💻 — Build in Order)

- [x] **NF-04: Implement `sendNotification(options)`** — 💻 ✅ Done 2026-04-18. Core function builds notification record, resolves audience, batches receipts, logs audit. SensitivityLevel + containsPII check enforce. 500-recipient cap requires `confirmedLargeAudience`.
- [x] **NF-05: Implement `resolveAudience(audienceType, targetId)`** — 💻 ✅ Done 2026-04-18. Resolves Individual/Organization/Role/All to PersonID array using `APP.state.data.people` and `APP.state.rolesRaw`.
- [x] **NF-06: Implement `batchCreateReceipts(notificationId, personIds)`** — 💻 ✅ Done 2026-04-18. Parallel POSTs with concurrency=5 (simpler than $batch API; can be upgraded later). Returns successful receipts.
- [x] **NF-07: Implement `renderTemplate(templateId, vars)`** — 💻 ✅ Done 2026-04-18. 16-template registry (`NOTIFICATION_TEMPLATES`). Sensitive templates retain body — only placeholder substitution allowed.
- [x] **NF-08: Implement `containsPII(text)`** — 💻 ✅ Done 2026-04-18. Regex SSN + 10-digit DoD ID + keyword list (`NOTIFICATION_PII_KEYWORDS`). Returns `{hasPII, matches}`.
- [x] **NF-09: Implement `canSendNotification(type, audience)`** — 💻 ✅ Done 2026-04-18. Permission matrix check using `hasRole()`.

##### Phase C: UI Integration (💻 — Build in Order)

- [x] **NF-10: Extend `getNotifications()` for persistent notifications** — 💻 ✅ Done 2026-04-18. Queries `CCSD_NotificationReceipts` via new `ensureMyNotificationReceiptsLoaded()`, expands `NotificationID`, filters expired, merges with computed items, sorts by date desc, caps at 50. Wired into `renderHome()` data loading.
- [x] **NF-11: Update `renderNotificationCenter()` for persistent notifications** — 💻 ✅ Done 2026-04-18. Module icons via `mapNotificationModuleIcon()`. Mark-as-read + dismiss buttons (security non-dismissable). `markNotificationRead()` and `dismissNotification()` wired into `handleClick`.
- [x] **NF-12: Build notification composer modal** — 💻 ✅ Done 2026-04-18. `openNotificationComposer(defaults)` with template dropdown (filtered by user permissions), audience type selector, person/org/role pickers, live PII warning, sensitivity auto-set from template, accepts pre-fill defaults from any module. `Send Notification` button on Security Admin view.
- [x] **NF-13: Implement `initNotificationChecks()`** — 💻 ✅ Done 2026-04-18. Runs once per session (`APP.state.notificationChecksRun`). Generates training expiration (`TRAIN-EXPIRE-30`) and expired (`TRAIN-EXPIRED`) notifications using current user's training model. Dedup by `TemplateID + RelatedEntityID`. Wired into `renderHome()` data load. SF-86 + clearance threshold checks deferred until SecurityRecords data loader is wired.

##### Phase D: Module Integration (💻 — After Phases B+C)

- [~] **NF-14: Integrate with Security incident lifecycle** — 💻 Partially done 2026-04-18. Status transitions (IM-15) optionally send templated notifications to subject (NT-01/03/04/05). Dual-write to `CCSD_IncidentNotifications` deferred until incident detail Communications tab is built.
- [x] **NF-15: Integrate with Supervisor Hub** — 💻 ✅ Done 2026-04-18. `initNotificationChecks()` now computes overdue team count via `computeOverdueTeamCount(supervisorPersonId)` and sends `SUP-TEAM-ALERT` once per week (auto-expires after 7 days, dedup by `RelatedEntityID = supervisor PersonID`).
- [~] **NF-16: Integrate with Training module** — 💻 Partially done 2026-04-18. Training expiration notifications (`TRAIN-EXPIRE-30`, `TRAIN-EXPIRED`) now generated by `initNotificationChecks()`. Training approval/rejection notifications via `sendNotification()` on status change still pending.

#### Implementation Roadmap

| Phase | Tasks | Dependencies | Estimate |
|-------|-------|-------------|----------|
| **A: Lists** | NF-01, NF-02, NF-03 | None (👤 prerequisite) | List creation |
| **B: Core** | NF-04 through NF-09 | Phase A complete | Core framework functions |
| **C: UI** | NF-10 through NF-13 | Phase B complete | Notification panel + composer |
| **D: Integration** | NF-14 through NF-16 | Phase C complete + Security Phase 2 (IM tasks) for NF-14 | Module wiring |

**Relationship to Security Module phases:**
- Security Phase 1 (Personnel Core) can proceed WITHOUT the notification framework — it uses no notifications.
- Security Phase 2 (Incident Management) DEPENDS on NF-01 through NF-12 being complete (specifically NF-04, NF-07, NF-10, NF-12).
- The recommended build order is: Security Phase 1 → Notification Framework (NF-01 through NF-13) → Security Phase 2.

**Relationship to existing IM tasks:**
- `IM-06` (Create `CCSD_Notifications` list) is superseded by `NF-01` (expanded to 19 columns).
- `IM-16` (Build notification composer) is superseded by `NF-12` (generalized, reusable).
- `IM-17` (Extend `getNotifications()`) is superseded by `NF-10` (generalized).
- `IM-27` (Power Automate email) remains unchanged — it's the Phase D+ email delivery enhancement.

---

## 10. Reporting (P3) — 💻

> **No prerequisites from you. All code-only.**

- [ ] Scheduled report email — 🤝 (requires Power Automate, see Section 6 notes)

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

- [x] **New "Security" nav tab** — Added to `APP.nav` and main navigation. Visible to all authenticated users, content scoped by role. ✅ Done 2026-04-14.
- [x] **Hash route `#security`** — Route added with role-based view switching (Security admin vs member self-service). ✅ Done 2026-04-14.
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
- [ ] **Status history tracking** — Each transition stored in the `CCSD_IncidentStatusHistory` list (one row per transition, per D1 Entity 2). Rendered as a visual timeline in the incident detail view.
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

> **Security-specific notification behavior is implemented through the reusable Notification Framework (Section 9). The framework provides `sendNotification()`, templates (NT-01 through NT-07, SF86-REMIND-*), audience resolution, privacy enforcement, and in-app delivery. Security-specific requirements below define HOW the framework is used by this module — not a separate implementation.**

- [ ] **Ad-hoc security notifications** — Security role users send notifications via `openNotificationComposer()` (NF-12) with `SourceModule = 'Security'`. Audience options:
  - **Individual:** Select person from roster (`AudienceType = 'Individual'`)
  - **Organization:** Select org (`AudienceType = 'Organization'`)
  - **All:** Broadcast (`AudienceType = 'All'`, requires Security or App Admin role per NF permission matrix)
- [ ] **Incident-linked notifications** — Sent via templates NT-01 through NT-07 (defined in Section 9). All incident notifications set `SensitivityLevel = 'Sensitive'` and `RelatedCaseNumber`. Body references ONLY case number, not details.
- [ ] **Security notification templates** — Hardcoded in `APP.config.notificationTemplates` (see Section 9 template table):
  - `NT-01` through `NT-07`: Incident lifecycle templates
  - `SF86-REMIND-90/60/30`: SF-86 due date reminders
  - `TRAIN-EXPIRE-30`, `TRAIN-EXPIRED`: Security training expiration
- [ ] **Delivery:** In-app notification panel via framework (NF-10, NF-11). Security notifications rendered with 🔒 icon, non-dismissable. Mark-as-read only.
- [ ] **Notification log** — All security notifications logged to `CCSD_Notifications` + `CCSD_NotificationReceipts` (framework lists). Incident-linked notifications additionally logged to `CCSD_IncidentNotifications` (dual-write per NF-14).
- [ ] **◇ Email notification (future):** Power Automate flow triggers on `CCSD_Notifications` creation where `NotificationType = 'Security'`. For `Sensitive` notifications, email body is generic ("You have a notification. Please log in."). See Section 14.

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

### PHASE 2 DETAIL: Incident Management System — Implementation Design

> **This section provides implementation-grade specifications for the incident management capability described in 11e–11j above. It covers the data model, state machine, permissions, notifications, audit logging, case number strategy, and responsibility split. Use this as the build spec.**

#### D1. Data Model — 6 Entities

> **All entities are SharePoint lists. The SPA reads/writes via `_api/web/lists/getbytitle('ListName')/items`. Existing patterns: `updateListItem()` for writes, `logAudit()` for audit trail, `attachFileToListItem()` for file attachments, `softDeleteItem()` for archival.**

##### Entity 1: `CCSD_SecurityIncidents` (Primary Case Record)

> **One row per incident. This is the master record that drives the case lifecycle.**

| Column | Type | Required | Notes |
|--------|------|----------|-------|
| Title | Single line | Auto | Auto-set to CaseNumber on create |
| CaseNumber | Single line | Yes | `SEC-YYYY-NNNN` — generated by app (see D6) |
| PersonID | Lookup → CCSD_Personnel | Yes | Subject of the incident |
| ReportedByPersonID | Lookup → CCSD_Personnel | Yes | Who filed the report (may be same as subject for self-reports) |
| ReporterRole | Choice | Yes | `Self`, `Supervisor`, `Security Manager`, `Commander`, `Other` |
| IncidentCategory | Choice | Yes | 18 SEAD 3-aligned values (see 11e) |
| IncidentSubType | Single line | No | Free text sub-type (e.g., "Bankruptcy Ch7") |
| SEAD4Guidelines | Single line | No | Auto-populated from category; editable. Comma-delimited letters: "F,E" |
| IncidentDate | Date | Yes | When the event occurred |
| DiscoveredDate | Date | No | When the event was discovered (may differ from IncidentDate) |
| ReportedDate | Date | Yes | When the report was filed in this system |
| ReportingDeadline | Date | No | Calculated from category + SEAD 3 timelines |
| TimelinessFlag | Choice | Auto | `On Time`, `Late`, `Significantly Late` — computed: ReportedDate vs ReportingDeadline |
| Status | Choice | Yes | See state machine (D2) — 16 values |
| PriorStatus | Single line | Auto | Set by app on each transition (enables undo) |
| Severity | Choice | Yes | `Infraction`, `Violation`, `Compromise` (for info sec); `Low`, `Medium`, `High`, `Critical` (for personnel) |
| ReportingSource | Choice | Yes | `Self-Report`, `Supervisor`, `Commander`, `CV Alert`, `AFOSI`, `External Agency`, `Anonymous`, `SF-702 Discrepancy` |
| AssignedTo | Lookup → CCSD_Personnel | No | Security staff member managing this case |
| Description | Multi-line | Yes | Detailed narrative — **Security role only** |
| InvestigationNotes | Multi-line | No | Running notes — **Security role only** |
| DamageAssessment | Multi-line | No | For spillage/unauthorized disclosure — **Security role only** |
| ContainmentActions | Multi-line | No | Immediate actions taken (system isolation, material secured, etc.) |
| CommanderNotifiedDate | Date | No | When the commander was informed |
| CommanderAction | Choice | No | `None`, `Access Suspended`, `Duty Reassignment`, `Commander's Inquiry Directed`, `Other` |
| DISSReportedDate | Date | No | When reported to DISS |
| DISSIncidentNumber | Single line | No | DISS-assigned reference number |
| ExternalReferralAgency | Single line | No | "AFOSI", "DCSA", "DOJ", "FBI", etc. |
| ExternalReferralDate | Date | No | When referred |
| SORIssuedDate | Date | No | When Statement of Reasons was issued |
| SORGuidelines | Single line | No | SEAD 4 guidelines cited: "F,E" |
| SORResponseDeadline | Date | No | Auto: SORIssuedDate + 30 days |
| SORExtensionGranted | Yes/No | No | Default: No |
| SORExtendedDeadline | Date | No | If extension granted |
| SORResponseDate | Date | No | When subject's response was received |
| SORResult | Choice | No | `Pending`, `Sustained`, `Modified`, `Reversed` |
| AppealFiledDate | Date | No | Within 30 days of final determination |
| AppealBody | Single line | No | "PSAB" or agency equivalent |
| PersonalAppearance | Yes/No | No | Whether subject requested personal appearance |
| AppealOutcome | Choice | No | `Pending`, `Upheld`, `Overturned`, `Modified` |
| AppealClosedDate | Date | No | |
| ResolutionDate | Date | No | Date case reached final disposition |
| Outcome | Choice | No | `No Action`, `Letter of Caution`, `Security Education`, `Clearance Retained with Conditions`, `Corrective Action`, `Access Suspended`, `Eligibility Suspended`, `Eligibility Revoked`, `Eligibility Denied`, `Referred to External`, `Administrative Withdrawal` |
| Conditions | Multi-line | No | If outcome includes conditions |
| DebriefingDate | Date | No | SF-312 debriefing date if clearance revoked |
| OrgID | Lookup → CCSD_Organizations | Yes | Subject's org at time of incident |
| IsArchived | Yes/No | Auto | Default: No. Set by `softDeleteItem()` |
| ArchivedDate | Date | No | |
| Notes | Multi-line | No | General notes |

**Total: 46 columns** (expanded from 28 in the high-level plan to include operational fields needed for full lifecycle tracking).

##### Entity 2: `CCSD_IncidentStatusHistory` (Status Transition Log) — NEW

> **One row per status transition. Replaces the `StatusHistoryJSON` column approach. A separate list is more queryable, reportable, and doesn't hit the 255-char limit for Choice columns or JSON size limits in multi-line text fields.**

| Column | Type | Required | Notes |
|--------|------|----------|-------|
| Title | Single line | Auto | Auto: `SEC-2026-0042 → Under Investigation` |
| IncidentID | Lookup → CCSD_SecurityIncidents | Yes | Parent case |
| CaseNumber | Single line | Yes | Denormalized for query performance |
| FromStatus | Choice | Yes | Previous status (same 16 values as Status) |
| ToStatus | Choice | Yes | New status |
| TransitionDate | Date and Time | Yes | When the transition occurred |
| ChangedBy | Lookup → CCSD_Personnel | Yes | Who made the change |
| Notes | Multi-line | No | Transition notes (e.g., "Referred to AFOSI per commander direction") |
| DaysInPriorStatus | Number | Auto | Computed: TransitionDate minus previous transition date |
| DeadlineWasMet | Yes/No | Auto | Was the stage completed within expected duration? |

**Design rationale:** The original plan used a `StatusHistoryJSON` column. That works for small cases but breaks down because: (1) JSON in a multi-line text field can't be queried server-side with `$filter`, (2) it can silently truncate at the SharePoint column limit, (3) it can't be included in SharePoint views or reports. A separate list is the more robust pattern. The `StatusHistoryJSON` column is retained on the parent record as a **cache** for fast rendering of the timeline UI, but the source of truth is this list.

##### Entity 3: `CCSD_IncidentActions` (Tasks/Follow-ups per Case) — NEW

> **One row per action item. Tracks tasks that must be completed as part of case management. Some are auto-generated by status transitions; others are manually created by the security manager.**

| Column | Type | Required | Notes |
|--------|------|----------|-------|
| Title | Single line | Yes | Action description: "Conduct preliminary inquiry", "Notify commander" |
| IncidentID | Lookup → CCSD_SecurityIncidents | Yes | Parent case |
| CaseNumber | Single line | Yes | Denormalized for display |
| ActionType | Choice | Yes | `Required`, `Recommended`, `Optional` |
| ActionCategory | Choice | Yes | `Notification`, `Investigation`, `Documentation`, `Containment`, `DISS Update`, `Commander Action`, `Subject Communication`, `External Referral`, `Training`, `Follow-Up`, `Other` |
| AssignedTo | Lookup → CCSD_Personnel | No | Who is responsible |
| DueDate | Date | No | When it should be completed |
| Priority | Choice | Yes | `Immediate`, `Urgent`, `Normal`, `Low` |
| Status | Choice | Yes | `Pending`, `In Progress`, `Completed`, `Cancelled`, `Blocked` |
| CompletedDate | Date | No | |
| CompletedBy | Lookup → CCSD_Personnel | No | |
| CompletionNotes | Multi-line | No | |
| IsAutoGenerated | Yes/No | Auto | True if created by a status transition rule |
| TriggeringStatus | Single line | No | Which status transition created this action |

**Auto-generated actions by status transition:**

| When Status Changes To → | Auto-Create These Actions |
|--------------------------|--------------------------|
| `Reported` | "Review report for completeness", "Determine reporting timeliness" |
| `Preliminary Inquiry` | "Conduct preliminary inquiry", "Determine if DISS reporting required", "Determine if commander notification required" |
| `Reported to DISS` | "Submit incident report in DISS", "Record DISS incident number" |
| `Interim Action Taken` | "Notify subject of access suspension", "Collect badges/access media", "Update system access", "Notify commander in writing" |
| `Under Investigation` | "Monitor investigation progress", "Provide requested documents to investigator" |
| `SOR Issued` | "Verify subject received SOR", "Track 30-day response deadline", "Notify commander of SOR" |
| `Closed — *` (any terminal) | "Update DISS with disposition", "Update member's security record", "File case documentation", "Conduct debriefing if revoked" |

##### Entity 4: `CCSD_IncidentNotifications` (Case Communication Log) — NEW

> **One row per notification sent in relation to a specific incident. This is SEPARATE from the general `CCSD_Notifications` list — this tracks the complete communication history for a specific case, which is part of the case file.**

| Column | Type | Required | Notes |
|--------|------|----------|-------|
| Title | Single line | Auto | Auto: notification subject line |
| IncidentID | Lookup → CCSD_SecurityIncidents | Yes | Parent case |
| CaseNumber | Single line | Yes | Denormalized |
| SentBy | Lookup → CCSD_Personnel | Yes | Security rep who sent it |
| RecipientPersonID | Lookup → CCSD_Personnel | Yes | Who received it |
| RecipientRole | Choice | Yes | `Subject`, `Supervisor`, `Commander`, `Security Manager`, `External` |
| NotificationType | Choice | Yes | `Initial Notification`, `Status Update`, `Action Required`, `Reminder`, `SOR Delivery`, `Appeal Notice`, `Resolution Notice`, `Debriefing Notice`, `General` |
| BodyText | Multi-line | Yes | Full text of the notification |
| ContainsCaseNumber | Yes/No | Auto | True if BodyText contains a case number reference |
| ContainsPII | Yes/No | Auto | True if notification includes name, SSN, or specific allegations (should be flagged — see privacy rules) |
| SentDate | Date and Time | Yes | |
| DeliveryMethod | Choice | Yes | `In-App`, `In-App + Email`, `Verbal (Logged)`, `Written (External)` |
| AcknowledgedDate | Date and Time | No | When recipient acknowledged receipt |
| MirroredToGeneralNotifications | Yes/No | Auto | Whether a copy was written to `CCSD_Notifications` for the in-app panel |

**Privacy enforcement rule:** Notifications to the **subject** (the person the incident is about) must NEVER include: the incident category, description, allegations, investigation details, or names of other involved parties. They may ONLY include: the case number, the current status, and a generic instruction to contact the security office. The app must enforce this by template — free-text notifications to subjects require Security role review.

##### Entity 5: `CCSD_IncidentParties` (People Involved in a Case) — NEW

> **One row per person involved in an incident (beyond the subject). Tracks witnesses, reporting officials, investigators, legal counsel, and other participants.**

| Column | Type | Required | Notes |
|--------|------|----------|-------|
| Title | Single line | Auto | Auto: person name + role |
| IncidentID | Lookup → CCSD_SecurityIncidents | Yes | Parent case |
| CaseNumber | Single line | Yes | Denormalized |
| PersonID | Lookup → CCSD_Personnel | No | If internal — linked to personnel record |
| ExternalName | Single line | No | If external (AFOSI agent, attorney, etc.) |
| ExternalOrg | Single line | No | |
| PartyRole | Choice | Yes | `Witness`, `Reporting Official`, `Investigating Officer`, `Commander`, `First Sergeant`, `Legal Counsel`, `Subject Representative`, `AFOSI Agent`, `DCSA Investigator`, `Adjudicator`, `Other` |
| InvolvedDate | Date | No | When they became involved |
| Notes | Multi-line | No | |

##### Entity 6: Evidence/Attachments

> **No separate list needed.** SharePoint list item attachments (via `attachFileToListItem()` at Index.html line 1515) handle this natively. Each `CCSD_SecurityIncidents` item can have multiple attachments. The app tracks attachment metadata in the UI by querying the AttachmentFiles endpoint.

**Attachment categories** (tracked in filename convention, e.g., `[CATEGORY]_filename.pdf`):
- `[RPT]` — Initial report / memorandum
- `[INQ]` — Preliminary inquiry report
- `[CMD]` — Commander's memo / endorsement
- `[INV]` — Investigation report
- `[DMG]` — Damage assessment
- `[SOR]` — Statement of Reasons
- `[RSP]` — Subject's response to SOR
- `[APL]` — Appeal documentation
- `[DIS]` — Final disposition letter
- `[DBR]` — Debriefing acknowledgment
- `[COR]` — Correspondence with external agencies
- `[EVD]` — Evidence / supporting documents
- `[OTH]` — Other

**File size limit:** 10MB per file (matches existing training submission pattern). Accepted types: PDF, DOC/DOCX, JPG, PNG, XLS/XLSX.

#### D2. Incident Workflow / State Machine

> **This defines every valid status, every valid transition, who can perform each transition, and what side effects each transition triggers. The app enforces these rules — invalid transitions are blocked in the UI.**

##### Complete Status Enum (16 values)

| # | Status | Type | Description |
|---|--------|------|-------------|
| 1 | `Reported` | Active | Initial intake. All cases start here. |
| 2 | `Preliminary Inquiry` | Active | USM reviewing report for substance and completeness |
| 3 | `Reported to DISS` | Active | Incident submitted to DISS/DCSA |
| 4 | `Interim Action Taken` | Active | Commander has suspended access or taken other interim action |
| 5 | `Under Investigation` | Active | Formal investigation underway (DCSA, AFOSI, or commander's inquiry) |
| 6 | `Investigation Complete` | Active | Investigation finished, awaiting adjudication |
| 7 | `Adjudication` | Active | Under review by adjudicative authority (CAF/AFCAF) |
| 8 | `SOR Issued` | Active | Statement of Reasons sent to subject |
| 9 | `Response/Appeal` | Active | Subject has responded; appeal may be in progress |
| 10 | `Resolved` | Active | Determination made but case not yet administratively closed |
| 11 | `Closed — No Action Required` | Terminal | Report reviewed, no security concern. Case filed. |
| 12 | `Closed — Favorable` | Terminal | Investigation/adjudication favorable. Clearance retained. |
| 13 | `Closed — Adverse Action` | Terminal | Clearance revoked, denied, or suspended with conditions. |
| 14 | `Referred to AFOSI` | Terminal | Referred to AF Office of Special Investigations |
| 15 | `Referred to External Agency` | Terminal | Referred to DCSA, DOJ, FBI, or other |
| 16 | `Administrative Withdrawal` | Terminal | Subject separated/departed; case moot |

##### Valid Transitions (Directed Graph)

```
FROM                          → VALID TRANSITIONS TO
─────────────────────────────────────────────────────────────────────
Reported                      → Preliminary Inquiry
                              → Closed — No Action Required (fast-close for duplicates/errors)

Preliminary Inquiry           → Reported to DISS
                              → Interim Action Taken
                              → Under Investigation (skip DISS for unit-level-only incidents)
                              → Closed — No Action Required
                              → Referred to AFOSI
                              → Referred to External Agency

Reported to DISS              → Interim Action Taken
                              → Under Investigation
                              → Adjudication (skip investigation if adjudicable on its face)
                              → Referred to AFOSI
                              → Referred to External Agency

Interim Action Taken          → Under Investigation
                              → Adjudication
                              → Referred to AFOSI
                              → Referred to External Agency

Under Investigation           → Investigation Complete
                              → Referred to AFOSI (mid-investigation referral)
                              → Referred to External Agency

Investigation Complete        → Adjudication
                              → Closed — Favorable (if investigation found no issue)
                              → Referred to External Agency

Adjudication                  → SOR Issued
                              → Closed — Favorable
                              → Closed — Adverse Action (direct adverse without SOR — rare)
                              → Resolved (clearance retained with conditions)

SOR Issued                    → Response/Appeal
                              → Closed — Adverse Action (subject did not respond within deadline)

Response/Appeal               → Resolved
                              → Closed — Favorable (SOR reversed on appeal)
                              → Closed — Adverse Action (appeal denied)

Resolved                      → Closed — Favorable
                              → Closed — Adverse Action

ANY active status             → Administrative Withdrawal (subject departed)
```

##### Transition Rules (enforced in app logic)

| Rule | Implementation |
|------|---------------|
| **Only forward movement** | Cannot revert to a prior status (except via `Administrative Withdrawal`). If a case needs to go "back," the security manager adds a note and the status stays; they do NOT rewind the state machine. |
| **SOR deadline enforcement** | When status = `SOR Issued` and `SORResponseDeadline` passes without `SORResponseDate` being set, the app displays a red alert and suggests `Closed — Adverse Action` as the next transition. It does NOT auto-transition. |
| **Interim Action is optional** | Not every case passes through `Interim Action Taken`. Only when the commander explicitly suspends access. |
| **DISS reporting is tracked, not enforced** | The app tracks `DISSReportedDate` but does not block transitions if DISS hasn't been updated. DISS updates happen outside the app. |
| **Terminal states are permanent** | Once a case reaches a terminal status (11-16), no further transitions are allowed. The case can only be archived. |
| **Reopen pattern** | If a closed case needs to be reopened (e.g., new information), create a NEW incident record linked to the original via a `RelatedCaseNumber` field reference in Notes. Do not reopen the original. |

##### Side Effects Per Transition

| Transition | Auto-Created Actions | Notifications Sent | Audit Entry |
|-----------|---------------------|-------------------|-------------|
| → `Reported` | "Review for completeness", "Assess timeliness" | None (case just created) | `Incident Created` |
| → `Preliminary Inquiry` | "Conduct inquiry", "Determine DISS requirement" | None | `Status Changed` |
| → `Reported to DISS` | "Submit to DISS", "Record DISS number" | None | `Status Changed` |
| → `Interim Action Taken` | "Notify subject", "Collect access media", "Update systems" | To subject: "Your access status has changed. Contact the security office." | `Status Changed` + `Notification Sent` |
| → `Under Investigation` | "Monitor progress" | None (subject may not be told investigation is open) | `Status Changed` |
| → `Investigation Complete` | "Review findings" | None | `Status Changed` |
| → `Adjudication` | "Monitor adjudication" | None | `Status Changed` |
| → `SOR Issued` | "Verify SOR received", "Track 30-day deadline" | To subject: "You have received correspondence from the adjudicative authority regarding case [CASE_NUMBER]. Contact the security office if you have questions." | `Status Changed` + `Notification Sent` |
| → `Response/Appeal` | "Review response", "Forward to adjudicator" | None | `Status Changed` |
| → `Resolved` | "Update security record", "File documentation" | To subject: "Case [CASE_NUMBER] has been resolved. Contact the security office for details." | `Status Changed` + `Notification Sent` |
| → `Closed — *` | "Update DISS", "Update security record", "Archive" | To subject: "Case [CASE_NUMBER] has been closed." | `Status Changed` + `Notification Sent` + `Incident Closed` |
| → `Administrative Withdrawal` | "Update DISS", "File" | None | `Status Changed` + `Incident Closed` |

#### D3. Permissions Model

> **Incident data is the most sensitive data in the entire SPA. Permissions are enforced at two levels: SharePoint REST query filters (server-side) and UI visibility rules (client-side). Both must agree.**

##### Query-Level Enforcement (Mandatory)

| Role | SharePoint REST Query Pattern | What They See |
|------|------------------------------|---------------|
| **Member (no Security role)** | `$filter=PersonID eq [myPersonnelId]` on `CCSD_SecurityIncidents` | Only their own incidents |
| **Member — incident fields** | App strips: Description, InvestigationNotes, DamageAssessment, Severity, IncidentCategory, ReportingSource, all SOR fields, Conditions, all party/action data | Only: CaseNumber, Status, ReportedDate, ResolutionDate, Outcome (generalized) |
| **Supervisor** | No access to `CCSD_SecurityIncidents` at all | Cannot see any incident data for anyone (not even direct reports) |
| **Security Manager** | `$filter=OrgID eq [scopeOrgId]` (if ScopeOrgID set on role) OR unfiltered (if no scope) | Full access to all fields for incidents in their org scope |
| **App Admin** | No filter | Full access to all incidents, all fields |

**Why supervisors see nothing:** Incident details are need-to-know per DoDM 5200.02. The supervisor's role is to report concerns and receive notification of access changes. They do NOT need to see case details, categories, or investigation status.

##### UI-Level Enforcement (Defense in Depth)

| UI Element | Member | Security Mgr | App Admin |
|-----------|--------|-------------|-----------|
| Incident list/table | Own cases only (case # + status) | Full table with all columns | Same as Security |
| Incident detail modal | Blocked — shows only summary card | Full detail with all tabs | Same as Security |
| Create incident button | Hidden | Visible | Visible |
| Edit incident fields | Hidden | All fields editable | Same as Security |
| Status transition buttons | Hidden | Visible (valid transitions only) | Same as Security |
| Action items tab | Hidden | Visible | Visible |
| Communication log tab | Own notifications only | Full log | Full log |
| Parties tab | Hidden | Visible | Visible |
| Attachments tab | Hidden | Visible (upload + view) | Same as Security |
| Export incidents | Hidden | Visible (CSV with CUI banner) | Same as Security |

##### New Gate Functions

```javascript
function canManageSecurity() {
    return hasAnyRole(['Security', 'App Admin']);
}
function canViewOwnSecurity() {
    return APP.state.currentPersonnel && APP.state.currentPersonnel.Id;
}
```

#### D4. Notification Model

> **Two notification channels: (1) case-specific communications logged in `CCSD_IncidentNotifications` (the case file record), and (2) in-app notifications via the reusable Notification Framework (Section 9). Every case notification writes to BOTH. The general framework (`CCSD_Notifications` + `CCSD_NotificationReceipts`) handles audience resolution, read tracking, and in-app delivery. The incident-specific list (`CCSD_IncidentNotifications`) provides the compliance/case-file record. See NF-14 for the integration task.**

##### Notification Flow

```
Security Manager authors notification
        │
        ▼
┌──────────────────────────┐
│ CCSD_IncidentNotifications│  ← Case file record (audit/compliance)
│ (Entity 4 from D1)        │     Full text, recipient, case link,
│                           │     delivery method, acknowledgment
└──────────┬───────────────┘
           │ App also writes to:
           ▼
┌──────────────────┐
│ CCSD_Notifications│  ← User-facing delivery
│ (general list)    │     Renders in Home dashboard panel
│                   │     Stripped of sensitive detail
└──────────────────┘
```

##### Privacy Rules for Subject-Facing Notifications

| Allowed | NOT Allowed |
|---------|-------------|
| Case number (e.g., "SEC-2026-0042") | Incident category |
| Current status (generalized: "updated", "resolved", "closed") | Description or allegations |
| Generic instruction: "Contact the security office" | Names of other parties |
| Date references | Investigation details, severity, SEAD 4 references |
| | SOR content or outcome details |

##### Notification Templates (Mandatory — Hardcoded)

| ID | Trigger | Template | Recipient |
|----|---------|----------|-----------|
| `NT-01` | Status → `Interim Action Taken` | "Your access status has changed. Please contact the security office at your earliest convenience." | Subject |
| `NT-02` | Status → `SOR Issued` | "You have received official correspondence regarding case {CASE_NUMBER}. Please contact the security office for details and to discuss your response options." | Subject |
| `NT-03` | Status → `Resolved` | "Case {CASE_NUMBER} has been resolved. Please contact the security office for details regarding the outcome." | Subject |
| `NT-04` | Status → any `Closed — *` | "Case {CASE_NUMBER} has been closed." | Subject |
| `NT-05` | Manual — daily check-in | "Regarding case {CASE_NUMBER}: Please contact the security office. This is a routine follow-up." | Subject |
| `NT-06` | Manual — action required | "Action required regarding case {CASE_NUMBER}. Please contact the security office by {DATE}." | Subject |
| `NT-07` | Manual — free text | Security manager writes custom text (500 char limit). **Validation:** warn if text contains category keywords, person names, or guideline references. | Subject |

##### Daily Notification Workflow

- [ ] **"Send Notification" button** on incident detail modal → opens notification composer
- [ ] **Template selector** — dropdown of NT-01 through NT-07
- [ ] **Recipient selector** — defaults to subject; can add supervisor/commander
- [ ] **Free-text area** (for NT-07) — with PII detection warning
- [ ] **Send** → writes to `CCSD_IncidentNotifications` AND `CCSD_Notifications`. Calls `logAudit()`.
- [ ] **Batch daily reminders** — "Send Daily Reminders" on list view: select multiple cases, pick template, send to each subject. Each gets its own case-specific log entry.

##### Integration with Existing Notification Panel

> **Superseded by Section 9 Notification Framework (NF-10, NF-11).** The framework extends `getNotifications()` to merge computed + persistent notifications, handles module-specific icons (🔒 for security), and enforces non-dismissable behavior for security notifications. No separate implementation needed here — see NF-10 and NF-11.

#### D5. Audit / Logging Model

> **Uses existing `logAudit(actionType, entityType, beforeObj, afterObj, meta)` at Index.html line 1620. Every incident action writes an audit entry.**

##### Audit Events

| Event | ActionType | EntityType | Meta |
|-------|-----------|------------|------|
| Incident created | `Create` | `SecurityIncident` | `{caseNumber, category, subject}` |
| Status changed | `StatusChange` | `SecurityIncident` | `{caseNumber, fromStatus, toStatus, notes}` |
| Field edited | `Update` | `SecurityIncident` | `{caseNumber, changedFields}` |
| Detail viewed | `View` | `SecurityIncident` | `{caseNumber, viewedBy}` |
| Attachment uploaded | `AttachmentAdded` | `SecurityIncident` | `{caseNumber, fileName}` |
| Attachment downloaded | `AttachmentViewed` | `SecurityIncident` | `{caseNumber, fileName}` |
| Notification sent | `NotificationSent` | `SecurityIncident` | `{caseNumber, template, recipientRole}` |
| Action item created | `Create` | `IncidentAction` | `{caseNumber, actionTitle}` |
| Action item completed | `Update` | `IncidentAction` | `{caseNumber, actionTitle}` |
| Incidents exported | `Export` | `SecurityIncident` | `{rowCount, filters}` |
| Incident archived | `Archive` | `SecurityIncident` | `{caseNumber}` |
| SOR issued | `SORIssued` | `SecurityIncident` | `{caseNumber, guidelines, responseDeadline}` |
| Own incident revealed | `RevealField` | `SecurityIncident` | `{caseNumber, fieldGroup}` |

**Retention:** 7 years minimum. Audit entries for incidents are NEVER deletable, even by App Admin.

#### D6. Case Number Generation Strategy

##### Recommended Approach: SharePoint ID-Based (No Race Conditions)

```javascript
// After creating the CCSD_SecurityIncidents item (which auto-assigns an ID):
function formatCaseNumber(sharePointItemId, incidentCategory) {
    var year = new Date().getFullYear();
    var prefix = [9, 10, 16, 17].indexOf(getCategoryIndex(incidentCategory)) >= 0
        ? 'ISV' : 'SEC';
    var seq = String(sharePointItemId).padStart(4, '0');
    return prefix + '-' + year + '-' + seq;
}
// Two-step create:
// 1. Create item with placeholder Title
// 2. Read back the auto-assigned ID
// 3. Update Title and CaseNumber with formatted value
```

**Why this approach:** SharePoint auto-increment IDs are guaranteed unique with no race conditions. The trade-off (possible gaps in sequence) is acceptable. Alternative query-based sequential numbering risks duplicates under concurrent access.

**Prefix logic:**
- `SEC-` for personnel security incidents (SEAD 3 categories 1-8, 11-15, 18)
- `ISV-` for information security incidents (categories 9, 10, 16, 17)
- Both are privacy-safe: reveal nothing about the subject, org, or incident nature

#### D7. Responsibility Split

| Responsibility | Owner | Notes |
|---------------|-------|-------|
| Incident record CRUD | App → SharePoint | Standard REST API pattern |
| State machine enforcement | App Logic | Valid transitions checked before update |
| Case number generation | App Logic | Two-step create + update pattern |
| Role-based query filtering | App Logic | `$filter` constructed from `APP.state.roleNames` |
| Auto-generated action items | App Logic | Created on status transition |
| Notification authoring + privacy validation | App Logic (via NF-04, NF-07, NF-08) | Template rendering, PII detection — see Section 9 Notification Framework |
| Dual-write (case log + notification panel) | App Logic (via NF-14) | Writes to `CCSD_IncidentNotifications` + `CCSD_Notifications`/`CCSD_NotificationReceipts` |
| Audit logging | App Logic → `logAudit()` | Existing function, no changes needed |
| SOR deadline calculation | App Logic | `SORIssuedDate + 30 days` |
| Overdue/deadline alerting | App Logic (on page load) | Check open cases for exceeded durations |
| Email notifications | Power Automate (future) | Trigger on `CCSD_Notifications` creation |
| DISS updates | Manual (outside app) | App tracks date and reference number only |
| Investigation/adjudication | External systems | App tracks status and outcome only |
| Archival | App Logic → `softDeleteItem()` | Sets `IsArchived = true`, no hard deletes |

#### D8. Implementation Task List (Build Order)

> **These are the specific coding tasks to implement incident management. They are ordered by dependency — each task depends on the ones above it. This replaces the high-level TODO items in 11e-11j with implementation-grade tasks.**

##### Mandatory (Core MVP)

- [x] **IM-01: Create `CCSD_SecurityIncidents` list** — 👤 ✅ Created 2026-04-18. 46 columns per D1 Entity 1.
- [x] **IM-02: Create `CCSD_IncidentStatusHistory` list** — 👤 ✅ Created 2026-04-18. 10 columns per D1 Entity 2.
- [x] **IM-03: Create `CCSD_IncidentActions` list** — 👤 ✅ Created 2026-04-18. 14 columns per D1 Entity 3.
- [x] **IM-04: Create `CCSD_IncidentNotifications` list** — 👤 ✅ Created 2026-04-18. 14 columns per D1 Entity 4.
- [x] **IM-05: Create `CCSD_IncidentParties` list** — 👤 ✅ Created 2026-04-18. 9 columns per D1 Entity 5.
- [x] **IM-06: Create `CCSD_Notifications` list** — 👤 ✅ Created 2026-04-18. **Superseded by NF-01** (19 columns, see Section 9 Notification Framework).
- [x] **IM-07: Add `Security` role to `CCSD_AppRoles`** — 👤 ✅ Done 2026-04-18. Data entry, not schema change.
- [x] **IM-08: Add gate functions** — 💻 `canManageSecurity()`, `canViewOwnSecurity()` added alongside existing gates. ✅ Done 2026-04-14.
- [x] **IM-09: Add `#security` route** — 💻 Hash route added to router, nav tab added to `APP.nav`, placeholder render function built, `Alt+S` keyboard shortcut registered. ✅ Done 2026-04-14.
- [ ] **IM-10: Build incident list view (Security role)** — 💻 Sortable/filterable table using existing table pattern. Columns: CaseNumber, Subject Name, Category, Status, Severity, AssignedTo, ReportedDate, Days Open. Color-coded status badges.
- [ ] **IM-11: Build incident list view (Member role)** — 💻 Simplified table: CaseNumber, Status, ReportedDate, ResolutionDate. Obscured by default with reveal toggle.
- [x] **IM-12: Build case number generation** — 💻 ✅ Done 2026-04-18. `generateCaseNumber(prefix, year)` queries `CCSD_SecurityIncidents`, finds max sequence for `PREFIX-YYYY-` pattern, returns next padded 4-digit ID.
- [x] **IM-13: Build "Create Incident" modal** — 💻 ✅ Done 2026-04-18. `openCreateIncidentModal()` with all 18 SEAD 3 categories, auto-fill of SEAD 4 guidelines on category change, mental health carve-out warning for Category 8. `saveIncident()` generates `SEC-`/`ISV-` case number, creates incident, initial status history entry, and 3 auto-generated `Reported`-status action items. `Create Incident` button on Security Admin view.
- [~] **IM-14: Build incident detail modal** — 💻 Partially done 2026-04-18. Single-view detail modal with summary KV grid, status timeline (from CCSD_IncidentStatusHistory), action items table (from CCSD_IncidentActions), Send Notification button (NF-12 with case context), and status transition controls (IM-15). Tabbed layout (Communications, Parties, Attachments, SOR tabs) deferred. Tabbed layout:
  - **Summary tab:** All case fields, editable by Security role. Status badge with transition buttons (valid next states only per D2 graph).
  - **Timeline tab:** Status history from `CCSD_IncidentStatusHistory`, rendered as vertical timeline with dates, actors, notes. Days-in-status shown.
  - **Actions tab:** Task list from `CCSD_IncidentActions`. Create/complete/cancel actions. Overdue items highlighted red.
  - **Communications tab:** Notification log from `CCSD_IncidentNotifications`. "Send Notification" button opens composer.
  - **Parties tab:** People involved from `CCSD_IncidentParties`. Add internal (person lookup) or external (name + org).
  - **Attachments tab:** File list via SharePoint AttachmentFiles API. Upload button using `attachFileToListItem()`. Filename convention with category prefix.
  - **SOR tab:** (visible only when status >= `SOR Issued`) SOR fields, response tracking, appeal tracking per D1.
- [x] **IM-15: Build status transition logic** — 💻 ✅ Done 2026-04-18. `INCIDENT_NEXT_STATUS` map enforces D2-allowed transitions. `applyIncidentStatusTransition()` validates, prompts for notes, updates Status + PriorStatus, creates `CCSD_IncidentStatusHistory` row, optionally fires NF-14 notification to subject (NT-01/03/04/05). Auto-sets `ClosedDate`, `ResolutionDate`, `SORIssuedDate` + 30-day deadline. Auto-action-items per status deferred.
- [x] **IM-16: Build notification composer** — 💻 ✅ Done 2026-04-18 via NF-12. Security usage wired via `data-source="Security"` button. Incident-specific dual-write to `CCSD_IncidentNotifications` deferred until incident detail modal (IM-14) is built.
- [x] **IM-17: Extend `getNotifications()` for persistent notifications** — 💻 ✅ Done 2026-04-18 via NF-10 + NF-11. Module icons (🔒 Security, 📋 Training, etc.) and non-dismissable security notifications handled by `getNotifications()` and `renderNotificationCenter()`.
- [~] **IM-18: Build incident audit logging** — 💻 Partially done 2026-04-18. View events logged when detail modal opens. Create/Update events auto-logged by `createListItem`/`updateListItem` infrastructure. Status transitions logged via `updateListItem` with before-snapshot. Remaining: explicit logging for SOR issue/response/appeal events when those workflows are built.
- [x] **IM-19: Build query-level security enforcement** — 💻 ✅ Done 2026-04-18. `getSecurityIncidentFilter()` returns OData filter based on role. `canViewIncident()` for client-side checks. `redactIncidentForMember()` strips sensitive fields. `ensureSecurityIncidentsLoaded()` applies filter at query time.

##### Recommended Enhancements (Post-MVP)

- [ ] **IM-20: Batch daily reminders** — 💻 Multi-select cases on list view, pick template, send to each subject.
- [ ] **IM-21: SOR deadline tracking** — 💻 When status = `SOR Issued`, display countdown to `SORResponseDeadline`. Red alert when overdue. Suggest `Closed — Adverse Action` transition.
- [ ] **IM-22: Stage duration monitoring** — 💻 Configurable expected durations per status (e.g., `Preliminary Inquiry` = 10 business days). Yellow highlight at 75%, red at 100%.
- [ ] **IM-23: Incident dashboard widgets** — 💻 On the Security admin view:
  - Open cases by status (horizontal bar)
  - Cases opened/closed this month (trend)
  - Average days to close by category
  - Overdue action items count
  - Pending SOR responses
- [ ] **IM-24: Case-to-case linking** — 💻 "Related Cases" field on incident record. Useful when a new incident arises from a prior case.
- [x] **IM-25: Incident CSV export** — 💻 ✅ Done 2026-04-18. `exportIncidentCSV()` with CUI banner header + footer. Wired to `Export Incidents (CSV)` button on Security Admin view. Logged via `logAudit('Export', 'SecurityIncidents', ...)`.
- [ ] **IM-26: Bulk status update** — 💻 Select multiple `Administrative Withdrawal` cases when multiple people depart simultaneously.
- [ ] **IM-27: Power Automate email integration** — 👤 Create a flow: trigger on `CCSD_Notifications` item created where `NotificationType = 'Security'`. Send email via O365 connector.
- [ ] **IM-28: Incident print view** — 💻 Print-optimized layout showing case summary, timeline, actions, and communication log. For inclusion in physical case files.

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
- [x] **Requires:** `CCSD_SecurityContainers` list, `CCSD_ContainerChecks` list, `CCSD_AreaChecks` list — ✅ All created 2026-04-18

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
- [x] **Requires:** `CCSD_VisitorLog` list, `CCSD_RestrictedAreas` list, `CCSD_AreaAccessRoster` list — ✅ All created 2026-04-18

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
- [x] **Requires:** No new lists — uses `CCSD_SecurityIncidents` (Category 16) and new columns on existing lists — ✅ All lists exist 2026-04-18

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
- [x] **Requires:** `CCSD_ClassifiedDocuments` list, `CCSD_DestructionRecords` list — ✅ All created 2026-04-18

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
- [x] **Requires:** `CCSD_OPSECProgram` list (or repurpose `CCSD_Config` for program metadata) — ✅ Created 2026-04-18

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
- [x] **Requires:** `CCSD_DD254Registry` list, `CCSD_ContractorPersonnel` list — ✅ All created 2026-04-18

---

### SharePoint Lists — Data Model

> **Phase 1 requires 3 lists (SecurityRecords, SecurityIncidents, Notifications + NotificationReceipts). Phases 3-5 add up to 10 more lists. Create Phase 1 lists first. The Notifications and NotificationReceipts schemas are defined in Section 9 (Notification Framework) — see NF-01 and NF-02.**

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
| OrgID | Lookup → CCSD_Organizations | Member's org at time of incident |
| Notes | Multiple lines of text | |

> **Changes from original:** Added 10 new columns for SOR/appeal tracking, damage assessment, timeliness, conditions, and debriefing. Removed `StatusHistoryJSON` (replaced by separate `CCSD_IncidentStatusHistory` list per D1 Entity 2). Expanded Status choices from 10 to 16. Expanded Outcome choices. Added SEAD 4 guideline mapping fields. The full implementation-grade schema is in D1 Entity 1 (46 columns including additional fields not shown in this abbreviated view).

##### `CCSD_Notifications` — REVISED (19 columns — see Section 9 Notification Framework for full design)

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Notification subject line |
| NotificationType | Choice | `Security`, `SF86 Reminder`, `Incident Update`, `Training Reminder`, `Request Update`, `Supervisor Alert`, `System`, `Broadcast`, `General` |
| SourceModule | Choice | `Security`, `Training`, `Requests`, `Calendar`, `Assets`, `Facilities`, `SupervisorHub`, `System`, `Admin` |
| Body | Multiple lines of text | Notification body text (redacted for Sensitive level) |
| SensitivityLevel | Choice | `Public`, `Internal`, `Sensitive` |
| AudienceType | Choice | `Individual`, `Organization`, `Role`, `All` |
| RecipientPersonID | Lookup → CCSD_Personnel | If AudienceType = Individual |
| RecipientOrgID | Lookup → CCSD_Organizations | If AudienceType = Organization |
| RecipientRole | Single line of text | If AudienceType = Role (matches CCSD_AppRoles role name) |
| SentBy | Lookup → CCSD_Personnel | Who sent/triggered the notification |
| SentDate | Date and Time | |
| ExpiresDate | Date and Time | Optional — notification hidden after this date |
| RelatedEntityType | Choice | `SecurityIncident`, `SecurityRecord`, `TrainingRecord`, `Request`, `Asset`, `Announcement`, `Other` |
| RelatedEntityID | Number | SharePoint item ID of related entity |
| RelatedCaseNumber | Single line of text | If linked to a security incident |
| ActionURL | Single line of text | Hash route to navigate on click (e.g., `#security`) |
| IsSystemGenerated | Yes/No | True if auto-generated by app logic |
| TemplateID | Single line of text | Template code if generated from template (e.g., `NT-01`) |
| Notes | Multiple lines of text | Internal notes (not shown to recipient) |

> **Read tracking is handled by `CCSD_NotificationReceipts` (9 columns) — one row per recipient per notification. See Section 9 Notification Framework for the full receipts schema, audience resolution logic, and implementation tasks (NF-01 through NF-16).**

##### `CCSD_NotificationReceipts` — NEW (9 columns — see Section 9 Notification Framework)

| Column Name | Type | Notes |
|-------------|------|-------|
| Title | Single line (default) | Auto: "NR-{NotificationID}-{PersonID}" |
| NotificationID | Lookup → CCSD_Notifications | Which notification |
| RecipientPersonID | Lookup → CCSD_Personnel | Specific recipient |
| IsRead | Yes/No | Default: No |
| ReadDate | Date and Time | When marked as read |
| IsDismissed | Yes/No | Default: No (security notifications NOT dismissable) |
| DismissedDate | Date and Time | When dismissed |
| DeliveryChannel | Choice | `InApp`, `Email`, `Both` |
| EmailSentDate | Date and Time | Set by Power Automate if email sent |

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
| **Phase 2** | Incident & Case Management: 18 SEAD 3 categories, 10-stage lifecycle, SOR/appeal tracking, case numbers, notifications, audit logging, reporting | **P1 — Build Second** | Phase 1 complete, Notification Framework (NF-01 through NF-12), `CCSD_SecurityIncidents` list | Large (11e-11j) |
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
| **In-app notifications** | App Logic → SharePoint (via Notification Framework, Section 9) | `sendNotification()` → `CCSD_Notifications` + `CCSD_NotificationReceipts`, render via extended `getNotifications()` |
| **Email notifications (future)** | Power Automate | Triggered by SharePoint list item creation/modification |
| **Scheduled reminders** | App Logic via `initNotificationChecks()` (NF-13) | Threshold checks on page load, dedup by TemplateID + RelatedEntityID, creates persistent notifications |
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
| 🔬 Notification delivery method | **✅ Resolved.** Reusable Notification Framework designed in Section 9 (NF-01 through NF-16). In-app panel for Phase 1. Power Automate email as future enhancement (Section 14). 3-list architecture: `CCSD_Notifications` (19 cols), `CCSD_NotificationReceipts` (9 cols), `CCSD_IncidentNotifications` (14 cols). |
| 🔬 Continuous Vetting tracking | **✅ Resolved.** Dual-mode tracking defined in 11h: legacy PR countdown for non-CV-enrolled; "Enrolled in CV" display for CV-enrolled. Both models supported during TW 2.0 transition. |
| 🔬 SCI/SAP access tracking | **✅ Resolved.** Boolean fields (`SCIAccess`, `SAPAccess`) appropriate for unit level. Detailed SCI compartment tracking is SSO responsibility (Scattered Castles), not unit-level. |
| 🔬 Physical security features | **✅ Resolved.** Full feature set defined in Phase 3 (11k-11l). Recommended as separate phase requiring owner approval. Key constraint: no combinations in unclassified system. |
| 🔬 Information security features | **✅ Resolved.** Full feature set defined in Phase 4 (11m-11n). Document accountability uses unclassified metadata only. |
| 🔬 OPSEC integration | **✅ Resolved.** Program compliance tracking defined in Phase 5 (11o). CIL metadata tracking only (actual CIL content stored separately). |
| 🔬 Industrial security | **✅ Resolved.** DD-254 registry and contractor management defined in Phase 5 (11p). Unit tracks verification records, not raw DISS/JADE data. |

---

## 12. Supervisor Hub (P1) — 🤝

> **Dedicated supervisor-only section that consolidates team oversight, pending actions, compliance tracking, people management, and cross-module visibility into a single hub. Designed for USAF/DoD civilian supervisors managing GS/GG personnel (and potentially military), aligned with DPMAP (DoDI 1400.25 Vol 431), OPM leave administration, AFI 36-1001, SEAD 3 supervisor obligations, and Privacy Act boundaries. The SPA is a supplemental tracking tool — it does NOT replace enterprise systems of record (DCPDS, MyBiz+, ATAAPS, DISS). It tracks what those systems cannot: unit-level checklists, compliance dashboards, suspenses, and cross-module visibility that no single DoD enterprise system provides.**
>
> **Research-backed by:** DoDI 1400.25 (Vols 250, 431, 451, 771), AFI 36-1001, AFI 36-703, AFI 36-1004, DoDI 1035.01, AFI 36-816, SEAD 3, DoDI 5200.02, 5 CFR Parts 315/412/610/630, Privacy Act (5 USC 552a).

### Feature Tiers

| Tier | Description | Criteria |
|------|-------------|----------|
| **Must-Have** | Core supervisor functionality — team visibility, action queues, compliance dashboards, leave approval, training oversight | Directly supports regulatory supervisory obligations or is essential for daily team management |
| **Should-Have** | High-value additions — DPMAP tracking, probationary alerts, task/suspense management, onboarding checklists, awards | Addresses confirmed supervisory requirements but can be phased in after core Hub is operational |
| **Future Enhancement** | Ambitious extensions — work schedules, budget visibility, IDP tracking, performance analytics, delegated admin | Requires new SharePoint lists, stakeholder validation, or policy decisions before building |

---

### MUST-HAVE Features

#### 12a. Role-Based Visibility & Access Control — 💻

> **Existing infrastructure:** The `Supervisor` role is already detected two ways: (1) via `CCSD_AppRoles` where `Role = 'Supervisor'`, and (2) via the `IsSupervisor` boolean flag on `CCSD_Personnel` (see `Index.html:1998,2025`). Both paths push `'Supervisor'` into `APP.state.roleNames`. Existing gate functions `canReviewTraining()` and `canManageInOut()` already include the Supervisor role.

- [x] **New "Supervisor Hub" nav tab** — Added to `APP.nav` after "Reports". Only visible when `canSeeSupervisorHub()` returns true. ✅ Done 2026-04-14.
- [x] **New route** — `#supervisor` hash route added with role guard. Non-supervisors redirected to `#home` with toast. ✅ Done 2026-04-14.
- [x] **Gate function** — `canSeeSupervisorHub()` added → `hasAnyRole(['Supervisor','App Admin'])`. ✅ Done 2026-04-14.
- [ ] **Team scope definition** — The Hub operates on the supervisor's "team," defined as:
  - **Primary (default):** All active personnel in `CCSD_Personnel` where `SupervisorPersonID.Id` = current user's personnel ID (direct reports).
  - **Extended:** All active personnel in the supervisor's org (`OrgID`) and its descendant orgs (using the existing `getOrgAndDescendants()` function, see `Index.html:4104`).
  - **Toggle:** A scope toggle at the top of the Hub: "My Direct Reports" vs. "My Organization" to switch between primary and extended views. State persists in `APP.state.supervisorScope` for the session.
- [ ] **App Admin sees all** — Users with `App Admin` role see the Hub with access to all personnel (no org/supervisor filter). A dropdown lets them select any org to scope the view. The dropdown uses `CCSD_Organizations` data already loaded.
- [x] **Keyboard shortcut** — `Alt+V` registered, gated by `canSeeSupervisorHub()`. ✅ Done 2026-04-14.
- [ ] **Privacy boundary enforcement** — All Hub data queries are scoped to the supervisor's team. No lateral access (a supervisor cannot view another supervisor's team unless they are in their org hierarchy). App Admin bypasses this restriction. Queries use `$filter` constructed from team PersonIDs or OrgIDs — never unscoped queries.
- [x] **Privacy Act banner** — One-time-per-session acknowledgment modal displayed on first Hub visit. Dismissal logged to `logAudit()` with action `PrivacyBannerAcknowledged`. ✅ Done 2026-04-14.

#### 12b. Supervisor Landing Page / Overview Dashboard — 💻

> **The main view when a supervisor navigates to the Hub. Consolidates at-a-glance metrics, pending actions, team status, and compliance indicators. Follows the same visual pattern as the Home dashboard (KPI strip → cards → grid) but scoped entirely to the supervisor's team.**

- [ ] **Team strength summary** — KPI strip at top (same `dash-kpis` pattern as Home dashboard):
  - **Total assigned** (count of team members per scope toggle)
  - **Present today** (total minus those with `CCSD_TimeOff` entries for today where `Status = 'Approved'`)
  - **On leave** (count with `TimeOffType` in `Annual Leave`, `Sick Leave`, `Comp Time`, `LWOP`)
  - **TDY** (count with `TimeOffType = 'TDY'`)
  - **Telework** (count with `TimeOffType = 'Telework'`)
  - **Training** (count with `TimeOffType = 'Training'`)
  - **Vacancies** (if Manning feature is built — see 12m; graceful omission if not)
  - Each KPI is clickable — drills down to the filtered team roster showing those people

- [ ] **Pending actions queue** — Prominent card (red border if items overdue) listing ALL items requiring the supervisor's action, with counts and one-click action buttons:
  - Leave requests pending approval (`CCSD_TimeOff` where `Status = 'Pending'` for team members)
  - Requests assigned to supervisor (`CCSD_AppRequests` where `AssignedTo` = current user and status is open)
  - Training submissions pending review (`CCSD_TrainingSubmissions` where `Status = 'Pending Review'` for team members)
  - In-processing steps assigned to supervisor (`CCSD_InOutStepStatus` where `AssignedTo` = current user or `OwningOrgID` matches supervisor's org, and status is open)
  - SF-182 requests pending supervisor approval (`CCSD_SF182TrainingRequests` where `Status = 'Submitted'` for team members)
  - **Security clearance expirations** within 90 days (from `CCSD_SecurityRecords` if Security module exists — graceful omission if not yet built)
  - **DPMAP milestones overdue** (if Performance feature is built — see 12k; graceful omission if not)
  - **Probationary period milestones** (if tracking is built — see 12l; graceful omission if not)
  - Each item shows: type icon, subject name, age in days, due date, one-click action (Approve/Review/Open)
  - Items sorted by: overdue first (red), then due within 3 days (yellow), then age descending

- [ ] **Team readiness scorecard** — Color-coded indicators (green ≥90% / amber 70-89% / red <70%):
  - **Training compliance**: % of team with all mandatory training current (from `getTeamTrainingModel()` at Index.html:6939)
  - **Asset accountability**: % of team's assigned hardware verified within 90 days (from `CCSD_HardwareAssignments`)
  - **In/Out processing**: Count of active cases, any overdue steps highlighted red
  - **Open requests**: Count of open/overdue requests for the team
  - **Security status**: % of team with current clearance investigations (from `CCSD_SecurityRecords` if built)
  - **DPMAP on track**: % of team with current performance plan (if Performance feature is built)
  - Each scorecard cell is clickable — drills down to the relevant detail view

- [ ] **Recent activity feed** — Last 15 events relevant to the team:
  - New personnel arrivals (from `CCSD_Personnel` where `DateArrived` is recent)
  - Departures (from `CCSD_Personnel` where `DateDeparted` is recent)
  - Completed requests (from `CCSD_AppRequests` where status changed to complete)
  - Leave submitted/approved (from `CCSD_TimeOff` recently created)
  - Training completions (from `CCSD_TrainingRecords` recently created)
  - In/Out step completions (from `CCSD_InOutStepStatus` recently completed)
  - Sourced from existing lists sorted by `Created` or `Modified` date, filtered to team PersonIDs
  - Shows: icon, event description, person name, timestamp, relative time ("2 hours ago")

#### 12c. Team Roster & Status Visibility — 💻

> **Existing infrastructure:** The People module (`Index.html:2032`) already loads all personnel with org/position/supervisor lookups. The Home dashboard already shows a "Team Availability — Today" widget (`Index.html:2508`). The supervisor request dashboard (`Index.html:4099`) already filters requests by org. `getTeamTrainingModel()` (Index.html:6939) already computes per-person training compliance for the supervisor's team. `formatPerson()` (Index.html:2920) handles name display with rank prefix.**

- [ ] **Team roster table** — Sortable, filterable table of all team members showing:
  - Name (with rank/grade prefix), position title, org
  - Personnel category (Civilian, Military, Contractor, NAF — from `Category` field)
  - Current personnel status (Active, Leave, TDY, Training, Telework, Departed — from `Status` field)
  - Today's availability (computed from `CCSD_TimeOff` entries for today: ✅ Present, �� Leave, 🟠 TDY, 🟣 Telework, 🟤 Training)
  - Training compliance % (computed per person via `getTeamTrainingModel()` data, color-coded)
  - Open requests count (from `CCSD_AppRequests` filtered to that person)
  - Date arrived (from `DateArrived`)
  - Click row → opens existing person detail modal (`view-person` action)
  - Each row has a mini-action menu: View | Training | Assets | Leave History | Requests

- [ ] **Status filter bar** — Quick filter pills: All | Present | Leave | TDY | Telework | Training | Departed
  - Each shows a count badge
  - Multiple can be selected (OR logic) except "All" which is exclusive
  - Filter state persists in `APP.state.supervisorRosterFilter`

- [ ] **Roster search** — Text search across name, grade, position, org (reuses `filterLocal()` pattern from Index.html:1926)

- [ ] **Team calendar / availability grid** — Week/month grid showing team availability at a glance:
  - Rows = team members (sorted by org → name), columns = days
  - Color-coded cells: present (green), leave (blue), TDY (orange), telework (teal), training (purple), holiday (red stripe)
  - Summary row at top: "X of Y present" per day
  - **Critical staffing alert:** Red highlight on any day where present-for-duty drops below 50% of assigned strength
  - Federal holidays rendered with holiday name (reuses `getFederalHolidays()` at Index.html:2141)
  - Click a cell → shows detail (person name, time-off type, dates, notes)
  - Click a person row header → opens person detail
  - Reuses `CCSD_TimeOff` data already loaded by the Calendar module
  - Week/month toggle with prev/next navigation

- [ ] **Upcoming departures** — Card showing team members with `DateDeparted` set within the next 90 days, sourced from `CCSD_Personnel`. Shows: name, departure date, days remaining, out-processing status (from linked `CCSD_InOutProcessing` case if it exists). Red highlight if departure is within 30 days and no out-processing case exists.

- [ ] **Upcoming arrivals** — Card showing in-processing cases (`CCSD_InOutProcessing` where `ProcessType = 'In-Processing'` and `Status` is open/in-progress) for the supervisor's org. Shows: person name, arrival date, process status, % steps complete, overdue steps count.

- [ ] **Team org chart view** — Optional visual showing the supervisor's reporting chain as a tree/hierarchy. Reuses `getSupervisorChain()` (Index.html:7111) and org hierarchy data. Clickable nodes → person detail. Shows vacancy indicators for unfilled positions (if Manning feature is built).

#### 12d. People Management & Administrative Tools — 💻

> **Existing infrastructure:** The People module has edit personnel modal (`canEditPeople()` gated to HR/Admin/App Admin), departure processing, org transfer workflow, and personnel CSV export. The Supervisor Hub extends these with team-specific actions. Supervisors do NOT get full edit access to personnel records — that remains HR/Admin-gated. Supervisors get read access + limited actions on their own team members only.**

- [ ] **Quick actions per team member** — From the roster row or a detail modal, supervisor can:
  - View full person detail (existing `view-person` modal)
  - View assigned assets (links to Assets module filtered to that person via `focus-person-assets` action at Index.html:7465)
  - View training records (links to Training module filtered to that person)
  - View time-off history (shows `CCSD_TimeOff` entries for that person, last 12 months)
  - View/create requests on behalf of team member (pre-fills `PersonID` on request form)
  - Initiate in-processing or out-processing case for the team member (opens `openCreateInOutModal()` at Index.html:4251 with person pre-selected)
  - View security status summary (if Security module built — clearance level, investigation date, training status; no incident details per Section 11 privacy rules)

- [ ] **Supervisor-initiated leave entry** — Supervisor can create a `CCSD_TimeOff` entry on behalf of a team member:
  - Pre-populates `PersonID` with the selected team member
  - Pre-populates `ApprovedBy` with the supervisor
  - Status defaults to `Approved` (supervisor is recording an already-approved absence)
  - Audit logged: `LeaveCreatedBySupervisor` action type

- [ ] **Supervisor notes** — Free-text notes field visible only to the supervisor for each team member:
  - **⚠️ Policy decision needed:** Store on `CCSD_Personnel` as `SupervisorNotes` column (simpler, but visible to HR/Admin/App Admin) or in a new `CCSD_SupervisorNotes` list (more private, more complex). **Recommendation:** Use `CCSD_Personnel` column — supervisory notes about work assignments, development areas, and goals are not inherently private from HR. Truly private notes should not be in any shared system.
  - Character limit: 2000 characters
  - Shows last-edited timestamp
  - **Privacy note:** Notes must NOT contain medical information, EEO complaint details, or information the supervisor learned through accommodation processes. Display a reminder when editing.

- [ ] **Newcomer integration tracking** — For team members currently in-processing (`CCSD_InOutProcessing` where `ProcessType = 'In-Processing'` and status is open), show a dedicated onboarding card with:
  - Overall progress (% of steps complete)
  - Supervisor-specific steps as a checklist (assigned to the supervisor in `CCSD_InOutStepStatus`):
    - Welcome meeting conducted
    - Workspace/seat assigned (links to Facilities module seat assignment)
    - IT accounts verified (links to relevant request if created)
    - Team introduction completed
    - DPMAP performance plan initiated (links to Performance tracker if built)
    - Security in-briefing coordinated (links to Security module if built)
    - 30/60/90-day check-in schedule set
  - These are standard `CCSD_InOutStepStatus` rows assigned to the supervisor — they leverage the existing checklist infrastructure, not a new list
  - Days-since-arrival counter with milestone markers (30/60/90 days)
  - **⚠️ Regulatory note (DoDI 1400.25 Vol 250):** New employee orientation must be completed within the first week. DPMAP performance plan must be established within 30 days of entry on duty.

#### 12e. Pending Actions, Queues & Alerts — 💻

> **Consolidates ALL actionable items a supervisor needs to act on across ALL modules into a single prioritized queue. This is the Hub's core value proposition — replacing the need to check 5+ separate modules for pending items.**

- [ ] **Unified action queue** — Single sortable/filterable list combining all pending items:
  - **Columns:** Action type (icon + label), Subject (team member name), Description, Submitted date, Due date, Age (days since created), Priority indicator, Action button
  - **Item sources:**
    1. Leave requests pending (`CCSD_TimeOff` where `Status = 'Pending'`)
    2. Requests assigned to supervisor (`CCSD_AppRequests` where `AssignedTo` = current user, status open)
    3. Training submissions pending review (`CCSD_TrainingSubmissions` where `Status = 'Pending Review'`)
    4. In-processing steps assigned to supervisor (`CCSD_InOutStepStatus` where `AssignedTo` = current user or `OwningOrgID` = supervisor's org, status open)
    5. SF-182 requests pending supervisor approval (`CCSD_SF182TrainingRequests` where `Status = 'Submitted'`)
    6. Overdue training (team members with expired mandatory training — from `getTeamTrainingModel()`)
    7. DPMAP milestones overdue (if Performance feature built)
    8. Probationary period milestones approaching (if Probation tracking built)
    9. Security clearance actions needed (if Security module built and supervisor has notifications)
    10. Task/suspense items assigned to supervisor (if Task feature built — see 12n)
  - **Sorting:** Overdue first (red), then due within 3 days (yellow), then by age descending
  - **Filtering:** By type (checkbox pills), by person, by date range
  - **One-click actions:** Approve, Deny, Review, Open Detail — inline where possible, modal for complex actions
  - **Batch actions:** Select multiple leave requests → batch approve

- [ ] **Leave approval workflow** — Inline approve/deny for pending leave requests:
  - Expandable detail row showing: person, dates, type, hours, notes
  - **Conflict check:** Automatically shows other team members with approved time off overlapping the requested dates
  - **Manning impact:** "Approving would bring team to X of Y present on [dates]" — red warning if below 50%
  - **Leave balance awareness:** Display a note: "Leave balance information is maintained in ATAAPS. Verify balance before approving." (The SPA does not track leave balances — that's ATAAPS.)
  - Approve → sets `CCSD_TimeOff.Status = 'Approved'`, `ApprovedBy = currentUser`, `SupervisorDecisionDate = now()`. Calls `logAudit()`.
  - Deny → requires a reason note (`DecisionNotes`), sets `Status = 'Denied'`. Calls `logAudit()`.
  - If Notification Framework (Section 9) is built, sends notification to the requestor on approval/denial.

- [ ] **Training submission review** — Inline approve/reject for pending training submissions:
  - Show certificate/proof attachment if present (expandable inline preview)
  - Show training details: name, code, frequency, mandatory flag
  - Approve → creates `CCSD_TrainingRecords` entry (existing pattern from Index.html training submission flow). Calls `logAudit()`.
  - Reject → sets `Status = 'Rejected'` with notes. Calls `logAudit()`.

- [x] **SF-182 approval** — ✅ Done 2026-04-18. `sf182SupervisorAction()` handles approve/return/reject with notes prompts, updates Status, calls `logAudit()` and `sendNotification()`. Integrated into unified action queue with 🎓 icon.

- [x] **In-processing step sign-off** — ✅ Done 2026-04-18. `completeInOutStep()` sets Status='Complete', CompletedBy/CompletedOn, calls `logAudit()`. Integrated into unified action queue with 🔄 icon.

- [ ] **Overdue badge on Hub nav tab** — Red badge showing count of overdue items across all sources. Badge renders in `renderNav()` when `canSeeSupervisorHub()` is true. Count computed from cached action queue data. Updates on each page load.

#### 12f. Cross-Module Connections — 💻

> **The Supervisor Hub does not replace existing modules — it provides a supervisor-scoped lens into them. Each link passes context (org filter, person filter) so the destination module shows team-relevant data immediately.**

- [x] **Link to Calendar** — ✅ Done 2026-04-18. "Team Calendar" link in Quick Navigation card navigates to `#calendar`.
- [x] **Link to Training** — ✅ Done 2026-04-18. "Team Training" link in Quick Navigation card navigates to `#training`.
- [x] **Link to Requests** — ✅ Done 2026-04-18. "Team Requests" link in Quick Navigation card navigates to `#requests`.
- [x] **Link to In/Out** — ✅ Done 2026-04-18. "In/Out Processing" link in Quick Navigation card navigates to `#inout`.
- [x] **Link to Assets** — ✅ Done 2026-04-18. "Team Assets" link in Quick Navigation card navigates to `#assets`.
- [x] **Link to Security** — ✅ Done 2026-04-18. "Security" link gated by `hasAnyRole(['Security', 'App Admin'])`.
- [ ] **Context preservation** — When navigating from the Hub to another module, the module respects the passed filter. When the user navigates back to `#supervisor`, the Hub state (scope toggle, active tab, scroll position) is preserved in `APP.state.supervisorState`.

#### 12g. Reporting, Dashboards & Drilldowns — 💻

> **Supervisors need actionable reports, not raw data. Each report is accessible within the Hub and also registered in the Reports module (Section 10) for consistency. All reports are scoped to the supervisor's team — App Admin can select any org.**

- [ ] **Team summary report** — Printable/exportable report showing:
  - Roster with: name, grade, position, org, status, date arrived, training compliance %, open requests count
  - Training compliance matrix (person × mandatory training items, with Current/Expired/Missing status per cell)
  - Open requests summary by type and status
  - Asset inventory per person (count of hardware/software assigned)
  - Time-off summary (approved hours by type for selected period: month/quarter/FY)
  - In/Out processing status (active cases, step completion %)
  - **Export:** CSV and print-optimized HTML. CSV includes CUI banner header if security data is included.

- [ ] **Training compliance drilldown** — Click the training compliance KPI to see a full per-person × per-training matrix:
  - Rows = team members, columns = mandatory training items (from `CCSD_TrainingCatalog` where `IsMandatory = true` or `Required = true`)
  - Cell values: ✅ Current (green) | ⚠️ Due Soon (yellow) | ❌ Expired (red) | — Missing (gray)
  - Expiration date shown in each cell
  - Column header shows overall % compliant for that training
  - Row total shows per-person compliance %
  - Click any cell → shows training detail modal
  - Reuses `getTeamTrainingModel()` data with expanded per-training detail

- [ ] **Leave utilization report** — Table showing leave usage by team member for selected period:
  - Rows = team members, columns = leave types (Annual, Sick, Comp Time, LWOP, TDY, Telework, Training)
  - Cell values = count of days or total hours for the period
  - Period selector: This Month | This Quarter | This FY | Custom Date Range
  - Summary row: team totals per type
  - Sourced from `CCSD_TimeOff` filtered to team members and date range
  - **Privacy note:** This tracks APPROVED time-off entries in the SPA, not official leave balances (those are in ATAAPS).

- [ ] **Equipment accountability report** — Table showing per-person hardware/software assignments:
  - Rows = team members, columns = hardware count, software count, last audit date
  - Expandable row → shows individual asset details
  - Highlights: unaudited assets (>90 days), missing assignments
  - Sourced from `CCSD_HardwareAssignments` and `CCSD_SoftwareAssignments`

- [ ] **Add to Reports module** — Register supervisor-specific report types in the existing Reports nav section (Section 10):
  - "Supervisor Team Summary" | "Team Training Compliance" | "Team Leave Utilization" | "Team Equipment Accountability"
  - These reports are role-gated: only visible when `canSeeSupervisorHub()` returns true

#### 12h. Supervisor Notification Integration — 💻

> **Integrates the Supervisor Hub with the Notification Framework (Section 9) so supervisors receive timely alerts about their team and can send team-scoped notifications.**

- [ ] **Supervisor-specific notification types** — The Hub generates these via the Notification Framework:
  - `SUP-TEAM-ALERT`: Weekly team compliance summary (training gaps, overdue requests, expiring clearances) — generated by `initNotificationChecks()` (NF-13)
  - `SUP-LEAVE-PENDING`: Immediate notification when a team member submits a leave request requiring approval
  - `SUP-INOUT-STEP`: Notification when an in-processing step is assigned to the supervisor
  - `SUP-TRAINING-SUBMIT`: Notification when a team member submits training completion for review
  - `SUP-SF182-PENDING`: Notification when an SF-182 request needs supervisor approval
  - `SUP-DPMAP-DUE`: DPMAP milestone approaching (if Performance feature built)
  - `SUP-PROBATION-DUE`: Probationary period milestone approaching (if Probation feature built)

- [ ] **Supervisor notification templates** — Add to `APP.config.notificationTemplates`:
  | Template ID | Sensitivity | Body Pattern |
  |-------------|-------------|-------------|
  | `SUP-TEAM-ALERT` | Internal | "{count} item(s) requiring attention in your team. Review the Supervisor Hub." |
  | `SUP-LEAVE-PENDING` | Internal | "{personName} has submitted a leave request for {dates}. Review in the Supervisor Hub." |
  | `SUP-INOUT-STEP` | Public | "An in-processing step has been assigned to you for {personName}." |
  | `SUP-TRAINING-SUBMIT` | Public | "{personName} has submitted a training completion for your review." |
  | `SUP-SF182-PENDING` | Public | "An SF-182 training request from {personName} requires your approval." |
  | `SUP-DPMAP-DUE` | Internal | "DPMAP milestone approaching: {milestone} for {personName} is due {dueDate}." |
  | `SUP-PROBATION-DUE` | Internal | "Probationary period milestone: {personName}'s {milestone} review is due {dueDate}." |

- [ ] **Send team notification** — Supervisor can send notifications to their team via `openNotificationComposer()` (NF-12) with `AudienceType = 'Organization'` pre-set to their org. Restricted to `Supervisor Alert` and `General` notification types per NF permission matrix.

- [ ] **Hub notification panel** — Dedicated notification section within the Hub showing supervisor-relevant notifications:
  - Filtered to notification types starting with `SUP-` or where `RecipientRole = 'Supervisor'`
  - Shows alongside the pending actions queue
  - Uses the same `CCSD_NotificationReceipts` query as the general notification panel but with Hub-specific filtering

---

### SHOULD-HAVE Features

> **High-value additions that address confirmed supervisory requirements (regulatory or best practice). Each requires a new SharePoint list or significant new column additions. Recommended for phased implementation after the Must-Have core is operational.**

#### 12i. Training Compliance Deep View — 💻

> **Extends the basic training compliance KPI from 12b into a full supervisor-facing training management view. Builds on the existing `getTeamTrainingModel()` function (Index.html:6939) and `renderTeamTraining()` (Index.html:6970).**

- [ ] **Full training compliance matrix** — Person × Training grid:
  - Rows = team members. Columns = all mandatory training items from `CCSD_TrainingCatalog` where `Required = true` or `IsMandatory = true`.
  - Cell = completion status (Current ✅ / Due Soon ⚠️ / Expired ❌ / Missing —) with expiration date
  - Row summary: compliance % per person. Column summary: compliance % per training.
  - Color-coded: row turns red if any item expired, yellow if any due soon
  - Click a cell → shows training record detail or "no record found" with "Notify" button
  - **Data:** Entirely from existing `CCSD_TrainingRecords`, `CCSD_TrainingCatalog`, `CCSD_Personnel`. No new lists needed.

- [ ] **Training gap actions** — From the matrix, supervisor can:
  - Send reminder notification to a team member with expired/missing training (uses Notification Framework NF-12 with `TRAIN-EXPIRED` or `TRAIN-EXPIRE-30` template)
  - Bulk-select team members with a specific missing training → send batch reminder
  - Export training compliance matrix to CSV for reporting to higher headquarters
  - View pending training submissions for review (same as action queue item)

- [ ] **Supervisor's own training tracker** — Prominent card showing the supervisor's own mandatory trainings, including supervisor-specific requirements:
  - DPMAP Supervisory Training (initial + refresher per DoDI 1400.25 Vol 431)
  - Supervisory EEO/No FEAR Act Training (per DoDI 1400.25 Vol 771)
  - Civilian Supervisory Course (if required within first year of supervisory assignment)
  - Cyber Awareness, SAPR, Suicide Prevention, AT Level I, OPSEC, Records Management (standard DoD mandatory training)
  - **Data:** From existing `CCSD_TrainingRecords` for the current user. No new lists needed.

#### 12j. Telework & Work Schedule Management — 🤝

> **✦ Regulatory: DoDI 1035.01 and AFI 36-816 require written telework agreements (DD Form 2946) before telework begins, reviewed annually. 5 CFR 610 governs alternate work schedules. This feature tracks agreement status and schedules — it does NOT replace official HR forms.**

- [ ] **Telework agreement tracker** — Per team member:
  - Agreement status: Active, Expired, None, Pending
  - Agreement type: Routine (regular schedule), Situational (ad hoc), Emergency
  - Approved date, expiration date (auto-computed: approval + 1 year)
  - Regular telework days (e.g., Mon/Wed)
  - **Alert:** Flag expired agreements (red). Flag agreements expiring within 30 days (yellow).
  - **⚠️ Policy decision needed:** Store in `CCSD_Personnel` as additional columns (simpler) or in a new `CCSD_TeleworkAgreements` list (more structured, supports history). **Recommendation:** New list — agreements have start/end dates and change over time.
  - **Data dependency:** New `CCSD_TeleworkAgreements` list (see data dependencies section).

- [ ] **Alternate work schedule visibility** — Per team member:
  - Schedule type: Standard (5/8), CWS (Compressed Work Schedule), FWS (Flexible Work Schedule), Maxiflex, 4-10, 5-4/9
  - Regular day off (RDO) for CWS employees
  - Core hours (if FWS/Maxiflex)
  - **Use:** Integrated into the team calendar/availability grid (12c) — show RDOs as "scheduled off" in a distinct color
  - **Data dependency:** New columns on `CCSD_Personnel`: `WorkScheduleType` (Choice), `RegularDayOff` (Choice: Mon-Fri), `CoreHoursStart` (Text), `CoreHoursEnd` (Text). Simple columns, no new list needed.

#### 12k. DPMAP Performance Cycle Tracking — 🤝

> **✦ Regulatory requirement (DoDI 1400.25 Vol 431). The DPMAP appraisal cycle runs 1 April – 31 March. Supervisors must establish performance plans within 30 days, conduct at least one midpoint progress review, and complete annual appraisals by 31 March. The SPA tracks cycle dates and milestones — it does NOT store narrative appraisals, objectives, or ratings (those belong in MyBiz+/PAA).**

- [ ] **DPMAP cycle dashboard** — Per team member, track:
  - Appraisal cycle: Current FY cycle (e.g., 1 Apr 2025 – 31 Mar 2026)
  - Performance plan established: Yes/No, date established
  - Midpoint review completed: Yes/No, date completed
  - Annual appraisal completed: Yes/No, date completed, rating submitted to HR: Yes/No
  - Next cycle action: What's due next and when
  - Status: On Track (green) / Milestone Approaching (yellow) / Overdue (red)
  - **Alerts:**
    - Performance plan not established by 1 May → yellow, by 15 May → red
    - Midpoint review not completed by 1 Nov → yellow, by 15 Nov → red
    - Annual appraisal not completed by 15 Mar → yellow, by 31 Mar → red
  - **⚠️ Critical:** Do NOT store performance ratings, narrative objectives, critical elements, or improvement plans. Those are in the enterprise PAA (Performance Appraisal Application) / MyBiz+. The SPA tracks only: "has this milestone been completed, and when?"

- [ ] **Probationary period tracking** — For new employees (per 5 CFR 315.801-805; AFI 36-1001):
  - Probationary start date (= `DateArrived` for new competitive-service appointees)
  - Probationary end date (start + 1 year)
  - Status: In Probation / Converted / Separated
  - **Milestone alerts:**
    - 6-month check-in due
    - 9-month progress review due (supervisor must assess whether employee should be retained)
    - 11-month final decision point — **critical**: missing this means automatic conversion
    - 30 days before end: urgent alert if no decision recorded
  - **Data dependency:** New `CCSD_PerformanceTracking` list (see data dependencies section). Alternatively, could be additional columns on `CCSD_Personnel` if the scope stays minimal.

#### 12l. Awards & Recognition Tracking — 🤝

> **Best practice aligned with DoDI 1400.25 Vol 451 and AFI 36-1004. Tracks award nominations submitted by the supervisor and helps ensure equitable distribution. The SPA does NOT replace the official awards processing system — it tracks nominations and outcomes for supervisor awareness.**

- [ ] **Awards tracker** — Supervisor can record and track:
  - Award type: Time-Off Award, Quality Step Increase (QSI), On-the-Spot Award, Special Act Award, Performance Award, Quarterly/Annual Award, Commander's Coin, Letter of Appreciation
  - Nominee (team member)
  - Nomination date, submitted date, decision date
  - Status: Draft, Submitted, Approved, Denied, Presented
  - Amount (hours for Time-Off Awards, dollars for monetary awards)
  - **Constraints from DoDI 1400.25 Vol 451:**
    - Time-Off Awards: max 40 hours per award, max 80 hours per employee per year
    - On-the-Spot Awards: max $50 without higher approval (varies by installation)
  - **Equity view:** Summary showing awards distribution by team member over trailing 12 months — helps supervisor ensure equitable recognition
  - **Data dependency:** New `CCSD_Awards` list (see data dependencies section).

#### 12m. Manning & Position Visibility — 🤝

> **Best practice per AFI 38-101 and AFI 36-1001. Supervisors should know their authorized vs. assigned positions, vacancy status, and pending fill actions. The SPA provides unit-level visibility — it does NOT replace UMPR (Unit Manpower Personnel Roster) or DCPDS position management.**

- [ ] **Manning roster** — Table showing:
  - Position number (from `CCSD_Positions`)
  - Position title, grade, series
  - Incumbent (linked to `CCSD_Personnel`) or "VACANT"
  - Status: Filled, Vacant, Pending Fill, Frozen, Temporarily Occupied
  - Fill action status (if vacant): Recruitment in progress, Awaiting classification, Pending funding, None
  - Date vacated (if vacant)
  - Days vacant counter
  - **KPI:** Authorized strength / Assigned strength / Fill rate %
  - **Data sources:** `CCSD_Positions` (existing) linked to `CCSD_Personnel` (existing). May need new columns on `CCSD_Positions`: `AuthorizedGrade` (Choice), `PositionStatus` (Choice), `VacatedDate` (Date), `FillActionStatus` (Choice).
  - **Privacy note:** Position data (grade, title, occupancy) is NOT PII — it's organizational/manpower data. No privacy restrictions on supervisor access.

- [ ] **Position description (PD) currency tracker** — For each position:
  - PD number, last review date
  - Flag PDs not reviewed in >2 years (per AFI 36-1001 — supervisors must keep PDs current)
  - Alert when a PD review is overdue
  - **Data dependency:** New columns on `CCSD_Positions`: `PDNumber` (Text), `PDLastReviewDate` (Date).

#### 12n. Task & Suspense Management — 🤝

> **Best practice for DoD unit-level management. Tasks/taskers flow from higher headquarters and must be tracked to completion. This is consistently identified as a high-value feature for supervisor oversight tools. The SPA provides a lightweight task tracker — not a replacement for TMT (Task Management Tool) or official tasker systems.**

- [ ] **Task board** — Supervisor can create, assign, and track tasks/suspenses:
  - Task fields: Title, description, assigned to (team member or self), originator, suspense date, priority (Routine/High/Urgent), status (Open/In Progress/Complete/Cancelled), category (Tasker/Suspense/Action Item/Follow-Up/Other), completion date, notes
  - **Views:**
    - **List view:** Sortable/filterable table with overdue highlighting
    - **Kanban board (optional):** Columns = Open / In Progress / Complete. Drag to change status.
    - **Calendar view:** Tasks plotted by suspense date on a calendar grid
  - **Features:**
    - Overdue tasks highlighted red, due within 3 days yellow
    - Recurring tasks (e.g., "Weekly staff meeting prep" — auto-recreates on completion)
    - Task assignment notification via Notification Framework (NF-04)
    - Bulk assign: select multiple team members → assign the same task to each
    - Task completion notification to originator
  - **Integration:** Task items appear in the unified action queue (12e) alongside leave requests, training reviews, etc.
  - **Data dependency:** New `CCSD_TaskAssignments` list (see data dependencies section).

---

### FUTURE ENHANCEMENT Features

> **Ambitious extensions requiring new SharePoint lists, stakeholder validation, or policy decisions. Each is independently viable and does not block Must-Have or Should-Have features. Build only when approved by the project owner.**

#### 12o. Disciplinary Action Tracking — 🤝

> **⚠️ Extremely sensitive data. Per 5 CFR 752 and AFI 36-704, disciplinary records have strict access rules and retention limits. Supervisors may access records they initiated or that are active. Full documentation belongs in the Employee Relations (ER) case file, not the SPA. The SPA tracks only: type, date issued, expiration, status.**

- [ ] **Active action tracker** — Per team member (visible only to their supervisor and HR/Admin):
  - Action type: Letter of Counseling, Letter of Admonishment, Letter of Reprimand, Suspension, Removal Action, PIP (Performance Improvement Plan)
  - Date issued, expiration date (reprimands: 1-3 years per Douglas Factors), status (Active/Expired/Rescinded)
  - NO narrative content, NO underlying facts, NO witness statements — those are in the ER file
  - Auto-archive when expiration date passes
  - **⚠️ Policy decision required:** Confirm with Employee Relations and Privacy Act officer before implementing. May require broken permission inheritance on the SharePoint list.
  - **Data dependency:** New `CCSD_DisciplinaryActions` list.

#### 12p. Individual Development Plans (IDPs) — 💻

> **Soft requirement per 5 CFR 412.101 and DoDI 1400.25 Vol 250. IDPs are encouraged for all employees, typically updated annually alongside DPMAP. The SPA tracks only whether an IDP exists and when it was last updated — NOT the plan content.**

- [ ] **IDP status tracker** — Per team member:
  - IDP on file: Yes/No
  - Last updated date
  - Next review date (typically aligns with DPMAP midpoint review)
  - Status: Current (updated within 12 months) / Due for Update / No IDP
  - **Data:** Could be 2 columns on `CCSD_Personnel` (`IDPOnFile` Yes/No, `IDPLastUpdated` Date) — no new list needed.

#### 12q. Work Schedule & Overtime Management — 🤝

> **Tracks alternate work schedules, overtime authorization, and comp time. The SPA is NOT the timekeeper (that's ATAAPS). It provides supervisor awareness of scheduling arrangements.**

- [ ] **Overtime authorization tracker** — Record approved overtime/comp time:
  - Employee, date, hours authorized, type (Overtime/Comp Time/Credit Hours), approver, reason
  - Running total by employee per pay period / month / FY
  - **Data dependency:** New `CCSD_OvertimeAuthorization` list or columns on `CCSD_TimeOff` (with an expanded `TimeOffType` choice set).

#### 12r. Sponsorship Program Management — 🤝

> **Best practice for military/DoD organizations. Assign sponsors to incoming personnel to facilitate smooth integration.**

- [ ] **Sponsor assignments** — When an in-processing case is created:
  - Supervisor assigns a sponsor from the team roster
  - Sponsor receives notification (via NF-04)
  - Sponsor checklist: initial contact made, welcome packet sent, workstation tour, first-day escort
  - Tracked as steps in `CCSD_InOutStepStatus` assigned to the sponsor — no new list needed

#### 12s. Additional Future Items — ⚠️ Requires Stakeholder Validation

> **These items were identified during research but require explicit project owner approval before any design work begins. Each is listed with the rationale for inclusion and the decision needed.**

| Item | Rationale | Decision Needed | Potential Data Source |
|------|-----------|-----------------|---------------------|
| **GPC (Government Purchase Card) tracking** | Supervisors accountable for cardholder oversight (DoDI 5000.76) | Does CPSG manage GPC cards? | New `CCSD_GPCTransactions` list |
| **Budget visibility** | Supervisors may need org-level budget execution data | Is budget data available/appropriate for the SPA? | New `CCSD_BudgetTracking` list |
| **Medical/fitness readiness (military)** | Track IMR status for military subordinates (AFI 10-203) — status only, no diagnoses | Are military personnel assigned to CPSG? | New columns on `CCSD_Personnel` |
| **Deployment readiness (military)** | Track deployment-related readiness items | Same as above | New list or columns |
| **Duty roster / shift scheduling** | Visual duty roster for daily coverage | Is shift scheduling relevant for CPSG? | New `CCSD_DutyRoster` list |
| **Standup/status notes** | Weekly accomplishments/plans/issues recording | Does the team want digital standup tracking? | New `CCSD_StandupNotes` list |
| **Leave balance tracking** | Manual/periodic recording of leave balances from ATAAPS | Is this needed given ATAAPS is the system of record? | New `CCSD_LeaveBalances` list |
| **Team announcements** | Org-scoped announcements from supervisors | Can this be handled by `CCSD_Announcements` with a `TargetOrgID` column? | Column addition to existing list |
| **Delegation of authority** | Track temporary supervisor delegations (leave, acting) | Is this needed? | New `CCSD_Delegations` list |
| **Reasonable accommodation tracking** | Track implementation status of approved accommodations (NOT medical details) | Privacy officer approval needed | New list with restricted access |

---

### Data Dependencies Summary

#### Must-Have Core (No New Lists Required)

The Must-Have features (12a-12h) operate entirely on existing lists:

| Existing List | Used By | Purpose |
|---------------|---------|---------|
| `CCSD_Personnel` | 12a, 12c, 12d | Team roster, supervisor linkage, person details |
| `CCSD_Organizations` | 12a, 12c | Org hierarchy, scope filtering |
| `CCSD_TimeOff` | 12b, 12c, 12e | Leave management, team calendar, leave approval |
| `CCSD_TrainingRecords` / `CCSD_TrainingCatalog` | 12b, 12i | Training compliance |
| `CCSD_TrainingSubmissions` | 12e | Submission review |
| `CCSD_AppRequests` | 12b, 12e | Request management |
| `CCSD_InOutProcessing` / `CCSD_InOutStepStatus` | 12b, 12c, 12d, 12e | In/out processing |
| `CCSD_SF182TrainingRequests` | 12e | SF-182 approvals |
| `CCSD_HardwareAssignments` / `CCSD_SoftwareAssignments` | 12b, 12g | Asset visibility |
| `CCSD_SecurityRecords` | 12b, 12f | Security status (if built) |
| `CCSD_Notifications` / `CCSD_NotificationReceipts` | 12h | Notification integration (if built per Section 9) |
| `CCSD_AppRoles` | 12a | Role detection |
| `CCSD_AppAuditLog` | All | Audit logging |
| `CCSD_Positions` | 12m | Position/manning data |

#### Columns to Add to Existing Lists — 👤

| List | Column | Type | Needed For | Tier |
|------|--------|------|------------|------|
| `CCSD_Personnel` | `SupervisorNotes` | Multiple lines of text | Supervisor notes per team member (12d) | Must-Have |
| `CCSD_TimeOff` | `RequestedDate` | Date | Track when leave was originally requested (12e) | Must-Have |
| `CCSD_TimeOff` | `SupervisorDecisionDate` | Date | Track when supervisor approved/denied (12e) | Must-Have |
| `CCSD_TimeOff` | `DecisionNotes` | Multiple lines of text | Reason for denial or conditions (12e) | Must-Have |
| `CCSD_Personnel` | `WorkScheduleType` | Choice | CWS/FWS/Maxiflex/Standard schedule type (12j) | Should-Have |
| `CCSD_Personnel` | `RegularDayOff` | Choice (Mon-Fri) | RDO for CWS employees (12j) | Should-Have |
| `CCSD_Personnel` | `ProbationaryStartDate` | Date | Probationary period tracking (12k) | Should-Have |
| `CCSD_Personnel` | `ProbationaryEndDate` | Date | Probationary period tracking (12k) | Should-Have |
| `CCSD_Personnel` | `ProbationaryStatus` | Choice | In Probation/Converted/Separated (12k) | Should-Have |
| `CCSD_Personnel` | `IDPOnFile` | Yes/No | IDP tracking (12p) | Future |
| `CCSD_Personnel` | `IDPLastUpdated` | Date | IDP tracking (12p) | Future |
| `CCSD_Positions` | `PDNumber` | Single line of text | PD currency tracking (12m) | Should-Have |
| `CCSD_Positions` | `PDLastReviewDate` | Date | PD currency tracking (12m) | Should-Have |
| `CCSD_Positions` | `PositionStatus` | Choice | Filled/Vacant/Pending Fill/Frozen (12m) | Should-Have |
| `CCSD_Positions` | `VacatedDate` | Date | Vacancy duration tracking (12m) | Should-Have |
| `CCSD_Positions` | `FillActionStatus` | Choice | Recruitment status (12m) | Should-Have |

#### New SharePoint Lists Required (Should-Have / Future Tiers Only)

| List | Columns | Feature | Tier | Priority |
|------|---------|---------|------|----------|
| `CCSD_TeleworkAgreements` | ~8 (PersonID, AgreementType, ApprovedDate, ExpirationDate, TeleworkDays, Status, ApprovedBy, Notes) | Telework agreement tracking (12j) | Should-Have | P2 |
| `CCSD_PerformanceTracking` | ~12 (PersonID, CycleYear, PlanEstablished, PlanDate, MidpointCompleted, MidpointDate, AnnualCompleted, AnnualDate, RatingSubmitted, ProbationaryStatus, ProbStartDate, ProbEndDate) | DPMAP + probation tracking (12k) | Should-Have | P1 |
| `CCSD_Awards` | ~10 (PersonID, AwardType, NominationDate, SubmittedDate, DecisionDate, Status, Amount, Hours, ApprovedBy, Notes) | Awards tracking (12l) | Should-Have | P2 |
| `CCSD_TaskAssignments` | ~12 (Title, Description, AssignedTo, Originator, SuspenseDate, Priority, Status, Category, CompletionDate, IsRecurring, RecurrencePattern, Notes) | Task/suspense management (12n) | Should-Have | P2 |
| `CCSD_DisciplinaryActions` | ~8 (PersonID, ActionType, DateIssued, ExpirationDate, Status, IssuedBy, Notes, IsArchived) | Disciplinary tracking (12o) | Future | P3 |
| `CCSD_OvertimeAuthorization` | ~8 (PersonID, Date, Hours, Type, ApprovedBy, Reason, PayPeriod, Notes) | Overtime tracking (12q) | Future | P3 |

---

### Implementation Tasks (SH-01 through SH-24)

> **Ordered by dependency. SH = Supervisor Hub. Must-Have tasks first, then Should-Have, then Future. Each task maps to a specific feature section.**

##### Must-Have Core (Build First — No New Lists Needed)

- [x] **SH-01: Add `Supervisor` role entries to `CCSD_AppRoles`** — 👤 ✅ Done 2026-04-18. Data entry. Add rows mapping each supervisor to `Role = 'Supervisor'`. Alternatively, the `IsSupervisor` flag on `CCSD_Personnel` auto-grants the role (existing logic at Index.html:2025).
- [x] **SH-02: Add leave approval columns to `CCSD_TimeOff`** — 👤 ✅ Created 2026-04-18. Add `RequestedDate` (Date), `SupervisorDecisionDate` (Date), `DecisionNotes` (Multi-line text). See Columns table above.
- [x] **SH-03: Add `SupervisorNotes` column to `CCSD_Personnel`** — 👤 ✅ Created 2026-04-18. Multi-line text. See Columns table above. ⚠️ See privacy decision note in 12d.
- [x] **SH-04: Build `canSeeSupervisorHub()` gate + route** — 💻 Gate function added, `#supervisor` route in router, nav tab in `APP.nav` with conditional visibility, `Alt+V` shortcut registered. ✅ Done 2026-04-14.
- [x] **SH-05: Build team scope resolution** — 💻 Team scope resolution built inline in `renderSupervisorHubContent()`. Scope toggle ("My Direct Reports" / "My Organization") with `APP.state.supervisorScope` persistence. Uses `SupervisorPersonID` match for direct, `getOrgAndDescendants()` for org. ✅ Done 2026-04-14.
- [x] **SH-06: Build Privacy Act banner** — 💻 One-time-per-session acknowledgment modal on first Hub visit. Logs `PrivacyBannerAcknowledged` to `logAudit()`. ✅ Done 2026-04-14.
- [~] **SH-07: Build landing page / overview dashboard** — 💻 Per 12b spec. KPI strip and pending actions summary built. Still needed: readiness scorecard, recent activity feed. Partially done 2026-04-14.
- [~] **SH-08: Build team roster table** — 💻 Per 12c spec. Basic sortable roster built (name, grade, position, org, status). Still needed: status filter pills, search bar, quick-action row menus, team calendar grid. Partially done 2026-04-14.
- [ ] **SH-09: Build team calendar / availability grid** — 💻 Per 12c spec. Week/month grid, color-coded cells, manning summary, critical staffing alerts. Reuses `CCSD_TimeOff` data.
- [x] **SH-10: Build unified action queue** — 💻 ✅ Done 2026-04-18. `renderSupervisorActionQueue()` aggregates pending leave + requests assigned + training submissions into a single sorted list (overdue first, then oldest). Inline action buttons per item.
- [x] **SH-11: Build leave approval workflow** — 💻 ✅ Done 2026-04-18. `approveLeaveRequest()` / `denyLeaveRequest()` prompt for notes/reason, update Status + SupervisorDecisionDate + DecisionNotes via `updateListItem` (audit logged), send notification to requester via `sendNotification()`. Manning-impact panel deferred.
- [x] **SH-12: Build training submission review** — 💻 ✅ Done 2026-04-18 via integration. The unified action queue surfaces pending submissions with approve/reject buttons that route to the existing `reviewSubmission()` Training pipeline.
- [x] **SH-13: Build SF-182 approval workflow** — 💻 ✅ Done 2026-04-18. `sf182SupervisorAction()` with approve/return/reject actions, notes prompts, notification sending. Wired into handleClick and unified action queue.
- [x] **SH-14: Build in-processing step sign-off** — 💻 ✅ Done 2026-04-18. `completeInOutStep()` marks steps complete with CompletedBy/CompletedOn. Wired into handleClick and unified action queue.
- [x] **SH-15: Build cross-module links** — 💻 ✅ Done 2026-04-18. "Quick Navigation" card added to Supervisor Hub with icon-labeled links to Calendar, Training, Requests, In/Out Processing, Assets, Facilities, Security (gated), and Reports. Each passes context via route navigation.
- [ ] **SH-16: Build reports** — 💻 Per 12g spec. Team summary, training compliance matrix, leave utilization, equipment accountability. CSV export. Register in Reports module.
- [ ] **SH-17: Integrate with Notification Framework** — 💻 Per 12h spec. Supervisor notification templates, team notification sending, Hub notification panel. Depends on NF-04 (Section 9) being built.

##### Should-Have (Build After Core — Requires New Lists/Columns)

- [x] **SH-18: Create `CCSD_PerformanceTracking` list** — 👤 ✅ Created 2026-04-18. ~12 columns per data dependencies table.
- [x] **SH-19: Add position management columns to `CCSD_Positions`** — 👤 ✅ Created 2026-04-18. PDNumber, PDLastReviewDate, PositionStatus, VacatedDate, FillActionStatus.
- [ ] **SH-20: Build DPMAP cycle tracker** — 💻 Per 12k spec. Cycle dashboard, milestone alerts, probationary period tracking.
- [ ] **SH-21: Build manning/position visibility** — 💻 Per 12m spec. Manning roster, vacancy tracking, PD currency tracker.
- [x] **SH-22: Create `CCSD_TeleworkAgreements` list** — 👤 ✅ Created 2026-04-18. ~8 columns per data dependencies table.
- [ ] **SH-23: Build telework agreement tracker** — 💻 Per 12j spec. Agreement status, expiration alerts, schedule visibility.
- [x] **SH-24: Create `CCSD_Awards` list** — 👤 ✅ Created 2026-04-18. ~10 columns per data dependencies table.
- [ ] **SH-25: Build awards tracker** — 💻 Per 12l spec. Nomination tracking, equity view.
- [x] **SH-26: Create `CCSD_TaskAssignments` list** — 👤 ✅ Created 2026-04-18. ~12 columns per data dependencies table.
- [ ] **SH-27: Build task/suspense management** — 💻 Per 12n spec. Task board, views, notifications, recurring tasks.

##### Future Enhancement (Build Only When Approved)

- [x] **SH-28: Create `CCSD_DisciplinaryActions` list** — 👤 ✅ Created 2026-04-18. Per 12o spec. ⚠️ Requires ER/Privacy officer approval.
- [ ] **SH-29: Build disciplinary action tracker** — 💻 Per 12o spec.
- [ ] **SH-30: Build IDP tracking** — 💻 Per 12p spec. Columns on `CCSD_Personnel`.
- [ ] **SH-31: Build overtime authorization** — 💻 Per 12q spec.
- [ ] **SH-32: Build sponsorship program** — 💻 Per 12r spec. Uses existing `CCSD_InOutStepStatus`.

---

### Policy & Stakeholder Validation Items

> **These items require human decisions before implementation can proceed. Each references the feature section that depends on the decision.**

| # | Item | Decision Needed | Depends On | Action |
|---|------|----------------|------------|--------|
| 1 | **Supervisor notes storage** | Store on `CCSD_Personnel` (visible to HR/Admin) or new list with broken inheritance? Recommendation: `CCSD_Personnel` column. | 12d | **Ask project owner** |
| 2 | **DPMAP scope** | Should the SPA track DPMAP cycle milestones? If yes, what level of detail? Recommendation: milestone dates only, no narratives. | 12k | **Ask project owner** |
| 3 | **Probationary tracking** | Are there current probationary employees? Is this tracking needed? | 12k | **Ask project owner** |
| 4 | **Awards tracking** | Does the unit want to track award nominations in the SPA? | 12l | **Ask project owner** |
| 5 | **Manning/position visibility** | Is the `CCSD_Positions` list populated with UMD-level data? Does it include authorized grades and vacancy status? | 12m | **Ask project owner** |
| 6 | **Task/suspense management** | Does the unit need a tasker tracking system in the SPA? Or is there an existing tool (TMT, SharePoint task list)? | 12n | **Ask project owner** |
| 7 | **Telework agreements** | Does the unit need telework agreement tracking? Are DD Form 2946 agreements managed locally? | 12j | **Ask project owner** |
| 8 | **Disciplinary action tracking** | ⚠️ Sensitive. Must confirm with Employee Relations and Privacy Act officer. Must determine access controls and retention periods. | 12o | **Consult ER + Privacy officer** |
| 9 | **Privacy Act coverage** | Confirm SORN coverage for supervisor-visible PII in the SPA. The Hub adds supervisor access to subordinate data — this may need a PIA update. | 12a | **Consult Privacy Act officer** |
| 10 | **GPC/budget/medical features** | Are any of the items in 12s relevant to this organization? | 12s | **Ask project owner** |
| 11 | **Military personnel** | Are active duty military assigned to CPSG? If yes, medical readiness (IMR) and fitness tracking may be relevant. | 12s | **Ask project owner** |

---

### Implementation Roadmap

| Phase | Tasks | Dependencies | Scope |
|-------|-------|-------------|-------|
| **Phase A: Infrastructure** | SH-01 through SH-06 | `CCSD_TimeOff` list exists, `Supervisor` role entries added | Route, gate, scope, privacy banner |
| **Phase B: Core Views** | SH-07 through SH-09 | Phase A complete | Dashboard, roster, team calendar |
| **Phase C: Action Queue** | SH-10 through SH-14 | Phase B complete | Unified queue, leave approval, training review, SF-182, in-processing |
| **Phase D: Cross-Module** | SH-15 through SH-17 | Phase C complete, Notification Framework (Section 9) for SH-17 | Navigation, reports, notifications |
| **Phase E: Should-Have** | SH-18 through SH-27 | Phase D complete, new lists created | DPMAP, manning, telework, awards, tasks |
| **Phase F: Future** | SH-28 through SH-32 | Phase E complete, policy approvals | Disciplinary, IDP, overtime, sponsorship |

**Recommended build order:** Phase A → B → C → D can be built sequentially with no new lists. Phase E requires stakeholder decisions (items 1-7 from Policy section) and new SharePoint lists. Phase F requires sensitive policy approvals (items 8-11).

---

## 13. SharePoint Lists to Create — 👤 ✅ ALL COMPLETE

> **All 76 lists and libraries have been created in SharePoint as of 2026-04-18. The instructions below are retained for reference.**

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

### Security Module Lists — See Section 11 for Full Schemas

> **The following lists are defined in Section 11 (SharePoint Lists — Data Model). Create them when ready to build the Security Module.**

- `CCSD_SecurityRecords` — 30 columns (Phase 1, Section 11)
- `CCSD_SecurityIncidents` — 46 columns (Phase 2, Section 11 / D1)
- `CCSD_IncidentStatusHistory` — 10 columns (Phase 2, D1 Entity 2)
- `CCSD_IncidentActions` — 14 columns (Phase 2, D1 Entity 3)
- `CCSD_IncidentNotifications` — 14 columns (Phase 2, D1 Entity 4)
- `CCSD_IncidentParties` — 9 columns (Phase 2, D1 Entity 5)

### Notification Framework Lists — See Section 9 for Full Schemas

> **The following lists are defined in Section 9 (Notification Framework). Create them when ready to build the notification infrastructure.**

- `CCSD_Notifications` — 19 columns (NF-01, Section 9)
- `CCSD_NotificationReceipts` — 9 columns (NF-02, Section 9)

### Supervisor Hub Lists — See Section 12 for Full Schemas

> **The following lists are defined in Section 12 (Data Dependencies). Create them only when the corresponding Should-Have feature is approved.**

- `CCSD_PerformanceTracking` — ~12 columns (SH-18, Section 12k)
- `CCSD_TeleworkAgreements` — ~8 columns (SH-22, Section 12j)
- `CCSD_Awards` — ~10 columns (SH-24, Section 12l)
- `CCSD_TaskAssignments` — ~12 columns (SH-26, Section 12n)

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

## 15. Column Additions to Existing Lists — 👤 ✅ ALL COMPLETE

> **All columns listed below have been created as of 2026-04-18. Verified by the database audit script (`database-audit-webpart.html`). This table is retained as a reference.**

| List | Column | Type | Needed For | Section |
|------|--------|------|------------|---------|
| `CCSD_HardwareAssets` | `LastAuditDate` | Date | Inventory audit | 2 |
| `CCSD_HardwareAssets` | `LastAuditBy` | Person | Inventory audit | 2 |
| `CCSD_HardwareAssets` | `WarrantyExpiration` | Date | Warranty tracking | 2 |
| `CCSD_HardwareAssets` | `PhysicalLocation` | Text | Location tracking | 2 |
| `CCSD_HardwareAssets` | `CostCenter` | Text | Cost center reporting | 2 |
| `CCSD_HardwareAssignments` | `ExpectedReturnDate` | Date | Portable check-out | 2 |
| `CCSD_SoftwareAssets` | `TotalLicenses` | Number | License utilization | 2 |
| `CCSD_SoftwareAssets` | `CostCenter` | Text | Cost center reporting | 2 |
| `CCSD_Personnel` | `SupervisorNotes` | Multiple lines of text | Supervisor notes (12d) | 12 |
| `CCSD_TimeOff` | `RequestedDate` | Date | Leave request tracking (12e) | 12 |
| `CCSD_TimeOff` | `SupervisorDecisionDate` | Date | Leave approval audit (12e) | 12 |
| `CCSD_TimeOff` | `DecisionNotes` | Multiple lines of text | Denial reason (12e) | 12 |
| `CCSD_Personnel` | `WorkScheduleType` | Choice | Work schedule type (12j) | 12 |
| `CCSD_Personnel` | `RegularDayOff` | Choice (Mon-Fri) | CWS regular day off (12j) | 12 |
| `CCSD_Personnel` | `ProbationaryStartDate` | Date | Probationary tracking (12k) | 12 |
| `CCSD_Personnel` | `ProbationaryEndDate` | Date | Probationary tracking (12k) | 12 |
| `CCSD_Personnel` | `ProbationaryStatus` | Choice | Probation status (12k) | 12 |
| `CCSD_Positions` | `PDNumber` | Text | PD currency tracking (12m) | 12 |
| `CCSD_Positions` | `PDLastReviewDate` | Date | PD currency tracking (12m) | 12 |
| `CCSD_Positions` | `PositionStatus` | Choice | Manning visibility (12m) | 12 |
| `CCSD_Positions` | `VacatedDate` | Date | Vacancy tracking (12m) | 12 |
| `CCSD_Positions` | `FillActionStatus` | Choice | Recruitment status (12m) | 12 |
| `CCSD_Personnel` | `IDPOnFile` | Yes/No | IDP tracking (12p) | 12 |
| `CCSD_Personnel` | `IDPLastUpdated` | Date | IDP tracking (12p) | 12 |
| `CCSD_InOutProcessing` | `FromLocation` | Single line of text | Prior base/unit/location (optional — currently in Notes) | 7 |
| `CCSD_InOutProcessing` | `ToLocation` | Single line of text | Gaining base/unit/location (optional — currently in Notes) | 7 |
| `CCSD_InOutProcessing` | `LosingOrgID` | Lookup → CCSD_Organizations | Org member is leaving (optional) | 7 |
| `CCSD_InOutProcessing` | `GainingOrgID` | Lookup → CCSD_Organizations | Org member is joining (optional) | 7 |

**How to add a column:**
1. Go to **Site Contents** > open the list
2. Click **+ Add column** (or go to List Settings > Create column)
3. Select the type, enter the name exactly as shown, save

---

## Priority Action Summary

### 🔴 Do First (blockers for existing features)
1. ~~**Create `CCSD_TimeOff` list**~~ — ✅ Created 2026-04-18

### 🟡 Do When Ready — Security Module (Section 11)
2. ~~**Create `CCSD_SecurityRecords` list** (30 columns)~~ — ✅ Created 2026-04-18
3. ~~**Add `Security` role entries to `CCSD_AppRoles`**~~ — ✅ Done 2026-04-18
4. **👤 Obtain sample DISS Excel export** — #1 blocker for the DISS import feature. Provide one monthly export file so column mapping can be built.
5. **👤 Verify SheetJS CDN access** from `usaf.dps.mil` — If blocked, library must be inlined (~500KB)
6. ~~**Create `CCSD_SecurityIncidents` list** (46 columns per D1)~~ — ✅ Created 2026-04-18
7. ~~**Create `CCSD_Notifications` list** (19 columns per NF-01) + **`CCSD_NotificationReceipts` list** (9 columns per NF-02)~~ — ✅ Created 2026-04-18
8. **⚖️ Consult Privacy Act officer** — Verify SORN coverage for security PII in SharePoint (Section 11 Legal/Policy item #1). Also review whether Supervisor Hub (Section 12) requires a PIA update for expanded supervisor access to subordinate data (Section 12 Policy item #9).
9. **⚖️ Consult Information Security Program Manager** — Confirm CUI marking requirements for CSV exports

### 🟡 Do When Ready — Supervisor Hub (Section 12)
10. ~~**Add `Supervisor` role entries to `CCSD_AppRoles`** (SH-01)~~ — ✅ Done 2026-04-18
11. ~~**Add leave approval columns to `CCSD_TimeOff`** (SH-02)~~ — ✅ Created 2026-04-18
12. ~~**Add `SupervisorNotes` column to `CCSD_Personnel`** (SH-03)~~ — ✅ Created 2026-04-18
13. **👤 Review 11 policy/stakeholder decisions** — Section 12 Policy & Stakeholder Validation table. Items 1-7 can be decided by project owner. Items 8-11 require Privacy/ER officer consultation.

### 🟡 Do When Ready — Other Features
14. ~~**Create `CCSD_ConferenceRooms` + `CCSD_RoomReservations`**~~ — ✅ Created 2026-04-18
15. ~~**Add audit columns** to `CCSD_HardwareAssets`~~ — ✅ Created 2026-04-18
16. **Azure AD App Registration** — Enables Outlook calendar integration (longest lead time)

### 🟢 Low Urgency (nice-to-have prerequisites)
17. ~~**Add `TotalLicenses`** to software assets~~ — ✅ Created 2026-04-18
18. ~~**Add `WarrantyExpiration`** to hardware assets~~ — ✅ Created 2026-04-18
19. ~~**Create `CCSD_Announcements`**~~ — ✅ Created 2026-04-18
20. **Set up Teams Incoming Webhook** — Enables Teams notifications
21. ~~**Create `CCSD_PerformanceTracking` list** (SH-18)~~ — ✅ Created 2026-04-18
22. ~~**Create `CCSD_TeleworkAgreements` list** (SH-22)~~ — ✅ Created 2026-04-18
23. ~~**Create `CCSD_Awards` list** (SH-24)~~ — ✅ Created 2026-04-18
24. ~~**Create `CCSD_TaskAssignments` list** (SH-26)~~ — ✅ Created 2026-04-18
