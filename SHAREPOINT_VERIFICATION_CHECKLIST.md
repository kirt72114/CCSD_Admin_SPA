# SharePoint Environment Verification Checklist

**Target Site:** https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA
**Source:** Extracted from Index.html v2026.04.03.3
**Generated:** 2026-04-03

Use this checklist to verify all 30 SharePoint lists and their columns exist on your new site.

**Quick test per list:** Go to `https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA/_api/web/lists/getbytitle('<LIST_NAME>')/fields?$filter=Hidden eq false&$select=Title,InternalName,TypeAsString` to see all columns.

---

## List Verification (30 Lists)

### 1. CCSD_Organizations
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| OrgID | Single line | — |
| OrgName | Single line | — |
| OrgCode | Single line | — |
| OrgType | Choice or Text | — |
| OrgDisplayOrder | Number | — |
| OrgEmail | Single line | — |
| IsActive | Yes/No | — |
| Notes | Multiple lines | — |
| SharePointURL | Single line / URL | — |
| OrganizationAddressNumber | Single line | — |
| OrganizationAddressBldgNumber | Single line | — |
| OrganizationAddressStreet | Single line | — |
| OrganizationAddressCity | Single line | — |
| OrganizationAddressState | Single line | — |
| OrganizationAddressZip | Single line | — |
| ParentOrgID | Lookup | → CCSD_Organizations |

---

### 2. CCSD_Personnel
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| PersonID | Single line | — |
| LastName | Single line | — |
| FirstName | Single line | — |
| MiddleName | Single line | — |
| Suffix | Single line | — |
| Grade | Single line | — |
| Rank | Single line | — |
| Component | Single line / Choice | — |
| Category | Single line / Choice | — |
| Email | Single line | — |
| PrimaryPhone | Single line | — |
| AltPhone | Single line | — |
| OfficePhone | Single line | — |
| Status | Choice | — |
| DateArrived | Date | — |
| DateDeparted | Date | — |
| IsSupervisor | Yes/No | — |
| Notes | Multiple lines | — |
| AFSC | Single line | — |
| Step | Number or Text | — |
| EducationLevel | Single line / Choice | — |
| Account | Person or Group | — |
| OrgID | Lookup | → CCSD_Organizations |
| PositionID | Lookup | → CCSD_Positions |
| SeatID | Lookup | → CCSD_Seats |
| SupervisorPersonID | Lookup | → CCSD_Personnel |
| WorkcenterID | Lookup | → (Workcenters or Orgs) |

---

### 3. CCSD_Positions
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| PositionID | Single line | — |
| PositionTitle | Single line | — |
| GradeBand | Single line | — |
| GradeNumber | Number | — |
| AuthorizedCount | Number | — |
| IsKeyLeadership | Yes/No | — |
| PositionLevel | Single line / Choice | — |
| DutySummary | Multiple lines | — |
| Notes | Multiple lines | — |
| OrgID | Lookup | → CCSD_Organizations |
| SupervisorPositionID | Lookup | → CCSD_Positions |

---

### 4. CCSD_Facilities
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| FacilityID | Single line | — |
| BuildingNumber | Single line | — |
| Base | Single line | — |
| Address | Single line | — |
| HasNIPR | Yes/No | — |
| HasSIPR | Yes/No | — |
| HasJWICS | Yes/No | — |
| FacilityPOC | Person or Group (multi) | — |
| Notes | Multiple lines | — |
| FloorPlanUrl | Single line / URL | — |

---

### 5. CCSD_Rooms
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| RoomID | Single line | — |
| RoomNumber | Single line | — |
| Floor | Number | — |
| RoomType | Choice or Text | — |
| MaxSeats | Number | — |
| IsSCIF | Yes/No | — |
| Notes | Multiple lines | — |
| FloorPlanUrl | Single line / URL | — |
| FacilityID | Lookup | → CCSD_Facilities |

---

