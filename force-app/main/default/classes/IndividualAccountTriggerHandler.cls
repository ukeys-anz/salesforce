/**
 * @author Ashwin Mohan
 * @since 02/2025
 * @description Trigger Handler for Individual Accounts
 */

public with sharing class IndividualAccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public IndividualAccountTriggerHandler() {
    super();
  }

  /**
   * @description to check the record is of Business record type
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    return ((Account) record).RecordTypeId == RTAccount.personAccount;
  }

  /**
   * @description onBeforeInsert to update the list of records which were identified in onValidate() method
   */
  public override void onBeforeInsert() {
    IndividualAccountActions.validateDateOfBirth(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IndividualAccountActions.restrictEditOnPlusCustomer(records);
    IndividualAccountActions.validateDateOfBirth(records);
    IndividualAccountActions.validateCustomerAttribute(records, oldMap);
    IndividualAccountActions.revertShellProspectBillingAddress(records);
    IndividualAccountActions.handleEmploymentTypeChange(
      records,
      (Map<Id, Account>) oldMap
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IndividualAccountActions.getUpdatedCustomersIds(
      (Map<Id, Account>) oldMap,
      records
    );
    IndividualAccountActions.createCasesForDeceasedCustomer(
      records,
      (Map<Id, Account>) oldMap
    );
  }
}
