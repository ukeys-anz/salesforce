/**
 * @description Handler for Disputes Cases
 * @author Vaibhav Joshi
 * @since 07/2025
 */
public with sharing class ImtDisputesCaseTriggerHandler extends Lib_TriggerHandler {
  public static final String IMT_NEW_EXTERNAL_STATUS = 'IMT_New_SF';
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ImtDisputesCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of disputes Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.imtDispute;
  }

  /**
   * @description onAfterInsert to handle after update trigger actions.
   */
  public override void onAfterInsert() {
    createImtExternalCase();
  }

  private void createImtExternalCase() {
    DisputesCaseActions.createExternalCaseStatuses(
      (List<Case>) records,
      IMT_NEW_EXTERNAL_STATUS
    );
  }
}
