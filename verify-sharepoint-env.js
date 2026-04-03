// ============================================================
// CCSD Admin SPA — SharePoint Environment Column Verification
// Paste this entire script into browser console on your SP site
// ============================================================

(function() {
  var siteUrl = 'https://patriavirtus.sharepoint.com/sites/CCSDAdminSPA';

  var EXPECTED = [
    { list: 'CCSD_Organizations', columns: ['OrgID','OrgName','OrgCode','OrgType','OrgDisplayOrder','OrgEmail','IsActive','Notes','SharePointURL','OrganizationAddressNumber','OrganizationAddressBldgNumber','OrganizationAddressStreet','OrganizationAddressCity','OrganizationAddressState','OrganizationAddressZip','ParentOrgID'] },
    { list: 'CCSD_Personnel', columns: ['PersonID','LastName','FirstName','MiddleName','Suffix','Grade','Rank','Component','Category','Email','PrimaryPhone','AltPhone','OfficePhone','Status','DateArrived','DateDeparted','IsSupervisor','Notes','AFSC','Step','EducationLevel','Account','OrgID','PositionID','SeatID','SupervisorPersonID','WorkcenterID'] },
    { list: 'CCSD_Positions', columns: ['PositionID','PositionTitle','GradeBand','GradeNumber','AuthorizedCount','IsKeyLeadership','PositionLevel','DutySummary','Notes','OrgID','SupervisorPositionID'] },
    { list: 'CCSD_Facilities', columns: ['FacilityID','BuildingNumber','Base','Address','HasNIPR','HasSIPR','HasJWICS','FacilityPOC','Notes','FloorPlanUrl'] },
    { list: 'CCSD_Rooms', columns: ['RoomID','RoomNumber','Floor','RoomType','MaxSeats','IsSCIF','Notes','FloorPlanUrl','FacilityID'] },
    { list: 'CCSD_Seats', columns: ['SeatID','SeatLabel','PortNumber','PhoneNumber','HasNIPR','HasSIPR','HasJWICS','VTCEnabled','XCoord','YCoord','SeatStatus','Notes','RoomID','CurrentPersonID'] },
    { list: 'CCSD_TrainingCatalog', columns: ['TrainingCode','TrainingName','Category','FrequencyMonths','RequiredFor','CostPerPerson','IsMandatory','IsActive','Notes','TrainingLink','SF182','TrainingDutyHours','TrainingNonDutyHours','OwningOrgID','TrainingType'] },
    { list: 'CCSD_TrainingRecords', columns: ['TrainingRecordID','CompletionDate','ExpirationDate','ExpectedCompletionDate','Status','SourceSystem','CertificateURL','EnteredOn','Notes','PersonID','TrainingID','EnteredBy'] },
    { list: 'CCSD_TrainingSubmissions', columns: ['CompletionDate','ProofAttached','Status','ReviewedOn','Notes','Person','PersonID','TrainingID','Reviewer'] },
    { list: 'CCSD_TrainingCourseDataTypeCode', columns: [] },
    { list: 'CCSD_SF182TrainingRequests', columns: ['TrainingStartDate','TrainingEndDate','Status','ApprovalID','GeneratedSF182','SpecialAccommodation','RejectionComments','Requestor','Training'] },
    { list: 'CCSD_SF182Library', columns: [] },
    { list: 'CCSD_InOutProcessing', columns: ['InOutID','ProcessType','Status','Category','OpenedOn','ClosedOn','CurrentStep','Priority','Notes','CorrelationID','PersonID','OwningOrgID','RequestID'] },
    { list: 'CCSD_InOutChecklists', columns: [] },
    { list: 'CCSD_InOutStepStatus', columns: ['StepNumber','Status','DueDate','CompletedOn','OfficeNotes','MemberNotes','CorrelationID','InOutID','ChecklistID','OwningOrgID','AssignedTo','CompletedBy'] },
    { list: 'CCSD_AppRoles', columns: ['Role','IsActive','PrincipalType','Principal','ScopeType','EffectiveFrom','EffectiveTo','Notes','Member','ScopeOrgID','ScopeFacilityID','ScopeSystemID'] },
    { list: 'CCSD_AppRequests', columns: ['RequestID','RequestType','Status','Priority','SubmittedOn','DueDate','CompletedOn','Details','WorkflowStep','WorkflowJson','CorrelationID','Requester','RequestingOrgID','PersonID','SeatID','InOutID','DutyID','HardwareAssetID','SoftwareID','ChangeID','AssignedOrgID','AssignedTo'] },
    { list: 'CCSD_Workflows', columns: ['RequestType','IsActive','SlaDays','StepsJson','EscalationJson','Notes','DefaultAssignedOrgID'] },
    { list: 'CCSD_Templates', columns: [] },
    { list: 'CCSD_HowTo', columns: ['Module','Audience','Summary','Steps','Links','Tags','IsActive','DisplayOrder'] },
    { list: 'CCSD_DataQualityRules', columns: [] },
    { list: 'CCSD_HardwareAssets', columns: ['Asset ID','Asset Type','Manufacturer','Model','Serial Number','Status','Purchase Date','Purchase Cost','DeviceNameHostName','PrimaryNetworkEnvironment','Portable','AssetTagAlias','Notes','Owning Org','Default Cost Center'] },
    { list: 'CCSD_HardwareAssignments', columns: ['Assignment ID','Assigned On','Unassigned On','Status','Notes','Ticket / Reason','Correlation ID','NetworkEnvironment','AssignmentType','Hardware Asset','Person','Seat','Assigned By','ReturnedBy'] },
    { list: 'CCSD_SoftwareAssets', columns: ['Software ID','Vendor','Software Version','License Type','Total Licenses','Annual Cost','Active','Notes','ApprovalStatus','ApprovedVersion','RequiresATO','ATONumber','ATOExpiration','AllowedNetworkEnvironments','Requestable','RequiresAdministratorInstall','Owning Org','Default Cost Center','System'] },
    { list: 'CCSD_SoftwareAssignments', columns: ['Assignment ID','Assigned On','Unassigned On','Status','Notes','Ticket / Reason','Correlation ID','NetworkEnvironment','AssignmentType','ApprovalSnapshot','VersionSnapshot','ExceptionApproved','ExceptionReason','Software','Person','Seat','Assigned By'] },
    { list: 'CCSD_Systems', columns: ['System ID','System Name','Description','Criticality','Notes','Active','ATONumber','ATOStatus','ATOExpiration','AuthorizingOfficial','NetworkEnvironment','ISSMISSO','Owning Org'] },
    { list: 'CCSD_AppTelemetry', columns: ['CorrelationID','SessionID','UserDisplayName','UserEmail','UserClaims','RoleSnapshot','AppModule','Operation','DataSource','ItemID','HttpStatus','ErrorMessage','ErrorDetail','RequestUrl','RequestPayload','ResponsePayload','ElapsedMs','PageUrl','ClientInfo','IsResolved'] },
    { list: 'CCSD_AppAuditLog', columns: ['CorrelationID','AuditEvent','EntityType','ItemID','DataBefore','DataAfter','ChangedBy','ChangedOn','Reason'] },
    { list: 'CCSD_Config', columns: ['Value'] },
    { list: 'CCSD_TimeOff', columns: ['StartDate','EndDate','TimeOffType','Status','Hours','Notes','PersonID','OrgID','ApprovedBy','CreatedBy'] }
  ];

  function spFetch(url) {
    return fetch(url, {
      headers: { Accept: 'application/json;odata=verbose' },
      credentials: 'include'
    });
  }

  function checkList(entry) {
    var listName = entry.list;
    var expectedCols = entry.columns;

    return spFetch(siteUrl + "/_api/web/lists/getbytitle('" + listName + "')/fields?$filter=Hidden eq false&$select=Title,InternalName,TypeAsString&$top=500")
      .then(function(r) {
        if (!r.ok) {
          return { list: listName, exists: false, status: r.status, expected: expectedCols.length, found: 0, missing: expectedCols, extra: [], matched: [], columns: [] };
        }
        return r.json().then(function(data) {
          var fields = data.d.results;
          // Build lookup sets by both Title and InternalName (case-insensitive)
          var titleSet = {};
          var internalSet = {};
          var allNames = [];
          fields.forEach(function(f) {
            titleSet[f.Title.toLowerCase()] = f;
            internalSet[f.InternalName.toLowerCase()] = f;
            allNames.push({ title: f.Title, internal: f.InternalName, type: f.TypeAsString });
          });

          var matched = [];
          var missing = [];

          expectedCols.forEach(function(col) {
            var colLower = col.toLowerCase();
            // Try exact title match, then internal name match, then partial matches
            // Also handle SP's space-to-_x0020_ encoding
            var spEncoded = col.replace(/ /g, '_x0020_').toLowerCase();
            var noSpaces = col.replace(/ /g, '').toLowerCase();

            if (titleSet[colLower]) {
              matched.push({ expected: col, actual: titleSet[colLower].Title, internal: titleSet[colLower].InternalName, type: titleSet[colLower].TypeAsString });
            } else if (internalSet[colLower]) {
              matched.push({ expected: col, actual: internalSet[colLower].Title, internal: internalSet[colLower].InternalName, type: internalSet[colLower].TypeAsString });
            } else if (internalSet[spEncoded]) {
              matched.push({ expected: col, actual: internalSet[spEncoded].Title, internal: internalSet[spEncoded].InternalName, type: internalSet[spEncoded].TypeAsString });
            } else {
              // Fuzzy: check if any field contains the expected name (handles OData ID suffixes like "PersonIDId")
              var fuzzyMatch = null;
              fields.some(function(f) {
                var ti = f.Title.toLowerCase();
                var ii = f.InternalName.toLowerCase();
                if (ti === colLower || ii === colLower) { fuzzyMatch = f; return true; }
                if (ii === colLower + 'id' || ii === colLower.replace(/id$/, '') + 'id') { fuzzyMatch = f; return true; }
                if (ti.replace(/[^a-z0-9]/g, '') === noSpaces) { fuzzyMatch = f; return true; }
                return false;
              });
              if (fuzzyMatch) {
                matched.push({ expected: col, actual: fuzzyMatch.Title, internal: fuzzyMatch.InternalName, type: fuzzyMatch.TypeAsString });
              } else {
                missing.push(col);
              }
            }
          });

          // Find extra columns (exist on list but not in expected)
          var expectedLower = {};
          expectedCols.forEach(function(c) { expectedLower[c.toLowerCase()] = true; });
          var builtIn = ['title','id','contenttypeid','contenttype','modified','created','author','editor','_hascopydestinations','_copysource','owshiddenversion','workflowversion','_uiversion','_uiversionstring','attachments','_moderationstatus','_moderationcomments','edit','linktitlenomenu','linktitle','linktitle2','selecttitle','instanceid','order','guid','workflowinstanceid','filetype','html_x0020_file_x0020_type','filedirref','last_x0020_modified','created_x0020_date','fsobjtype','sortbehavior','permask','fileleafref','uniqueid','synclientid','progid','scopeid','html_x0020_file_x0020_type','_editmenutablestart','_editmenutablestart2','_editmenutableend','linktitlenourl','_complianceassetid','complianceassetid','bsn','_isrecord','apptitle','appauthor','appeditor'];
          var extra = [];
          allNames.forEach(function(f) {
            var tl = f.title.toLowerCase();
            var il = f.internal.toLowerCase();
            if (!expectedLower[tl] && !expectedLower[il] && builtIn.indexOf(tl) === -1 && builtIn.indexOf(il) === -1 && tl !== 'title') {
              extra.push({ title: f.title, internal: f.internal, type: f.type });
            }
          });

          return {
            list: listName,
            exists: true,
            status: 200,
            expected: expectedCols.length,
            found: matched.length,
            missing: missing,
            extra: extra,
            matched: matched,
            columns: allNames
          };
        });
      })
      .catch(function(err) {
        return { list: listName, exists: false, status: err.message, expected: expectedCols.length, found: 0, missing: expectedCols, extra: [], matched: [], columns: [] };
      });
  }

  console.log('%c CCSD Admin SPA — SharePoint Environment Verification ', 'background:#0d4f9b;color:#fff;font-size:14px;padding:8px 16px;border-radius:4px');
  console.log('%cScanning ' + EXPECTED.length + ' lists...', 'color:#5c7086;font-size:12px');

  var startTime = Date.now();

  Promise.all(EXPECTED.map(checkList)).then(function(results) {
    var elapsed = ((Date.now() - startTime) / 1000).toFixed(1);

    // ─── Summary Table ───
    console.log('\n%c ━━━ LIST SUMMARY ━━━ ', 'background:#0a2948;color:#8cc4ff;font-size:13px;padding:4px 12px');
    var summaryRows = results.map(function(r) {
      var status;
      if (!r.exists) status = '❌ MISSING';
      else if (r.missing.length === 0 && r.expected > 0) status = '✅ COMPLETE';
      else if (r.expected === 0) status = '✅ EXISTS (no columns to check)';
      else status = '⚠️ PARTIAL (' + r.missing.length + ' missing)';
      return {
        List: r.list,
        Status: status,
        'Expected Cols': r.expected,
        'Matched': r.found,
        'Missing': r.missing.length,
        'Extra': r.extra.length
      };
    });
    console.table(summaryRows);

    // ─── Missing Lists ───
    var missingLists = results.filter(function(r) { return !r.exists; });
    if (missingLists.length) {
      console.log('\n%c ❌ MISSING LISTS (' + missingLists.length + ') ', 'background:#983047;color:#fff;font-size:12px;padding:4px 12px');
      missingLists.forEach(function(r) {
        console.log('  • ' + r.list + ' (HTTP ' + r.status + ')');
      });
    }

    // ─── Per-List Column Details ───
    var listsWithIssues = results.filter(function(r) { return r.exists && r.missing.length > 0; });
    if (listsWithIssues.length) {
      console.log('\n%c ⚠️  LISTS WITH MISSING COLUMNS (' + listsWithIssues.length + ') ', 'background:#a06b04;color:#fff;font-size:12px;padding:4px 12px');
      listsWithIssues.forEach(function(r) {
        console.log('\n%c ' + r.list + ' ', 'background:#2c1800;color:#ffd88b;font-size:11px;padding:2px 8px');
        console.log('  Missing (' + r.missing.length + '): %c' + r.missing.join(', '), 'color:#ff7f92');
        if (r.matched.length) {
          console.log('  Matched (' + r.matched.length + '):');
          console.table(r.matched.map(function(m) {
            return { Expected: m.expected, 'Actual Title': m.actual, InternalName: m.internal, Type: m.type };
          }));
        }
      });
    }

    // ─── Extra Columns (informational) ───
    var listsWithExtras = results.filter(function(r) { return r.exists && r.extra.length > 0; });
    if (listsWithExtras.length) {
      console.log('\n%c ℹ️  EXTRA COLUMNS (on site but not expected by app) ', 'background:#0d4f9b;color:#c4f1ff;font-size:12px;padding:4px 12px');
      listsWithExtras.forEach(function(r) {
        console.log('\n  ' + r.list + ' (+' + r.extra.length + ' extra):');
        console.table(r.extra.map(function(e) {
          return { Title: e.title, InternalName: e.internal, Type: e.type };
        }));
      });
    }

    // ─── Perfect Lists ───
    var perfectLists = results.filter(function(r) { return r.exists && r.missing.length === 0 && r.expected > 0; });
    if (perfectLists.length) {
      console.log('\n%c ✅ FULLY MATCHED LISTS (' + perfectLists.length + '/' + results.length + ') ', 'background:#17794f;color:#fff;font-size:12px;padding:4px 12px');
      console.log('  ' + perfectLists.map(function(r) { return r.list; }).join(', '));
    }

    // ─── Final Score ───
    var totalExpected = results.reduce(function(s, r) { return s + r.expected; }, 0);
    var totalFound = results.reduce(function(s, r) { return s + r.found; }, 0);
    var totalMissing = results.reduce(function(s, r) { return s + r.missing.length; }, 0);
    var listsOk = results.filter(function(r) { return r.exists; }).length;

    console.log('\n%c ━━━ FINAL SCORE ━━━ ', 'background:#0a2948;color:#8cc4ff;font-size:13px;padding:4px 12px');
    console.log('  Lists:   %c' + listsOk + '/' + results.length + ' exist', listsOk === results.length ? 'color:#6df0b6;font-weight:bold' : 'color:#ff7f92;font-weight:bold');
    console.log('  Columns: %c' + totalFound + '/' + totalExpected + ' matched', totalMissing === 0 ? 'color:#6df0b6;font-weight:bold' : 'color:#ffc769;font-weight:bold');
    if (totalMissing > 0) {
      console.log('  Missing: %c' + totalMissing + ' columns across ' + listsWithIssues.length + ' lists', 'color:#ff7f92;font-weight:bold');
    }
    console.log('  Scanned in ' + elapsed + 's');

    if (missingLists.length === 0 && totalMissing === 0) {
      console.log('\n%c 🎉 ENVIRONMENT IS FULLY VERIFIED — All lists and columns match! ', 'background:#17794f;color:#fff;font-size:14px;padding:8px 16px;border-radius:4px');
    } else {
      console.log('\n%c ⚠️  ACTION NEEDED — See details above for missing items ', 'background:#a06b04;color:#fff;font-size:14px;padding:8px 16px;border-radius:4px');
    }

    // Return results for programmatic use
    return results;
  });
})();
