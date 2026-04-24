# ============================================================
# CCSD Admin SPA - Add Missing SharePoint Columns
# ============================================================
# Prerequisites: Install PnP PowerShell module
#   Install-Module -Name PnP.PowerShell -Scope CurrentUser
#
# Usage:
#   .\Add-MissingColumns.ps1
#
# This script will:
#   1. Connect to your SharePoint site (interactive login)
#   2. Create CCSD_TimeOff list if it doesn't exist
#   3. Check each list for missing columns
#   4. Add only the columns that don't already exist
#   5. Report what was added
# ============================================================

$SiteUrl = "https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA"

# ─── Connect ───
Write-Host "`n=== CCSD Admin SPA - SharePoint Column Setup ===" -ForegroundColor Cyan
Write-Host "Connecting to $SiteUrl ..." -ForegroundColor Gray

try {
    Connect-PnPOnline -Url $SiteUrl -Interactive
    Write-Host "Connected successfully." -ForegroundColor Green
} catch {
    Write-Host "ERROR: Failed to connect. Make sure PnP.PowerShell is installed:" -ForegroundColor Red
    Write-Host "  Install-Module -Name PnP.PowerShell -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

# ─── Helper: Get existing field internal names for a list ───
function Get-ExistingFields {
    param([string]$ListName)
    try {
        $fields = Get-PnPField -List $ListName -ErrorAction Stop
        $set = @{}
        foreach ($f in $fields) {
            $set[$f.InternalName.ToLower()] = $f.Title
            $set[$f.Title.ToLower()] = $f.Title
        }
        return $set
    } catch {
        return $null
    }
}

# ─── Helper: Check if column exists (by internal name or title) ───
function Test-ColumnExists {
    param([hashtable]$Existing, [string]$Name)
    if ($null -eq $Existing) { return $false }
    $lower = $Name.ToLower()
    $noSpaces = ($Name -replace ' ', '').ToLower()
    $spEncoded = ($Name -replace ' ', '_x0020_').ToLower()
    return $Existing.ContainsKey($lower) -or $Existing.ContainsKey($noSpaces) -or $Existing.ContainsKey($spEncoded)
}

# ─── Helper: Add a field if it doesn't exist ───
function Add-ColumnIfMissing {
    param(
        [string]$ListName,
        [string]$ColumnName,
        [string]$FieldType,
        [hashtable]$Existing,
        [string]$LookupListName = "",
        [string[]]$Choices = @(),
        [switch]$Required,
        [switch]$MultiUser
    )

    if (Test-ColumnExists -Existing $Existing -Name $ColumnName) {
        return $false
    }

    $internalName = $ColumnName -replace '[^a-zA-Z0-9]', ''

    try {
        switch ($FieldType) {
            "Text" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Text -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Note" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Note -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Number" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Number -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Currency" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Currency -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "DateTime" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type DateTime -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Boolean" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Boolean -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Choice" {
                if ($Choices.Count -gt 0) {
                    Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Choice -Choices $Choices -AddToDefaultView -ErrorAction Stop | Out-Null
                } else {
                    Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Choice -AddToDefaultView -ErrorAction Stop | Out-Null
                }
            }
            "User" {
                if ($MultiUser) {
                    Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type User -AddToDefaultView -ErrorAction Stop | Out-Null
                    # Set to allow multiple
                    $field = Get-PnPField -List $ListName -Identity $internalName -ErrorAction SilentlyContinue
                    if ($field) {
                        $field.AllowMultipleValues = $true
                        $field.Update()
                        Invoke-PnPQuery
                    }
                } else {
                    Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type User -AddToDefaultView -ErrorAction Stop | Out-Null
                }
            }
            "URL" {
                Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type URL -AddToDefaultView -ErrorAction Stop | Out-Null
            }
            "Lookup" {
                if ($LookupListName) {
                    $lookupList = Get-PnPList -Identity $LookupListName -ErrorAction SilentlyContinue
                    if ($lookupList) {
                        Add-PnPField -List $ListName -DisplayName $ColumnName -InternalName $internalName -Type Lookup -AddToDefaultView -ErrorAction Stop | Out-Null
                        $field = Get-PnPField -List $ListName -Identity $internalName -ErrorAction SilentlyContinue
                        if ($field) {
                            $field.LookupList = $lookupList.Id.ToString("B")
                            $field.LookupField = "Title"
                            $field.Update()
                            Invoke-PnPQuery
                        }
                    } else {
                        Write-Host "    WARNING: Lookup target '$LookupListName' not found. Skipping '$ColumnName'." -ForegroundColor Yellow
                        return $false
                    }
                }
            }
        }
        Write-Host "    + Added '$ColumnName' ($FieldType)" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "    ERROR adding '$ColumnName': $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ─── Track totals ───
$totalAdded = 0
$totalSkipped = 0
$totalErrors = 0
$listsProcessed = 0

# ============================================================
# STEP 1: Create CCSD_TimeOff list if missing
# ============================================================
Write-Host "`n--- Checking CCSD_TimeOff list ---" -ForegroundColor Cyan
$timeOffList = Get-PnPList -Identity "CCSD_TimeOff" -ErrorAction SilentlyContinue
if ($null -eq $timeOffList) {
    Write-Host "  Creating CCSD_TimeOff list..." -ForegroundColor Yellow
    try {
        New-PnPList -Title "CCSD_TimeOff" -Template GenericList -ErrorAction Stop | Out-Null
        Write-Host "  Created CCSD_TimeOff list." -ForegroundColor Green
    } catch {
        Write-Host "  ERROR creating list: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "  CCSD_TimeOff already exists." -ForegroundColor Gray
}

# ============================================================
# STEP 1b: Create Additional-Duty lists + libraries if missing
# ============================================================
$dutyListsToCreate = @(
    @{ Name = "CCSD_DutyTypes";        Template = "GenericList" },
    @{ Name = "CCSD_AdditionalDuties"; Template = "GenericList" },
    @{ Name = "CCSD_DutyVacancyLog";   Template = "GenericList" },
    @{ Name = "CCSD_LetterTemplates";  Template = "DocumentLibrary" },
    @{ Name = "CCSD_Letters";          Template = "DocumentLibrary" }
)
foreach ($d in $dutyListsToCreate) {
    Write-Host "`n--- Checking $($d.Name) ---" -ForegroundColor Cyan
    $existingList = Get-PnPList -Identity $d.Name -ErrorAction SilentlyContinue
    if ($null -eq $existingList) {
        Write-Host "  Creating $($d.Name) ($($d.Template))..." -ForegroundColor Yellow
        try {
            New-PnPList -Title $d.Name -Template $d.Template -ErrorAction Stop | Out-Null
            Write-Host "  Created $($d.Name)." -ForegroundColor Green
        } catch {
            Write-Host "  ERROR creating $($d.Name): $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  $($d.Name) already exists." -ForegroundColor Gray
    }
}

# ============================================================
# STEP 2: Define all expected columns per list
# ============================================================
$ListSchemas = @(
    @{
        List = "CCSD_Organizations"
        Columns = @(
            @{ Name="OrgID"; Type="Text" },
            @{ Name="OrgName"; Type="Text" },
            @{ Name="OrgCode"; Type="Text" },
            @{ Name="OrgType"; Type="Text" },
            @{ Name="OrgDisplayOrder"; Type="Number" },
            @{ Name="OrgEmail"; Type="Text" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="SharePointURL"; Type="URL" },
            @{ Name="OrganizationAddressNumber"; Type="Text" },
            @{ Name="OrganizationAddressBldgNumber"; Type="Text" },
            @{ Name="OrganizationAddressStreet"; Type="Text" },
            @{ Name="OrganizationAddressCity"; Type="Text" },
            @{ Name="OrganizationAddressState"; Type="Text" },
            @{ Name="OrganizationAddressZip"; Type="Text" },
            @{ Name="ParentOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" }
        )
    },
    @{
        List = "CCSD_Personnel"
        Columns = @(
            @{ Name="PersonID"; Type="Text" },
            @{ Name="LastName"; Type="Text" },
            @{ Name="FirstName"; Type="Text" },
            @{ Name="MiddleName"; Type="Text" },
            @{ Name="Suffix"; Type="Text" },
            @{ Name="Grade"; Type="Text" },
            @{ Name="Rank"; Type="Text" },
            @{ Name="Component"; Type="Text" },
            @{ Name="Category"; Type="Text" },
            @{ Name="Email"; Type="Text" },
            @{ Name="PrimaryPhone"; Type="Text" },
            @{ Name="AltPhone"; Type="Text" },
            @{ Name="OfficePhone"; Type="Text" },
            @{ Name="Status"; Type="Choice"; Choices=@("Active","Departed","TDY","Leave","Deployed") },
            @{ Name="DateArrived"; Type="DateTime" },
            @{ Name="DateDeparted"; Type="DateTime" },
            @{ Name="IsSupervisor"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="AFSC"; Type="Text" },
            @{ Name="Step"; Type="Text" },
            @{ Name="EducationLevel"; Type="Text" },
            @{ Name="Account"; Type="User" },
            @{ Name="OrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="PositionID"; Type="Lookup"; LookupList="CCSD_Positions" },
            @{ Name="SeatID"; Type="Lookup"; LookupList="CCSD_Seats" },
            @{ Name="SupervisorPersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="WorkcenterID"; Type="Lookup"; LookupList="CCSD_Organizations" }
        )
    },
    @{
        List = "CCSD_Positions"
        Columns = @(
            @{ Name="PositionID"; Type="Text" },
            @{ Name="PositionTitle"; Type="Text" },
            @{ Name="GradeBand"; Type="Text" },
            @{ Name="GradeNumber"; Type="Number" },
            @{ Name="AuthorizedCount"; Type="Number" },
            @{ Name="IsKeyLeadership"; Type="Boolean" },
            @{ Name="PositionLevel"; Type="Text" },
            @{ Name="DutySummary"; Type="Note" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="OrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="SupervisorPositionID"; Type="Lookup"; LookupList="CCSD_Positions" }
        )
    },
    @{
        List = "CCSD_Facilities"
        Columns = @(
            @{ Name="FacilityID"; Type="Text" },
            @{ Name="BuildingNumber"; Type="Text" },
            @{ Name="Base"; Type="Text" },
            @{ Name="Address"; Type="Text" },
            @{ Name="HasNIPR"; Type="Boolean" },
            @{ Name="HasSIPR"; Type="Boolean" },
            @{ Name="HasJWICS"; Type="Boolean" },
            @{ Name="FacilityPOC"; Type="User"; MultiUser=$true },
            @{ Name="Notes"; Type="Note" },
            @{ Name="FloorPlanUrl"; Type="URL" }
        )
    },
    @{
        List = "CCSD_Rooms"
        Columns = @(
            @{ Name="RoomID"; Type="Text" },
            @{ Name="RoomNumber"; Type="Text" },
            @{ Name="Floor"; Type="Number" },
            @{ Name="RoomType"; Type="Text" },
            @{ Name="MaxSeats"; Type="Number" },
            @{ Name="IsSCIF"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="FloorPlanUrl"; Type="URL" },
            @{ Name="FacilityID"; Type="Lookup"; LookupList="CCSD_Facilities" }
        )
    },
    @{
        List = "CCSD_Seats"
        Columns = @(
            @{ Name="SeatID"; Type="Text" },
            @{ Name="SeatLabel"; Type="Text" },
            @{ Name="PortNumber"; Type="Text" },
            @{ Name="PhoneNumber"; Type="Text" },
            @{ Name="HasNIPR"; Type="Boolean" },
            @{ Name="HasSIPR"; Type="Boolean" },
            @{ Name="HasJWICS"; Type="Boolean" },
            @{ Name="VTCEnabled"; Type="Boolean" },
            @{ Name="XCoord"; Type="Number" },
            @{ Name="YCoord"; Type="Number" },
            @{ Name="SeatStatus"; Type="Text" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="RoomID"; Type="Lookup"; LookupList="CCSD_Rooms" },
            @{ Name="CurrentPersonID"; Type="Lookup"; LookupList="CCSD_Personnel" }
        )
    },
    @{
        List = "CCSD_TrainingCatalog"
        Columns = @(
            @{ Name="TrainingCode"; Type="Text" },
            @{ Name="TrainingName"; Type="Text" },
            @{ Name="Category"; Type="Text" },
            @{ Name="FrequencyMonths"; Type="Number" },
            @{ Name="RequiredFor"; Type="Text" },
            @{ Name="CostPerPerson"; Type="Currency" },
            @{ Name="IsMandatory"; Type="Boolean" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="TrainingLink"; Type="URL" },
            @{ Name="SF182"; Type="Boolean" },
            @{ Name="TrainingDutyHours"; Type="Number" },
            @{ Name="TrainingNonDutyHours"; Type="Number" },
            @{ Name="OwningOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="TrainingType"; Type="Lookup"; LookupList="CCSD_TrainingCourseDataTypeCode" }
        )
    },
    @{
        List = "CCSD_TrainingRecords"
        Columns = @(
            @{ Name="TrainingRecordID"; Type="Text" },
            @{ Name="CompletionDate"; Type="DateTime" },
            @{ Name="ExpirationDate"; Type="DateTime" },
            @{ Name="ExpectedCompletionDate"; Type="DateTime" },
            @{ Name="Status"; Type="Choice"; Choices=@("Active","Expired","Pending Review","Revoked") },
            @{ Name="SourceSystem"; Type="Text" },
            @{ Name="CertificateURL"; Type="URL" },
            @{ Name="EnteredOn"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="TrainingID"; Type="Lookup"; LookupList="CCSD_TrainingCatalog" },
            @{ Name="EnteredBy"; Type="User" }
        )
    },
    @{
        List = "CCSD_TrainingSubmissions"
        Columns = @(
            @{ Name="CompletionDate"; Type="DateTime" },
            @{ Name="ProofAttached"; Type="Boolean" },
            @{ Name="Status"; Type="Choice"; Choices=@("Pending Review","Approved","Rejected") },
            @{ Name="ReviewedOn"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Person"; Type="User" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="TrainingID"; Type="Lookup"; LookupList="CCSD_TrainingCatalog" },
            @{ Name="Reviewer"; Type="User" }
        )
    },
    @{
        List = "CCSD_SF182TrainingRequests"
        Columns = @(
            @{ Name="TrainingStartDate"; Type="DateTime" },
            @{ Name="TrainingEndDate"; Type="DateTime" },
            @{ Name="Status"; Type="Choice"; Choices=@("Draft","Submitted","Approved","Rejected","Completed") },
            @{ Name="ApprovalID"; Type="Text" },
            @{ Name="GeneratedSF182"; Type="Note" },
            @{ Name="SpecialAccommodation"; Type="Note" },
            @{ Name="RejectionComments"; Type="Note" },
            @{ Name="Requestor"; Type="User" },
            @{ Name="Training"; Type="Lookup"; LookupList="CCSD_TrainingCatalog" }
        )
    },
    @{
        List = "CCSD_InOutProcessing"
        Columns = @(
            @{ Name="InOutID"; Type="Text" },
            @{ Name="ProcessType"; Type="Choice"; Choices=@("In-Processing","Out-Processing","Transfer") },
            @{ Name="Status"; Type="Choice"; Choices=@("Open","In Progress","On Hold","Closed","Completed") },
            @{ Name="Category"; Type="Choice"; Choices=@("Military","Civilian","Contractor","NAF","Intern","Volunteer") },
            @{ Name="OpenedOn"; Type="DateTime" },
            @{ Name="ClosedOn"; Type="DateTime" },
            @{ Name="CurrentStep"; Type="Text" },
            @{ Name="Priority"; Type="Choice"; Choices=@("Routine","High","Urgent") },
            @{ Name="Notes"; Type="Note" },
            @{ Name="CorrelationID"; Type="Text" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="OwningOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="RequestID"; Type="Lookup"; LookupList="CCSD_AppRequests" }
        )
    },
    @{
        List = "CCSD_InOutStepStatus"
        Columns = @(
            @{ Name="StepNumber"; Type="Number" },
            @{ Name="Status"; Type="Choice"; Choices=@("Open","In Progress","Completed","Skipped") },
            @{ Name="DueDate"; Type="DateTime" },
            @{ Name="CompletedOn"; Type="DateTime" },
            @{ Name="OfficeNotes"; Type="Note" },
            @{ Name="MemberNotes"; Type="Note" },
            @{ Name="CorrelationID"; Type="Text" },
            @{ Name="InOutID"; Type="Lookup"; LookupList="CCSD_InOutProcessing" },
            @{ Name="ChecklistID"; Type="Lookup"; LookupList="CCSD_InOutChecklists" },
            @{ Name="OwningOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="AssignedTo"; Type="User" },
            @{ Name="CompletedBy"; Type="User" }
        )
    },
    @{
        List = "CCSD_AppRoles"
        Columns = @(
            @{ Name="Role"; Type="Text" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="PrincipalType"; Type="Text" },
            @{ Name="Principal"; Type="Text" },
            @{ Name="ScopeType"; Type="Text" },
            @{ Name="EffectiveFrom"; Type="DateTime" },
            @{ Name="EffectiveTo"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Member"; Type="User" },
            @{ Name="ScopeOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="ScopeFacilityID"; Type="Lookup"; LookupList="CCSD_Facilities" },
            @{ Name="ScopeSystemID"; Type="Lookup"; LookupList="CCSD_Systems" }
        )
    },
    @{
        List = "CCSD_AppRequests"
        Columns = @(
            @{ Name="RequestID"; Type="Text" },
            @{ Name="RequestType"; Type="Choice"; Choices=@("Administrative","Training","SF182","Facilities","IT","Security","HR","Hardware","Software") },
            @{ Name="Status"; Type="Choice"; Choices=@("Submitted","In Progress","On Hold","Completed","Closed","Cancelled") },
            @{ Name="Priority"; Type="Choice"; Choices=@("Routine","High","Urgent") },
            @{ Name="SubmittedOn"; Type="DateTime" },
            @{ Name="DueDate"; Type="DateTime" },
            @{ Name="CompletedOn"; Type="DateTime" },
            @{ Name="Details"; Type="Note" },
            @{ Name="WorkflowStep"; Type="Text" },
            @{ Name="WorkflowJson"; Type="Note" },
            @{ Name="CorrelationID"; Type="Text" },
            @{ Name="Requester"; Type="User" },
            @{ Name="RequestingOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="SeatID"; Type="Lookup"; LookupList="CCSD_Seats" },
            @{ Name="InOutID"; Type="Lookup"; LookupList="CCSD_InOutProcessing" },
            @{ Name="DutyID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="HardwareAssetID"; Type="Lookup"; LookupList="CCSD_HardwareAssets" },
            @{ Name="SoftwareID"; Type="Lookup"; LookupList="CCSD_SoftwareAssets" },
            @{ Name="ChangeID"; Type="Lookup"; LookupList="CCSD_AppRequests" },
            @{ Name="AssignedOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="AssignedTo"; Type="User" }
        )
    },
    @{
        List = "CCSD_Workflows"
        Columns = @(
            @{ Name="RequestType"; Type="Text" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="SlaDays"; Type="Number" },
            @{ Name="StepsJson"; Type="Note" },
            @{ Name="EscalationJson"; Type="Note" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="DefaultAssignedOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" }
        )
    },
    @{
        List = "CCSD_HowTo"
        Columns = @(
            @{ Name="Module"; Type="Text" },
            @{ Name="Audience"; Type="Choice"; Choices=@("All","Admin","Supervisors","Members") },
            @{ Name="Summary"; Type="Note" },
            @{ Name="Steps"; Type="Note" },
            @{ Name="Links"; Type="Note" },
            @{ Name="Tags"; Type="Text" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="DisplayOrder"; Type="Number" }
        )
    },
    @{
        List = "CCSD_HardwareAssets"
        Columns = @(
            @{ Name="Asset ID"; Type="Text" },
            @{ Name="Asset Type"; Type="Choice"; Choices=@("Laptop","Desktop","Monitor","Keyboard","Mouse","Docking Station","Printer","Phone","Tablet","Other") },
            @{ Name="Manufacturer"; Type="Text" },
            @{ Name="Model"; Type="Text" },
            @{ Name="Serial Number"; Type="Text" },
            @{ Name="Status"; Type="Choice"; Choices=@("Active","Surplus","In Repair","Lost","Disposed") },
            @{ Name="Purchase Date"; Type="DateTime" },
            @{ Name="Purchase Cost"; Type="Currency" },
            @{ Name="DeviceNameHostName"; Type="Text" },
            @{ Name="PrimaryNetworkEnvironment"; Type="Text" },
            @{ Name="Portable"; Type="Boolean" },
            @{ Name="AssetTagAlias"; Type="Text" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Owning Org"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="Default Cost Center"; Type="Lookup"; LookupList="CCSD_Organizations" }
        )
    },
    @{
        List = "CCSD_HardwareAssignments"
        Columns = @(
            @{ Name="Assignment ID"; Type="Text" },
            @{ Name="Assigned On"; Type="DateTime" },
            @{ Name="Unassigned On"; Type="DateTime" },
            @{ Name="Status"; Type="Choice"; Choices=@("Active","Returned","Transferred","Lost") },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Ticket / Reason"; Type="Text" },
            @{ Name="Correlation ID"; Type="Text" },
            @{ Name="NetworkEnvironment"; Type="Text" },
            @{ Name="AssignmentType"; Type="Text" },
            @{ Name="Hardware Asset"; Type="Lookup"; LookupList="CCSD_HardwareAssets" },
            @{ Name="Person"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="Seat"; Type="Lookup"; LookupList="CCSD_Seats" },
            @{ Name="Assigned By"; Type="User" },
            @{ Name="ReturnedBy"; Type="User" }
        )
    },
    @{
        List = "CCSD_SoftwareAssets"
        Columns = @(
            @{ Name="Software ID"; Type="Text" },
            @{ Name="Vendor"; Type="Text" },
            @{ Name="Software Version"; Type="Text" },
            @{ Name="License Type"; Type="Choice"; Choices=@("Per User","Per Device","Site","Enterprise","Open Source","Freeware") },
            @{ Name="Total Licenses"; Type="Number" },
            @{ Name="Annual Cost"; Type="Currency" },
            @{ Name="Active"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="ApprovalStatus"; Type="Text" },
            @{ Name="ApprovedVersion"; Type="Text" },
            @{ Name="RequiresATO"; Type="Boolean" },
            @{ Name="ATONumber"; Type="Text" },
            @{ Name="ATOExpiration"; Type="DateTime" },
            @{ Name="AllowedNetworkEnvironments"; Type="Text" },
            @{ Name="Requestable"; Type="Boolean" },
            @{ Name="RequiresAdministratorInstall"; Type="Boolean" },
            @{ Name="Owning Org"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="Default Cost Center"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="System"; Type="Lookup"; LookupList="CCSD_Systems" }
        )
    },
    @{
        List = "CCSD_SoftwareAssignments"
        Columns = @(
            @{ Name="Assignment ID"; Type="Text" },
            @{ Name="Assigned On"; Type="DateTime" },
            @{ Name="Unassigned On"; Type="DateTime" },
            @{ Name="Status"; Type="Choice"; Choices=@("Active","Removed","Transferred") },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Ticket / Reason"; Type="Text" },
            @{ Name="Correlation ID"; Type="Text" },
            @{ Name="NetworkEnvironment"; Type="Text" },
            @{ Name="AssignmentType"; Type="Text" },
            @{ Name="ApprovalSnapshot"; Type="Note" },
            @{ Name="VersionSnapshot"; Type="Text" },
            @{ Name="ExceptionApproved"; Type="Boolean" },
            @{ Name="ExceptionReason"; Type="Note" },
            @{ Name="Software"; Type="Lookup"; LookupList="CCSD_SoftwareAssets" },
            @{ Name="Person"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="Seat"; Type="Lookup"; LookupList="CCSD_Seats" },
            @{ Name="Assigned By"; Type="User" }
        )
    },
    @{
        List = "CCSD_Systems"
        Columns = @(
            @{ Name="System ID"; Type="Text" },
            @{ Name="System Name"; Type="Text" },
            @{ Name="Description"; Type="Note" },
            @{ Name="Criticality"; Type="Choice"; Choices=@("Low","Medium","High","Critical") },
            @{ Name="Notes"; Type="Note" },
            @{ Name="Active"; Type="Boolean" },
            @{ Name="ATONumber"; Type="Text" },
            @{ Name="ATOStatus"; Type="Choice"; Choices=@("Active","Expired","Pending","Revoked") },
            @{ Name="ATOExpiration"; Type="DateTime" },
            @{ Name="AuthorizingOfficial"; Type="Text" },
            @{ Name="NetworkEnvironment"; Type="Choice"; Choices=@("NIPR","SIPR","JWICS","Standalone") },
            @{ Name="ISSMISSO"; Type="Text" },
            @{ Name="Owning Org"; Type="Lookup"; LookupList="CCSD_Organizations" }
        )
    },
    @{
        List = "CCSD_AppTelemetry"
        Columns = @(
            @{ Name="CorrelationID"; Type="Text" },
            @{ Name="SessionID"; Type="Text" },
            @{ Name="UserDisplayName"; Type="Text" },
            @{ Name="UserEmail"; Type="Text" },
            @{ Name="UserClaims"; Type="Note" },
            @{ Name="RoleSnapshot"; Type="Note" },
            @{ Name="AppModule"; Type="Text" },
            @{ Name="Operation"; Type="Text" },
            @{ Name="DataSource"; Type="Text" },
            @{ Name="ItemID"; Type="Text" },
            @{ Name="HttpStatus"; Type="Number" },
            @{ Name="ErrorMessage"; Type="Note" },
            @{ Name="ErrorDetail"; Type="Note" },
            @{ Name="RequestUrl"; Type="Note" },
            @{ Name="RequestPayload"; Type="Note" },
            @{ Name="ResponsePayload"; Type="Note" },
            @{ Name="ElapsedMs"; Type="Number" },
            @{ Name="PageUrl"; Type="Text" },
            @{ Name="ClientInfo"; Type="Note" },
            @{ Name="IsResolved"; Type="Boolean" }
        )
    },
    @{
        List = "CCSD_AppAuditLog"
        Columns = @(
            @{ Name="CorrelationID"; Type="Text" },
            @{ Name="AuditEvent"; Type="Text" },
            @{ Name="EntityType"; Type="Text" },
            @{ Name="ItemID"; Type="Text" },
            @{ Name="DataBefore"; Type="Note" },
            @{ Name="DataAfter"; Type="Note" },
            @{ Name="ChangedBy"; Type="Text" },
            @{ Name="ChangedOn"; Type="DateTime" },
            @{ Name="Reason"; Type="Note" }
        )
    },
    @{
        List = "CCSD_Config"
        Columns = @(
            @{ Name="Value"; Type="Note" }
        )
    },
    @{
        List = "CCSD_TimeOff"
        Columns = @(
            @{ Name="StartDate"; Type="DateTime" },
            @{ Name="EndDate"; Type="DateTime" },
            @{ Name="TimeOffType"; Type="Choice"; Choices=@("Annual Leave","Sick Leave","TDY","Training","Comp Time","Telework","LWOP","Other") },
            @{ Name="Status"; Type="Choice"; Choices=@("Approved","Pending","Denied","Cancelled") },
            @{ Name="Hours"; Type="Number" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="OrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="ApprovedBy"; Type="User" },
            @{ Name="CreatedBy"; Type="User" }
        )
    },
    @{
        List = "CCSD_DutyTypes"
        Columns = @(
            @{ Name="DutyTypeID"; Type="Text" },
            @{ Name="Description"; Type="Note" },
            @{ Name="TemplateName"; Type="Text" },
            @{ Name="RequiredTraining"; Type="Note" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="DefaultSignerRole"; Type="Choice"; Choices=@("Supervisor","OrgLead","AppAdmin","NotificationPOC","Custom") },
            @{ Name="GrantsAdminRole"; Type="Boolean" },
            @{ Name="DefaultOrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="DefaultNotificationPOC"; Type="User" },
            @{ Name="DefaultSignerPerson"; Type="User" }
        )
    },
    @{
        List = "CCSD_AdditionalDuties"
        Columns = @(
            @{ Name="DutyID"; Type="Text" },
            @{ Name="AppointmentStartDate"; Type="DateTime" },
            @{ Name="AppointmentEndDate"; Type="DateTime" },
            @{ Name="Status"; Type="Choice"; Choices=@("Pending","Active","Vacant","Suspended","Closed") },
            @{ Name="AppointmentLetterURL"; Type="URL" },
            @{ Name="LastNotifiedOn"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="DutyTypeID"; Type="Lookup"; LookupList="CCSD_DutyTypes" },
            @{ Name="OrgID"; Type="Lookup"; LookupList="CCSD_Organizations" },
            @{ Name="NotificationPOC"; Type="User" }
        )
    },
    @{
        List = "CCSD_DutyVacancyLog"
        Columns = @(
            @{ Name="LogID"; Type="Text" },
            @{ Name="DateVacant"; Type="DateTime" },
            @{ Name="NotificationDate"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="DutyID"; Type="Lookup"; LookupList="CCSD_AdditionalDuties" },
            @{ Name="PreviousPersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="NotifiedTo"; Type="User" }
        )
    },
    @{
        List = "CCSD_LetterTemplates"
        Columns = @(
            @{ Name="TemplateID"; Type="Text" },
            @{ Name="TemplateType"; Type="Choice"; Choices=@("Appointment Letter","Additional Duty Letter","Revocation Letter","Delegation Letter","Memorandum","Other") },
            @{ Name="VersionNumber"; Type="Number" },
            @{ Name="IsActive"; Type="Boolean" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="DutyTypeID"; Type="Lookup"; LookupList="CCSD_DutyTypes" }
        )
    },
    @{
        List = "CCSD_Letters"
        Columns = @(
            @{ Name="LetterType"; Type="Choice"; Choices=@("Appointment","Reappointment","Revocation","Temporary Assignment","Other") },
            @{ Name="GeneratedOn"; Type="DateTime" },
            @{ Name="Notes"; Type="Note" },
            @{ Name="PersonID"; Type="Lookup"; LookupList="CCSD_Personnel" },
            @{ Name="DutyTypeID"; Type="Lookup"; LookupList="CCSD_DutyTypes" },
            @{ Name="RelatedDutyID"; Type="Lookup"; LookupList="CCSD_AdditionalDuties" },
            @{ Name="GeneratedBy"; Type="User" }
        )
    }
)

# ============================================================
# STEP 3: Process each list
# ============================================================
Write-Host "`n=== Processing $($ListSchemas.Count) lists ===" -ForegroundColor Cyan

foreach ($schema in $ListSchemas) {
    $listName = $schema.List
    $listsProcessed++

    # Check if list exists
    $list = Get-PnPList -Identity $listName -ErrorAction SilentlyContinue
    if ($null -eq $list) {
        Write-Host "`n[$listsProcessed/$($ListSchemas.Count)] $listName - SKIPPED (list does not exist)" -ForegroundColor Yellow
        continue
    }

    $existing = Get-ExistingFields -ListName $listName
    $addedCount = 0
    $skipCount = 0

    Write-Host "`n[$listsProcessed/$($ListSchemas.Count)] $listName" -ForegroundColor White

    foreach ($col in $schema.Columns) {
        $params = @{
            ListName = $listName
            ColumnName = $col.Name
            FieldType = $col.Type
            Existing = $existing
        }

        if ($col.LookupList) { $params.LookupListName = $col.LookupList }
        if ($col.Choices) { $params.Choices = $col.Choices }
        if ($col.MultiUser) { $params.MultiUser = $true }

        $added = Add-ColumnIfMissing @params
        if ($added) {
            $addedCount++
            $totalAdded++
        } else {
            $skipCount++
            $totalSkipped++
        }
    }

    if ($addedCount -eq 0) {
        Write-Host "  All $($schema.Columns.Count) columns already exist." -ForegroundColor Gray
    } else {
        Write-Host "  Added $addedCount, skipped $skipCount (already existed)." -ForegroundColor Cyan
    }
}

# ============================================================
# STEP 4: Summary
# ============================================================
Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Lists processed: $listsProcessed" -ForegroundColor White
Write-Host "  Columns added:   $totalAdded" -ForegroundColor $(if ($totalAdded -gt 0) { "Green" } else { "Gray" })
Write-Host "  Already existed: $totalSkipped" -ForegroundColor Gray
Write-Host "============================================" -ForegroundColor Cyan

if ($totalAdded -eq 0) {
    Write-Host "`n  All columns already exist. Environment is complete!" -ForegroundColor Green
} else {
    Write-Host "`n  $totalAdded columns were added. Run the browser verification" -ForegroundColor Yellow
    Write-Host "  script again to confirm everything matches." -ForegroundColor Yellow
}

Write-Host "`nDone. Disconnecting..." -ForegroundColor Gray
Disconnect-PnPOnline -ErrorAction SilentlyContinue
