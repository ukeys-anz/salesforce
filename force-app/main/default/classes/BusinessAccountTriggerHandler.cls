/**
 * @author Ashwin Mohan
 * @since 02/2025
 * @description Trigger Handler for Business Accounts
 */
public with sharing class BusinessAccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public BusinessAccountTriggerHandler() {
    super();
  }

  /**
   * @description to check the record is of Business record type
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Account) record).RecordTypeId == RTAccount.businessAccount;
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    BusinessAccountActions.setErrorForOCVIdChange(
      records,
      (Map<Id, Account>) oldMap
    );
  }
}
