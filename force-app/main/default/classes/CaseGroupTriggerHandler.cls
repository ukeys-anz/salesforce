/**
 * @description Handler for Case Group Case Trigger which extends Lib_TriggerHandler framework.
 * @author Kopal Goswami
 * @since 1/2025
 */
public with sharing class CaseGroupTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CaseGroupTriggerHandler() {
    super();
  }

  //Validate the record relevance to this handler based on record type
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.caseGroup;
  }

  public override void onBeforeInsert() {
    List<Case> filteredParentCaseByIssueType = ListUtil.filter(records)
      .equals(Case.Type, CaseGroupCaseConstants.CASE_ISSUE_TYPES)
      .toList();

    CaseGroupCaseActions.validateDuplicateParentCasePerAccount(
      filteredParentCaseByIssueType
    );
    CaseGroupCaseActions.populateParentCaseSubject(
      filteredParentCaseByIssueType
    );
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> parentCasesWithChangedFields = new List<Case>();
    List<Case> filteredParentCaseByIssueType = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CaseGroupCaseConstants.CASE_ISSUE_TYPES)
      .toList();
    parentCasesWithChangedFields.addAll(
      (List<Case>) ListUtil.filter(filteredParentCaseByIssueType, oldMap)
        .changed(case.Type)
        .toList()
    );
    parentCasesWithChangedFields.addAll(
      (List<Case>) ListUtil.filter(filteredParentCaseByIssueType, oldMap)
        .changed(case.AccountId)
        .toList()
    );

    List<Case> parentCasesWithStatusEscalated = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CaseGroupCaseConstants.CASE_ISSUE_TYPES)
      .changedTo(Case.Status, CaseGroupCaseConstants.ESCALATED_STATUS)
      .toList();
    List<Case> parentCasesWithStatusClosed = ListUtil.filter(records, oldMap)
      .equals(Case.Type, CaseGroupCaseConstants.CASE_ISSUE_TYPES)
      .changedTo(Case.Status, CaseGroupCaseConstants.CLOSED_STATUS)
      .toList();

    CaseGroupCaseActions.validateDuplicateParentCasePerAccount(
      parentCasesWithChangedFields
    );
    CaseGroupCaseActions.populateParentCaseSubject(
      parentCasesWithChangedFields
    );
    CaseGroupCaseActions.assignEscalatedCasesToQueue(
      parentCasesWithStatusEscalated
    );
    CaseGroupCaseActions.validateParentClosureIfChildCasesOpen(
      parentCasesWithStatusClosed
    );

    CaseGroupCaseActions.completeMilestones(records, oldMap);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> filteredParentCaseByIssueType = ListUtil.filter(records)
      .equals(Case.Type, CaseGroupCaseConstants.CASE_ISSUE_TYPES)
      .toList();
    Set<Schema.SObjectField> fieldsToTrackForChanges = new Set<Schema.SObjectField>{
      Case.OwnerId,
      Case.Status,
      Case.Circumstance__c,
      Case.Type
    };
    List<Case> parentCasesWithFieldChanges = RecordComparisonUtil.getRecordsWithChangedFields(
      filteredParentCaseByIssueType,
      oldMap,
      fieldsToTrackForChanges
    );
    CaseGroupCaseActions.cascadeParentFieldChangesToChildCases(
      parentCasesWithFieldChanges
    );
  }
}