### 6. CCSD_Seats
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| SeatID | Single line | — |
| SeatLabel | Single line | — |
| PortNumber | Single line | — |
| PhoneNumber | Single line | — |
| HasNIPR | Yes/No | — |
| HasSIPR | Yes/No | — |
| HasJWICS | Yes/No | — |
| VTCEnabled | Yes/No | — |
| XCoord | Number | — |
| YCoord | Number | — |
| SeatStatus | Choice or Text | — |
| Notes | Multiple lines | — |
| RoomID | Lookup | → CCSD_Rooms |
| CurrentPersonID | Lookup | → CCSD_Personnel |

---

### 7. CCSD_TrainingCatalog
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| TrainingCode | Single line | — |
| TrainingName | Single line | — |
| Category | Choice or Text | — |
| FrequencyMonths | Number | — |
| RequiredFor | Single line / Choice | — |
| CostPerPerson | Number / Currency | — |
| IsMandatory | Yes/No | — |
| IsActive | Yes/No | — |
| Notes | Multiple lines | — |
| TrainingLink | Single line / URL | — |
| SF182 | Yes/No or Text | — |
| TrainingDutyHours | Number | — |
| TrainingNonDutyHours | Number | — |
| OwningOrgID | Lookup | → CCSD_Organizations |
| TrainingType | Lookup | → CCSD_TrainingCourseDataTypeCode |

---

### 8. CCSD_TrainingRecords
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| TrainingRecordID | Single line | — |
| CompletionDate | Date | — |
| ExpirationDate | Date | — |
| ExpectedCompletionDate | Date | — |
| Status | Choice | — |
| SourceSystem | Single line | — |
| CertificateURL | Single line / URL | — |
| EnteredOn | Date | — |
| Notes | Multiple lines | — |
| PersonID | Lookup | → CCSD_Personnel |
| TrainingID | Lookup | → CCSD_TrainingCatalog |
| EnteredBy | Person or Group | — |

---

### 9. CCSD_TrainingSubmissions
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| CompletionDate | Date | — |
| ProofAttached | Yes/No | — |
| Status | Choice | — |
| ReviewedOn | Date | — |
| Notes | Multiple lines | — |
| Person | Person or Group | — |
| PersonID | Lookup | → CCSD_Personnel |
| TrainingID | Lookup | → CCSD_TrainingCatalog |
| Reviewer | Person or Group | — |

---

### 10. CCSD_TrainingCourseDataTypeCode
- [ ] List exists
- [ ] Columns:

| Column | Type |
|--------|------|
| Title | Single line |

> This is a reference/lookup list. The app queries it only via the TrainingType lookup from CCSD_TrainingCatalog.

---

### 11. CCSD_SF182TrainingRequests
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| TrainingStartDate | Date | — |
| TrainingEndDate | Date | — |
| Status | Choice | — |
| ApprovalID | Single line | — |
| GeneratedSF182 | Multiple lines / URL | — |
| SpecialAccommodation | Multiple lines | — |
| RejectionComments | Multiple lines | — |
| Requestor | Person or Group | — |
| Training | Lookup | → CCSD_TrainingCatalog |

---

### 12. CCSD_SF182Library
- [ ] List exists (document library or list)
- [ ] App references this list but column usage was not found in query calls — may be a document library for generated SF182 forms

---

### 13. CCSD_InOutProcessing
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| InOutID | Single line | — |
| ProcessType | Choice | — |
| Status | Choice | — |
| Category | Choice | — |
| OpenedOn | Date | — |
| ClosedOn | Date | — |
| CurrentStep | Single line | — |
| Priority | Choice | — |
| Notes | Multiple lines | — |
| CorrelationID | Single line | — |
| PersonID | Lookup | → CCSD_Personnel |
| OwningOrgID | Lookup | → CCSD_Organizations |
| RequestID | Lookup | → CCSD_AppRequests |

---

