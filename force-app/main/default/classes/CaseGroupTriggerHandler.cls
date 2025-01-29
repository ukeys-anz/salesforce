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
    List<Case> parentCasesOfAccountClosureType = ListUtil.filter(records)
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .toList();

    AccountClosureCaseActions.validateDuplicateParentCasePerAccount(
      parentCasesOfAccountClosureType
    );
    AccountClosureCaseActions.populateCaseSubject(
      parentCasesOfAccountClosureType,
      GetHelpConstants.CASE_GROUP
    );
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> parentCasesWhereCustomerChanged = ListUtil.filter(
        records,
        oldMap
      )
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .changed(case.AccountId)
      .toList();
    List<Case> parentCasesWithStatusEscalated = ListUtil.filter(records, oldMap)
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .changedTo(Case.Status, GetHelpConstants.ESCALATED_STATUS)
      .toList();
    List<Case> parentCasesWithStatusClosed = ListUtil.filter(records, oldMap)
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .changedTo(Case.Status, GetHelpConstants.CLOSED_STATUS)
      .toList();

    AccountClosureCaseActions.validateDuplicateParentCasePerAccount(
      parentCasesWhereCustomerChanged
    );
    AccountClosureCaseActions.populateCaseSubject(
      parentCasesWhereCustomerChanged,
      GetHelpConstants.CASE_GROUP
    );
    AccountClosureCaseActions.assignEscalatedCasesToQueue(
      parentCasesWithStatusEscalated
    );
    AccountClosureCaseActions.validateParentClosureIfChildCasesOpen(
      parentCasesWithStatusClosed
    );
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> parentCasesOfAccountClosureType = ListUtil.filter(records)
      .equals(Case.Type, GetHelpConstants.ACCOUNT_CLOSURE)
      .toList();
    Set<Schema.SObjectField> fieldsToTrackForChanges = new Set<Schema.SObjectField>{
      Case.OwnerId,
      Case.Status,
      Case.Circumstance__c
    };
    List<Case> parentCasesWithFieldChanges = RecordComparisonUtil.getRecordsWithChangedFields(
      parentCasesOfAccountClosureType,
      oldMap,
      fieldsToTrackForChanges
    );
    AccountClosureCaseActions.cascadeParentFieldChangesToChildCases(
      parentCasesWithFieldChanges
    );
  }
}
