# Security Module — Research Summary & Regulatory Foundation

This document summarizes research conducted across 9 security domains to inform the CCSD Admin SPA Security Module implementation plan. All findings are classified as **Confirmed Regulatory Requirement** or **Common Practice / Best Practice**.

---

## Sources Consulted

| Source | Scope | Authority Level |
|--------|-------|-----------------|
| **SEAD 3** (DNI, June 2017) | Reporting requirements for cleared personnel | Binding executive directive |
| **SEAD 4** (DNI, June 2017) | National Security Adjudicative Guidelines (13 guidelines) | Binding executive directive |
| **SEAD 6** (DNI) | Continuous Evaluation / Continuous Vetting | Binding executive directive |
| **EO 12968** (as amended) | Access to Classified Information; due process rights | Executive order |
| **EO 13526** | Classified National Security Information | Executive order |
| **EO 13556** | Controlled Unclassified Information | Executive order |
| **EO 13587** | Insider Threat Programs | Executive order |
| **DoDM 5200.01** (Vols 1-4) | DoD Information Security Program | DoD manual (regulatory) |
| **DoDM 5200.02** (Vols 1-3) | DoD Personnel Security Program | DoD manual (regulatory) |
| **DoDI 5200.48** | Controlled Unclassified Information | DoD instruction (regulatory) |
| **DoDI 5240.06** | Counterintelligence Awareness and Reporting (CIAR) | DoD instruction (regulatory) |
| **DoDM 5205.02** | DoD Operations Security Program Manual | DoD manual (regulatory) |
| **DoDM 5220.22 / 32 CFR 117** | NISPOM (Industrial Security) | DoD manual / federal regulation |
| **AFI 16-1404** | Air Force Information Security Program | AF instruction (regulatory) |
| **AFI 16-1406** | Air Force Personnel Security | AF instruction (regulatory) |
| **AFMAN 16-1405** | Air Force Information Security Program Management | AF manual (regulatory) |
| **AFI 10-701** | Operations Security | AF instruction (regulatory) |
| **ICD 704** | SCI eligibility and access | IC directive (regulatory) |
| **Privacy Act of 1974** (5 USC 552a) | PII protections and System of Records requirements | Federal statute |

---

## Key Findings by Domain

### 1. SEAD 3 — Reportable Events (15 Categories)

SEAD 3 defines **15 categories** of events that cleared personnel must self-report. Supervisors have an independent, concurrent reporting obligation. Reporting timelines range from immediate (espionage, unauthorized disclosure) to 30 days (financial issues, status changes).

**Categories confirmed from the directive:**
1. Foreign Travel
2. Foreign Contacts
3. Foreign Activities and Interests
4. Financial Issues
5. Criminal Conduct and Legal Issues
6. Illegal Substances / Substance Abuse
7. Alcohol-Related Events
8. Mental Health and Emotional Conditions (narrow scope — voluntary counseling for combat, sexual assault, domestic violence, or grief is explicitly NOT reportable)
9. Unauthorized Disclosure of Classified Information
10. Security Violations and Infractions
11. Change in Personal Status
12. Association or Membership
13. Technology and Cyber
14. Attempts to Subvert the Adjudicative Process
15. Outside Activities / Employment

**Critical design implication:** The incident category dropdown in the SPA must align with these 15 categories. The mental health carve-out (Category 8) must be reflected in UI guidance to avoid chilling effects on help-seeking behavior.

**Reporting obligation structure:** Self-reporting by the individual does NOT relieve the supervisor of reporting, and vice versa. All parties who become aware of reportable information must report through appropriate channels.

### 2. SEAD 4 — Adjudicative Guidelines (13 Guidelines)

SEAD 4 defines **13 adjudicative guidelines** used to evaluate reported information:

| ID | Guideline | Maps to SEAD 3 Categories |
|----|-----------|---------------------------|
| A | Allegiance to the United States | 12, 14 |
| B | Foreign Influence | 1, 2, 3 |
| C | Foreign Preference | 3 |
| D | Sexual Behavior | 5 |
| E | Personal Conduct | 5, 11, 14 |
| F | Financial Considerations | 4 |
| G | Alcohol Consumption | 7 |
| H | Drug Involvement and Substance Misuse | 6 |
| I | Psychological Conditions | 8 |
| J | Criminal Conduct | 5 |
| K | Handling Protected Information | 9, 10 |
| L | Outside Activities | 15 |
| M | Use of Information Technology | 13 |

Each guideline has specific **Disqualifying Conditions (DCs)** and **Mitigating Conditions (MCs)**. Adjudication applies the **whole-person concept** (9 factors including recency, severity, rehabilitation, coercion potential).

**Clearance standard:** "Any doubt concerning personnel being considered for national security eligibility will be resolved in favor of the national security."

### 3. Investigation Tiers & Clearance Levels

| Clearance Level | Investigation Tier | Legacy PR Cycle | Under TW 2.0 |
|----------------|-------------------|-----------------|---------------|
| Confidential | T3 | 15 years | CV replaces PR |
| Secret | T3 | 10 years | CV replaces PR |
| Top Secret | T5 | 5 years | CV replaces PR |
| TS/SCI | T5 + SCI adjudication | 5 years | CV replaces PR |

**Key distinction:** SCI and SAP are **access determinations**, not clearance levels. A person holds TS clearance and may or may not have SCI access based on need-to-know. The SPA correctly separates `ClearanceLevel` from access booleans.

**Trusted Workforce 2.0 status:** CV is actively replacing periodic reinvestigations but the transition is phased and not complete for all populations. The SPA should support both legacy PR tracking and CV enrollment status during the transition.

### 4. Security Training Requirements (6 Mandatory Types)

| Training | Frequency | Governing Directive | Cycle |
|----------|-----------|-------------------|-------|
| Initial Security Briefing | Before access to classified | DoDM 5200.01, Encl 5 | One-time |
| Annual Security Refresher | Every 12 months | DoDM 5200.01, Encl 5 | Annual |
| Derivative Classification | Every 2 years | EO 13526, Sec 2.1(d) | Biennial |
| CI Awareness | Every 12 months | DoDI 5240.06 | Annual |
| Insider Threat Awareness | Every 12 months | EO 13587 | Annual |
| CUI Training | Every 12 months | DoDI 5200.48 | Annual |

**Schema gap identified:** The current `CCSD_SecurityRecords` schema has `InitialBriefingDate`, `AnnualRefresherDate`, and `DerivedClassDate` but is **missing** `InsiderThreatDate`, `CUITrainingDate`, and `CIAwarenessDate`.

### 5. Incident Lifecycle (10 Stages)

Research confirms a 10-stage lifecycle with type-dependent branching:

1. Initial Report / Discovery
2. Preliminary Inquiry
3. Formal Reporting (to DISS/DCSA)
4. Interim Action / Suspension (commander authority)
5. Investigation (DCSA, AFOSI, or unit-level)
6. Adjudication (DCSA CAF / AFCAF)
7. Determination / Disposition
8. SOR Issuance (if unfavorable)
9. Appeal (PSAB)
10. Final Resolution / Closure

**Different incident types follow different paths.** Spillages require immediate containment and damage assessment. Financial issues may allow extended mitigation periods. Criminal conduct often runs parallel to legal proceedings.

**Due process rights (EO 12968, Section 5.2):** Written SOR, opportunity to respond (30 days), right to appeal, right to personal appearance before appellate panel. These are confirmed regulatory requirements, not optional.

### 6. DISS Export Fields (Common Practice)

Typical DISS export columns (not formally standardized, based on common unit-level practice):

Subject Name, SSN/DoD ID, SMO Code, Clearance Level, Eligibility Status, Investigation Type, Investigation Open/Close Dates, Eligibility Date, PR Due Date, CV Enrolled, Interim Eligibility, SCI Eligibility, LOJ Date, Access Indoctrinations

