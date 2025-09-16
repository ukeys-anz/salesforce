/**
 * @author Akshat Khandelwal
 * @since 08/2025
 * @description  DeceasedCustomerCaseTriggerHandler is the handler class for Deceased Customer Cases.
 */
public with sharing class DeceasedCustomerCaseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public DeceasedCustomerCaseTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Genral Inquiry case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Case) record).RecordTypeId == RTCase.generalInquiry &&
      ((Case) record).Type == 'Deceased Estate';
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    DeceasedCustomerCaseActions.updateDeceasedEstateStatusOnAccount(
      records,
      'Initiated'
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   *@param oldMap oldMap of updated cases
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    DeceasedCustomerCaseActions.checkValidityAndUpdateAccount(records, oldMap);
  }
}
