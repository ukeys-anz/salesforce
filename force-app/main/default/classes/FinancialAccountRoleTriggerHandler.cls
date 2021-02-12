/**
 * @author Jasmine Nguyen
 * @since 2/2021
 * @description  FinancialAccountRoleTriggerHandler is the handler class for Financial Account Role Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class FinancialAccountRoleTriggerHandler extends Lib_TriggerHandler {
  //List to store Financial Account Roles that we will set External Id
  public List<FinServ__FinancialAccountRole__c> rolesRecordsToProcess = new List<FinServ__FinancialAccountRole__c>();

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public FinancialAccountRoleTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to update the list of records which were identified in onValidate() method
   */
  public override void onBeforeInsert() {
    for (
      FinServ__FinancialAccountRole__c record : (List<FinServ__FinancialAccountRole__c>) records
    ) {
      // Only process the roles which are Primary Owner
      if (record.FinServ__Role__c == 'Primary Owner') {
        rolesRecordsToProcess.add(record);
      }
    }

    if (!rolesRecordsToProcess.isEmpty()) {
      FinancialAccountRoleCommonActions.setExternalId(rolesRecordsToProcess);
    }
  }
}
