# CCSD All-Things Administrative SPA — TODO

Master task list for pending features, improvements, and technical debt.
Updated: 2026-04-02

---

## Legend

- `[ ]` Not started
- `[~]` In progress / partial
- `[x]` Complete

**Priority:** P0 = Critical, P1 = High, P2 = Medium, P3 = Nice-to-have

---

## 1. Calendar Module Enhancements

### Conference Room Scheduling (P1)
- [ ] Create `CCSD_ConferenceRooms` SharePoint list
  - Columns: Title, RoomName, FacilityID (lookup), Floor, Capacity, HasProjector, HasVTC, HasPhone, HasWhiteboard, Notes
- [ ] Create `CCSD_RoomReservations` SharePoint list
  - Columns: Title, ConferenceRoomID (lookup), ReservedBy (person), StartTime (datetime), EndTime (datetime), Subject, Notes, IsRecurring, RecurrencePattern, Status (Confirmed/Cancelled)
- [ ] Build room availability grid (Scheduling Assistant-style timeline)
- [ ] Book / cancel reservation modals
- [ ] Recurring meeting support with recurrence pattern builder
- [ ] Conflict detection — prevent double-booking
- [ ] Room search by capacity and equipment (projector, VTC, etc.)
- [ ] Room calendar view (per-room day/week timeline)
- [ ] Integration with Facilities module (link to floor plan room data)

### Microsoft Graph API — Outlook Calendar Integration (P2)
> **Requires Azure AD tenant admin actions before development can proceed.**

- [ ] **Azure AD App Registration** (tenant admin):
  1. Azure Portal > Azure Active Directory > App Registrations > "New registration"
  2. Name: "CCSD Administrative SPA"
  3. Supported accounts: "Accounts in this organizational directory only"
  4. Redirect URI (SPA type):
     - `https://usaf.dps.mil/teams/aetc-lak-cpsg/Database/SitePages/Index.aspx`
     - `https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA/SitePages/Index.aspx`
  5. API Permissions > Add:
     - Microsoft Graph > Delegated > `Calendars.Read.Shared`
     - Microsoft Graph > Delegated > `User.Read`
  6. Click "Grant admin consent for [tenant]"
  7. Copy Application (client) ID and Directory (tenant) ID
- [ ] Add MSAL.js 2.x via CDN (`<script src="https://alcdn.msauth.net/browser/2.38.0/js/msal-browser.min.js">`)
- [ ] Add `graphClientId` and `graphTenantId` config fields to APP object
- [ ] Initialize MSAL PublicClientApplication in bootstrap
- [ ] Implement silent token acquisition with interactive fallback
- [ ] Call `POST /me/calendar/getSchedule` with user emails and time window
- [ ] Render free/busy availability bars alongside time-off calendar
- [ ] Add admin config panel for Client ID / Tenant ID input
- [ ] Handle token refresh and expiration gracefully

### Calendar General Improvements (P2)
- [ ] Drag-to-create time-off entries (click + drag across days in month view)
- [ ] Multi-day entry visual spanning (bar stretching across days instead of per-day pills)
- [ ] Print-friendly calendar layout (month view CSS print stylesheet)
- [ ] Export calendar to CSV / ICS format
- [ ] Bulk import time-off entries from CSV
- [ ] Pending/denied entries visible with visual distinction (strikethrough, muted)
- [ ] Notifications for upcoming time off (7-day lookahead on Home)

---

## 2. Hardware / Software Asset Improvements

### Asset Lifecycle Management (P1)
- [x] **Edit hardware asset modal** — modify asset details (model, serial, status, network, notes) ✅ *v2026.04.02.1*
- [x] **Edit software asset modal** — modify software details (version, license type, ATO, approval status) ✅ *v2026.04.02.1*
- [x] **Unassign / return flow** — modal to unassign hardware/software with condition check (Good/Fair/Poor/Damaged/Missing) ✅ *v2026.04.02.1*
- [x] **Transfer assignment** — one-step reassign from person to person preserving chain of custody ✅ *v2026.04.02.1*
- [x] **Asset status workflow**: Available → Assigned → Returned/Transferred → Surplus → Disposed ✅ *v2026.04.02.1*
- [x] **Condition tracking**: capture condition on return (Good/Fair/Poor/Damaged/Missing) and transfer ✅ *v2026.04.02.1*
- [ ] **Depreciation / age tracking**: calculate asset age from PurchaseDate, flag items past useful life threshold