### 14. CCSD_InOutChecklists
- [ ] List exists
- [ ] App references this list. Column details depend on your production checklist structure.

---

### 15. CCSD_InOutStepStatus
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| StepNumber | Number | — |
| Status | Choice | — |
| DueDate | Date | — |
| CompletedOn | Date | — |
| OfficeNotes | Multiple lines | — |
| MemberNotes | Multiple lines | — |
| CorrelationID | Single line | — |
| InOutID | Lookup | → CCSD_InOutProcessing |
| ChecklistID | Lookup | → CCSD_InOutChecklists |
| OwningOrgID | Lookup | → CCSD_Organizations |
| AssignedTo | Person or Group | — |
| CompletedBy | Person or Group | — |

---

### 16. CCSD_AppRoles
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| Role | Choice or Text | — |
| IsActive | Yes/No | — |
| PrincipalType | Choice or Text | — |
| Principal | Single line | — |
| ScopeType | Choice or Text | — |
| EffectiveFrom | Date | — |
| EffectiveTo | Date | — |
| Notes | Multiple lines | — |
| Member | Person or Group | — |
| ScopeOrgID | Lookup | → CCSD_Organizations |
| ScopeFacilityID | Lookup | → CCSD_Facilities |
| ScopeSystemID | Lookup | → CCSD_Systems |

---

### 17. CCSD_AppRequests
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| RequestID | Single line | — |
| RequestType | Choice | — |
| Status | Choice | — |
| Priority | Choice | — |
| SubmittedOn | Date | — |
| DueDate | Date | — |
| CompletedOn | Date | — |
| Details | Multiple lines | — |
| WorkflowStep | Single line | — |
| WorkflowJson | Multiple lines | — |
| CorrelationID | Single line | — |
| Requester | Person or Group | — |
| RequestingOrgID | Lookup | → CCSD_Organizations |
| PersonID | Lookup | → CCSD_Personnel |
| SeatID | Lookup | → CCSD_Seats |
| InOutID | Lookup | → CCSD_InOutProcessing |
| DutyID | Lookup | → (Duties list) |
| HardwareAssetID | Lookup | → CCSD_HardwareAssets |
| SoftwareID | Lookup | → CCSD_SoftwareAssets |
| ChangeID | Lookup | → (Changes list) |
| AssignedOrgID | Lookup | → CCSD_Organizations |
| AssignedTo | Person or Group | — |

---

### 18. CCSD_Workflows
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| RequestType | Choice or Text | — |
| IsActive | Yes/No | — |
| SlaDays | Number | — |
| StepsJson | Multiple lines | — |
| EscalationJson | Multiple lines | — |
| Notes | Multiple lines | — |
| DefaultAssignedOrgID | Lookup | → CCSD_Organizations |

---

### 19. CCSD_Templates
- [ ] List exists
- [ ] App references this list; column usage depends on your production setup.

---

### 20. CCSD_HowTo
- [ ] List exists
- [ ] Columns:

| Column | Type |
|--------|------|
| Title | Single line |
| Module | Single line / Choice |
| Audience | Choice |
| Summary | Multiple lines |
| Steps | Multiple lines |
| Links | Multiple lines |
| Tags | Single line |
| IsActive | Yes/No |
| DisplayOrder | Number |

---

### 21. CCSD_DataQualityRules
- [ ] List exists
- [ ] App references this list; column usage depends on your production setup.

---

### 22. CCSD_HardwareAssets
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| Asset ID | Single line | — |
| Asset Type | Choice | — |
| Manufacturer | Single line | — |
| Model | Single line | — |
| Serial Number | Single line | — |
| Status | Choice | — |
| Purchase Date | Date | — |
| Purchase Cost | Currency / Number | — |
| DeviceNameHostName | Single line | — |
| PrimaryNetworkEnvironment | Choice or Text | — |
| Portable | Yes/No | — |
| AssetTagAlias | Single line | — |
| Notes | Multiple lines | — |
| Owning Org | Lookup | → CCSD_Organizations |
| Default Cost Center | Lookup | → (Cost Centers) |

