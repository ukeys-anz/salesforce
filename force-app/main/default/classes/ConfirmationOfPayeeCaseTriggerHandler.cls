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
    List<Case> childWithdrawnCases = ListUtil.filter(records, oldMap)
      .changedTo(case.Status, 'Withdrawn')
      .toList();
    ConfirmationOfPayeeCaseActions.populateChildCaseSubject(
      childCasesWhereTypeChanged
    );
    ConfirmationOfPayeeCaseActions.updateFieldsOnWithdrawn(childWithdrawnCases);

    List<Case> validCasesforMilestoneCompletion = ListUtil.filter(
        records,
        oldMap
      )
      .equals(Case.Type, CaseGroupCaseConstants.ENTITLEMENT_CASE_ISSUE_TYPES)
      .changedTo(Case.Status, CaseGroupCaseConstants.CLOSED_STATUSES)
      .toList();

    Set<Id> validCaseIds = ListUtil.getIds(
      validCasesforMilestoneCompletion,
      Case.Id
    );
    MilestoneUtils.completeMilestones(
      validCaseIds,
      CaseGroupCaseConstants.MILESTONES_APPLICABLE,
      System.now()
    );
  }

  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<Case> childCasesWhereStatusChanged = ListUtil.filter(records, oldMap)
      .changed(case.Status)
      .toList();
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(
      childCasesWhereStatusChanged
    );
    ConfirmationOfPayeeCaseActions.updateParentCaseStatusToClosed(
      childCasesWhereStatusChanged
    );
  }

  public override void onAfterDelete() {
    ConfirmationOfPayeeCaseActions.handleModifyCopAction(records);
  }
}