### Inventory & Audit (P1)
- [ ] **Inventory audit mode**: checklist-style walkthrough of all assets, mark each as Verified / Missing / Damaged
- [ ] **Last audit date** field on hardware assets
- [ ] **Audit history log** — who audited, when, what status was found
- [ ] **Barcode / asset tag scanning support** (camera-based scan for asset tag lookup — future, may need native)
- [ ] **Inventory discrepancy report**: assets marked as Assigned but person has departed, assets with no assignment, ghost assignments

### Software Governance (P2)
- [ ] **License utilization dashboard**: used vs total licenses per software title, highlight over-allocated
- [ ] **Software request workflow**: user requests software > supervisor approves > admin provisions > assignment created
- [ ] **ATO expiration alerts on Home dashboard**: cards for software nearing ATO expiry
- [ ] **Approved software catalog** view: browsable list of all approved titles with version, ATO status, and requestability
- [ ] **Version compliance check**: flag assignments where installed version differs from approved version
- [ ] **Cost center reporting**: total asset cost per org/cost center

### Hardware Tracking (P2)
- [ ] **Warranty tracking**: WarrantyExpiration field, flag expired warranties
- [ ] **Location tracking**: physical location beyond seat (building, floor, room, or "mobile")
- [ ] **Check-out / check-in** for portable devices (temporary assignment with expected return date)
- [x] **Asset detail page**: full view of asset with all assignments (current + historical) and properties ✅ *v2026.04.02.1*
- [ ] **Bulk asset import from CSV** (admin)

### Assignment Improvements (P2)
- [x] **Edit existing assignments** — change environment, status, notes ✅ *v2026.04.02.1*
- [ ] **Assignment history timeline**: visual timeline of who had an asset and when
- [ ] **Seat-to-asset auto-suggestion**: when assigning to a person at a seat, suggest seat-linked equipment
- [ ] **Duplicate assignment detection**: warn if same asset already assigned to someone else

---

## 3. People Module Improvements

- [ ] **Edit personnel modal** — update phone, email, org, position, supervisor, grade, notes
- [ ] **Person detail page** — unified view of person's assets, training, SF182s, time off, org chain
- [ ] **Photo / avatar support** (SharePoint profile picture integration)
- [ ] **Personnel onboarding wizard** — guided flow to create person + seat + asset assignments
- [ ] **Departure processing** — mark person departed and auto-flag open assignments, training gaps, seats for reassignment
- [ ] **Org transfer workflow** — move person between orgs with assignment/seat updates
- [ ] **Personnel export to CSV** with selected fields

---

## 4. Organization Module Improvements

- [ ] **Create / edit organization modal** (admin)
- [ ] **Org merge / restructure tool** — reassign all personnel when an org is reorganized
- [ ] **Org dashboard**: aggregate metrics per org (headcount, training compliance %, asset count, open requests)
- [ ] **Org contact card**: expanded contact info with mailing address, building/room, phone tree
- [ ] **Org chart print layout**: printable org chart with clean formatting

---

## 5. Training Module Improvements

- [ ] **Training calendar integration**: show scheduled training on the Calendar module
- [ ] **Bulk training record entry**: admin uploads completion records for multiple people at once
- [ ] **Training gap analysis per org**: which orgs have the lowest compliance rates
- [ ] **Certification expiration alerts on Home**: cards for certifications expiring in 30/60/90 days
- [ ] **Training request workflow**: person requests training > supervisor approves > SF182 auto-created if applicable

---

## 6. Requests / Workflow Improvements

- [ ] **Request comments thread UI** — rich comment display with timestamps and author
- [ ] **Email notification integration** (via Power Automate or Graph) on request status changes
- [ ] **Request dashboard for supervisors**: see all requests from their team
- [ ] **SLA compliance tracking**: visual indicator of how close requests are to SLA breach
- [ ] **Request templates**: pre-fill form based on request type selection

---

## 7. Facilities Module Improvements

- [ ] **Room booking integration** with Calendar conference room scheduling
- [ ] **Floor plan: bulk seat import from CSV** with X,Y coordinates
- [ ] **Floor plan: room boundary overlays** — draw room outlines on the floor plan
- [ ] **Multi-floor navigation**: tab or dropdown to switch between floors in a building
- [ ] **Facility capacity reporting**: occupancy % per building/floor/room

