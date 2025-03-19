/**
 * @description Handler for Confirmation Of Payee Cases which extends Lib_TriggerHandler framework.
 * @author Kopal Goswami
 * @since 3/2025
 */
public with sharing class ConfirmationOfPayeeCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ConfirmationOfPayeeCaseTriggerHandler() {
    super();
  }

  //Validate the record relevance to this handler based on record type

  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.confirmationOfPayee;
  }

  public override void onBeforeInsert() {
    ConfirmationOfPayeeCaseActions.cascadeParentFieldsToChildCases(records);
    ConfirmationOfPayeeCaseActions.populateChildCaseSubject(records);
  }

  public override void onAfterInsert() {
    ConfirmationOfPayeeCaseActions.modifyCopStatusButtonVisibility(records);
  }

  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    List<Case> childCasesWhereTypeChanged = ListUtil.filter(records, oldMap)
      .changed(case.Type)
      .toList();
    ConfirmationOfPayeeCaseActions.populateChildCaseSubject(
      childCasesWhereTypeChanged
    );
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> childCasesWhereStatusChanged = ListUtil.filter(records, oldMap)
      .changed(case.Status)
      .toList();
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(
      childCasesWhereStatusChanged
    );
  }

  public override void onAfterDelete() {
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(records);
  }
}
