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
    AccountClosureCaseActions.populateCaseSubject(
      records,
      GetHelpConstants.ACCOUNT_CLOSURE
    );
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> parentCasesWhereCustomerChanged = ListUtil.filter(
        records,
        oldMap
      )
      .changed(case.AccountId)
      .toList();
    AccountClosureCaseActions.populateCaseSubject(
      parentCasesWhereCustomerChanged,
      GetHelpConstants.ACCOUNT_CLOSURE
    );
  }

  public override void onAfterInsert() {
    AccountClosureCaseActions.handleButtonVisibiltyFlags(records);
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> casesWithChangedFields = new List<Case>();
    casesWithChangedFields.addAll(
      (List<Case>) ListUtil.filter(records, oldMap)
        .changed(case.Status)
        .toList()
    );
    casesWithChangedFields.addAll(
      (List<Case>) ListUtil.filter(records, oldMap)
        .changed(case.Sub_Status__c)
        .toList()
    );
    AccountClosureCaseActions.handleButtonVisibiltyFlags(
      casesWithChangedFields
    );
  }

  public override void onAfterDelete() {
    AccountClosureCaseActions.handleButtonVisibiltyFlags(records);
  }
}