---

## 8. Home Dashboard Improvements

- [ ] **My upcoming time off** widget (personal upcoming time-off entries)
- [x] **My team's availability** widget (who's out today/this week in my section) ✅ *v2026.04.02.2*
- [x] **My pending requests** widget ✅ *v2026.04.02.2*
- [x] **My training due soon** widget ✅ *v2026.04.02.2*
- [x] **Priority Actions panel** — overdue requests, expiring training ✅ *v2026.04.02.2*
- [x] **KPI strip** — People, Requests, Training %, Assets, In/Out cases ✅ *v2026.04.02.2*
- [x] **Quick Navigation tile grid** ✅ *v2026.04.02.2*
- [x] **Notifications panel** ✅ *v2026.04.02.2*
- [x] **Admin Health Summary** (App Admin only) ✅ *v2026.04.02.2*
- [ ] **Announcements / news** banner (from a CCSD_Announcements list)
- [ ] **Quick links** section (customizable per user or org)

---

## 9. Platform / Technical Improvements

### Performance (P2)
- [ ] **Lazy module loading**: only query lists when that module is first visited
- [ ] **List data pagination**: handle lists with 5000+ items via paging tokens
- [ ] **Debounced calendar re-render**: avoid re-rendering on every keystroke in search

### UX (P2)
- [ ] **Dark/light theme toggle** (currently dark only)
- [ ] **Responsive design audit**: ensure all modules work on tablet/mobile
- [ ] **Loading skeletons**: show placeholder shapes while data loads instead of spinner text
- [ ] **Breadcrumb navigation**: show current location path in context bar
- [ ] **Undo toast actions**: "Undo" button on destructive operations (delete seat, etc.)
- [ ] **Keyboard navigation**: arrow keys to navigate calendar days, tab through tables

### Security (P1)
- [ ] **Audit all CRUD operations**: ensure every create/update/delete writes to AppAuditLog
- [ ] **Role-based field visibility**: hide sensitive fields (SSN, home phone) from non-supervisors
- [ ] **Session timeout**: auto-logout after inactivity period
- [ ] **Input sanitization review**: ensure all user input is escaped before rendering

### Data Integrity (P2)
- [ ] **Expand data quality checks**: validate all cross-list references (orphan assignments, etc.)
- [ ] **Scheduled data quality report**: auto-run checks and surface count on Home dashboard
- [ ] **Archive / soft-delete pattern**: mark records inactive instead of hard delete

---

## 10. Reporting (P3)

- [ ] **Headcount by org report** with drill-down
- [ ] **Training compliance report** by org/section with exportable PDF
- [ ] **Asset inventory report** with filters by type, status, environment, org
- [ ] **Time-off utilization report** by person/org/month
- [ ] **Request SLA compliance report**
- [ ] **Dashboard print view**: print-optimized layout for briefings
- [ ] **Scheduled report email** (via Power Automate integration)

---

## 11. SharePoint Lists to Create

| List Name | Status | Notes |
|-----------|--------|-------|
| `CCSD_TimeOff` | **Needs creation** | PersonID, OrgID, StartDate, EndDate, TimeOffType, Status, Hours, Notes, ApprovedBy, CreatedBy |
| `CCSD_ConferenceRooms` | Planned | RoomName, FacilityID, Floor, Capacity, HasProjector, HasVTC, HasPhone, HasWhiteboard |
| `CCSD_RoomReservations` | Planned | ConferenceRoomID, ReservedBy, StartTime, EndTime, Subject, IsRecurring, Status |
| `CCSD_Announcements` | Planned | Title, Body, StartDate, EndDate, Priority, Audience, IsActive |

---

## 12. External Integrations (Future)

- [ ] **Microsoft Graph API** — Outlook calendar free/busy (see Section 1 above)
- [ ] **Power Automate** — email notifications on request status, training expiry, ATO alerts
- [ ] **SharePoint Search API** — global search across all lists from a unified search bar
- [ ] **Teams integration** — post notifications to a Teams channel for critical events
- [ ] **PDF generation** — generate SF182 forms, inventory reports, org charts as PDF

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