### 7. Physical Security (4 Sub-Areas)

Governed by DoDM 5200.01 Vol 3, AFI 31-101, AFI 16-1404. Key areas:
- **Key Control** — Combination changes required annually and on departure; SF-700 Parts 1/2A/2B management (NEVER store actual combinations in unclassified system)
- **Security Containers** — SF-702 daily checks, SF-701 area checks
- **Visitor Control** — Access logs, clearance verification, escort tracking
- **Restricted Areas** — Access rosters, AF Form 2586 tracking

### 8. Information Security (5 Sub-Areas)

Governed by DoDM 5200.01 Vols 1-4, AFI 16-1404, EO 13526. Key areas:
- **Classification Management** — Derivative classifier training tracking, SCG registry
- **CUI Handling** — CUI training tracking, incident tracking for improper handling
- **Document Accountability** — Top Secret requires continuous accountability and annual inventory; unclassified metadata only in the SPA
- **Destruction Records** — Two witnesses for TS; 5-year retention for TS destruction records
- **Spillage Response** — Immediate containment, damage assessment within 10 days

### 9. OPSEC (4 Sub-Areas)

Governed by DoDD 5205.02E, DoDM 5205.02, AFI 10-701. Key areas:
- **Program Compliance** — Coordinator appointment, annual assessment, training
- **Critical Information List (CIL)** — Annual review, version control, dissemination tracking
- **OPSEC Assessments** — Annual assessments required, findings tracked to closure
- **OPSEC Training** — All personnel: initial + annual refresher; coordinators: specialized course

### 10. Industrial Security (4 Sub-Areas)

Governed by 32 CFR 117 (NISPOM), DoDI 5220.22. Key areas:
- **DD-254 Tracking** — Contract classification specifications
- **Contractor Clearance Verification** — Via DISS; unit records verification, not raw data
- **Facility Clearance (FCL)** — Verification records, CAGE codes
- **Visitor Certification** — Visit authorization requests via DISS

---

## Privacy & Legal Constraints

1. **Security clearance status is CUI** — Not publicly releasable (DoDM 5400.11)
2. **Need-to-know applies** — Only those with official need should access incident details
3. **Privacy Act (5 USC 552a)** — System maintaining security PII must operate under an applicable System of Records Notice (SORN)
4. **SOR contents are particularly sensitive** — May contain medical, financial, and criminal information
5. **Mental health carve-out** — SEAD 3 explicitly excludes voluntary counseling for combat, sexual assault, DV, or grief from reporting requirements
6. **Unclassified system constraint** — The SPA runs on SharePoint Online (unclassified); no classified content, actual combinations, or SCI/SAP program names may be stored
7. **Commander vs. CAF authority** — Commander controls local access; CAF controls eligibility. The SPA tracks both but must not conflate them

---

## Recommendations for Implementation Phasing

| Phase | Scope | Dependencies |
|-------|-------|-------------|
| **Phase 1** | Personnel Security Core: clearance tracking, training compliance, SF-86 due dates, DISS import, self-service view, admin roster | `CCSD_SecurityRecords` list, `Security` role in `CCSD_AppRoles` |
| **Phase 2** | Incident & Case Management: SEAD 3 categories, lifecycle tracking, SOR workflow, case numbers, notifications | `CCSD_SecurityIncidents` list, `CCSD_Notifications` list |
| **Phase 3** | Physical Security: key control, container tracking (SF-700/702), visitor control, restricted area management | 4-6 new SharePoint lists |
| **Phase 4** | Information Security: classification management, CUI tracking, document accountability, destruction records | 2-3 new SharePoint lists |
| **Phase 5** | OPSEC & Industrial Security: program compliance, CIL management, DD-254 tracking, contractor clearances | 3-4 new SharePoint lists |

Phases 3-5 each represent significant scope expansion and should be validated with the project owner before implementation.