> **Note:** Column display names include spaces (e.g., "Asset ID", "Asset Type", "Serial Number"). Internal names may differ. Verify internal names match.

---

### 23. CCSD_HardwareAssignments
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| Assignment ID | Single line | — |
| Assigned On | Date | — |
| Unassigned On | Date | — |
| Status | Choice | — |
| Notes | Multiple lines | — |
| Ticket / Reason | Single line | — |
| Correlation ID | Single line | — |
| NetworkEnvironment | Single line / Choice | — |
| AssignmentType | Single line / Choice | — |
| Hardware Asset | Lookup | → CCSD_HardwareAssets |
| Person | Lookup | → CCSD_Personnel |
| Seat | Lookup | → CCSD_Seats |
| Assigned By | Person or Group | — |
| ReturnedBy | Person or Group | — |

> **Note:** Columns use display names with spaces. Internal names may be `Hardware_x0020_Asset`, `Assigned_x0020_On`, etc.

---

### 24. CCSD_SoftwareAssets
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| Software ID | Single line | — |
| Vendor | Single line | — |
| Software Version | Single line | — |
| License Type | Choice | — |
| Total Licenses | Number | — |
| Annual Cost | Currency / Number | — |
| Active | Yes/No | — |
| Notes | Multiple lines | — |
| ApprovalStatus | Choice or Text | — |
| ApprovedVersion | Single line | — |
| RequiresATO | Yes/No | — |
| ATONumber | Single line | — |
| ATOExpiration | Date | — |
| AllowedNetworkEnvironments | Single line / Choice | — |
| Requestable | Yes/No | — |
| RequiresAdministratorInstall | Yes/No | — |
| Owning Org | Lookup | → CCSD_Organizations |
| Default Cost Center | Lookup | → (Cost Centers) |
| System | Lookup | → CCSD_Systems |

---

### 25. CCSD_SoftwareAssignments
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| Assignment ID | Single line | — |
| Assigned On | Date | — |
| Unassigned On | Date | — |
| Status | Choice | — |
| Notes | Multiple lines | — |
| Ticket / Reason | Single line | — |
| Correlation ID | Single line | — |
| NetworkEnvironment | Single line / Choice | — |
| AssignmentType | Single line / Choice | — |
| ApprovalSnapshot | Multiple lines | — |
| VersionSnapshot | Single line | — |
| ExceptionApproved | Yes/No | — |
| ExceptionReason | Multiple lines | — |
| Software | Lookup | → CCSD_SoftwareAssets |
| Person | Lookup | → CCSD_Personnel |
| Seat | Lookup | → CCSD_Seats |
| Assigned By | Person or Group | — |

---

### 26. CCSD_Systems
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| System ID | Single line | — |
| System Name | Single line | — |
| Description | Multiple lines | — |
| Criticality | Choice | — |
| Notes | Multiple lines | — |
| Active | Yes/No | — |
| ATONumber | Single line | — |
| ATOStatus | Choice | — |
| ATOExpiration | Date | — |
| AuthorizingOfficial | Single line | — |
| NetworkEnvironment | Choice | — |
| ISSMISSO | Single line | — |
| Owning Org | Lookup | → CCSD_Organizations |

---

### 27. CCSD_AppTelemetry
- [ ] List exists
- [ ] Columns:

| Column | Type |
|--------|------|
| CorrelationID | Single line |
| SessionID | Single line |
| UserDisplayName | Single line |
| UserEmail | Single line |
| UserClaims | Multiple lines |
| RoleSnapshot | Multiple lines |
| AppModule | Single line |
| Operation | Single line |
| DataSource | Single line |
| ItemID | Single line |
| HttpStatus | Number |
| ErrorMessage | Multiple lines |
| ErrorDetail | Multiple lines |
| RequestUrl | Multiple lines |
| RequestPayload | Multiple lines |
| ResponsePayload | Multiple lines |
| ElapsedMs | Number |
| PageUrl | Single line |
| ClientInfo | Multiple lines |
| IsResolved | Yes/No |

