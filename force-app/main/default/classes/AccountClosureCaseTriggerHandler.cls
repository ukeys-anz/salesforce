/**
 * @description Handler for Account Closure  and Case Group Case Trigger which extends Lib_TriggerHandler framework.
 * @author Kopal Goswami
 * @since 11/2024
 */
public with sharing class AccountClosureCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public AccountClosureCaseTriggerHandler() {
    super();
  }

  private static final Set<SObjectField> CASE_FIELDS = new Set<SObjectField>{
    Case.Status,
    Case.Sub_Status__c
  };

  //Validate the record relevance to this handler based on record type
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.accountClosure;
  }

  public override void onBeforeInsert() {
    List<Case> accountClosureChildCasesWithoutParent = ListUtil.filter(records)
      .isNull(Case.ParentId)
      .toList();

    AccountClosureCaseActions.linkChildCasesWithParent(
      accountClosureChildCasesWithoutParent
    );
    AccountClosureCaseActions.cascadeParentFieldsToChildCases(records);
    AccountClosureCaseActions.populateCaseSubject(records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> parentCasesWhereCustomerChanged = ListUtil.filter(
        records,
        oldMap
      )
      .changed(case.AccountId)
      .toList();
    AccountClosureCaseActions.populateCaseSubject(
      parentCasesWhereCustomerChanged
    );
    AccountClosureCaseActions.setAccountDetailsAsEmpty(
      records,
      (Map<Id, Case>) oldMap
    );
  }

  public override void onAfterInsert() {
    AccountClosureCaseActions.initiatePrecheckButtonVisibility(records);
    AccountClosureCaseActions.setParentCaseStatusAsEscalated(records);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> casesWithChangedFields = ListUtil.filter(records, oldMap)
      .anyChanged(CASE_FIELDS)
      .toList();
    AccountClosureCaseActions.handleButtonVisibiltyFlags(
      casesWithChangedFields
    );
    AccountClosureCaseActions.setParentCaseStatusAsEscalated(
      casesWithChangedFields
    );
  }

  public override void onAfterDelete() {
    AccountClosureCaseActions.handleButtonVisibiltyFlags(records);
  }
}
