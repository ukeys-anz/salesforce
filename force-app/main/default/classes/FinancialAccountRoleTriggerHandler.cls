/**
 * @author Jasmine Nguyen
 * @since 2/2021
 * @description  FinancialAccountRoleTriggerHandler is the handler class for Financial Account Role Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class FinancialAccountRoleTriggerHandler extends Lib_TriggerHandler {
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
    FinancialAccountRoleCommonActions.populateData(records);
  }
}