---

### 28. CCSD_AppAuditLog
- [ ] List exists
- [ ] Columns:

| Column | Type |
|--------|------|
| CorrelationID | Single line |
| AuditEvent | Single line |
| EntityType | Single line |
| ItemID | Single line |
| DataBefore | Multiple lines |
| DataAfter | Multiple lines |
| ChangedBy | Single line |
| ChangedOn | Date |
| Reason | Multiple lines |

---

### 29. CCSD_Config
- [ ] List exists
- [ ] App references this for configuration key/value pairs. Typically:

| Column | Type |
|--------|------|
| Title | Single line (config key) |
| Value | Multiple lines (config value) |

---

### 30. CCSD_TimeOff
- [ ] List exists
- [ ] Columns:

| Column | Type | Lookup Target |
|--------|------|---------------|
| Title | Single line | — |
| StartDate | Date | — |
| EndDate | Date | — |
| TimeOffType | Choice | — |
| Status | Choice | — |
| Hours | Number | — |
| Notes | Multiple lines | — |
| PersonID | Lookup | → CCSD_Personnel |
| OrgID | Lookup | → CCSD_Organizations |
| ApprovedBy | Person or Group | — |
| CreatedBy | Person or Group | — |

---

## Quick Verification Script

Paste this into your browser console on the SharePoint site to check which lists exist:

```javascript
var lists = [
  'CCSD_Organizations','CCSD_Personnel','CCSD_Positions','CCSD_Facilities',
  'CCSD_Rooms','CCSD_Seats','CCSD_TrainingCatalog','CCSD_TrainingRecords',
  'CCSD_TrainingSubmissions','CCSD_TrainingCourseDataTypeCode',
  'CCSD_SF182TrainingRequests','CCSD_SF182Library','CCSD_InOutProcessing',
  'CCSD_InOutChecklists','CCSD_InOutStepStatus','CCSD_AppRoles',
  'CCSD_AppRequests','CCSD_Workflows','CCSD_Templates','CCSD_HowTo',
  'CCSD_DataQualityRules','CCSD_HardwareAssets','CCSD_HardwareAssignments',
  'CCSD_SoftwareAssets','CCSD_SoftwareAssignments','CCSD_Systems',
  'CCSD_AppTelemetry','CCSD_AppAuditLog','CCSD_Config','CCSD_TimeOff'
];
Promise.all(lists.map(function(name){
  return fetch(_spPageContextInfo.webAbsoluteUrl + "/_api/web/lists/getbytitle('" + name + "')", {
    headers: { Accept: 'application/json;odata=verbose' }
  }).then(function(r){ return { name: name, exists: r.ok }; })
  .catch(function(){ return { name: name, exists: false }; });
})).then(function(results){
  console.table(results);
  var missing = results.filter(function(r){ return !r.exists; });
  if (missing.length) {
    console.warn('MISSING LISTS:', missing.map(function(r){ return r.name; }));
  } else {
    console.log('ALL 30 LISTS EXIST');
  }
});
```

## Column Verification Script (per list)

Replace `LIST_NAME` with the list to check:

```javascript
var listName = 'CCSD_Personnel'; // <-- change this
fetch(_spPageContextInfo.webAbsoluteUrl + "/_api/web/lists/getbytitle('" + listName + "')/fields?$filter=Hidden eq false&$select=Title,InternalName,TypeAsString,LookupList&$top=200", {
  headers: { Accept: 'application/json;odata=verbose' }
}).then(function(r){ return r.json(); }).then(function(d){
  var fields = d.d.results.map(function(f){
    return { Title: f.Title, InternalName: f.InternalName, Type: f.TypeAsString };
  });
  console.table(fields);
});
```
