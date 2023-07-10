/**
 * @author Jasmine Nguyen
 * @since 3/2021
 * @description  FinancialAccountTriggerHandler is the handler class for @link FinancialAccountTrigger.trigger which extends Lib_TriggerHandler the trigger framework used.
 * @runTests FinancialAccountTriggerHandlerTest
 */

public with sharing class FinancialAccountTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public FinancialAccountTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMFinancialAccountActions.populateName(records);
    CCRMFinancialAccountActions.validateSourceStatus(records, null);
    CCRMFinancialAccountActions.setPrimaryOwner(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMFinancialAccountActions.populateName(records);
    CCRMFinancialAccountActions.validateSourceStatus(records, oldMap);
    CCRMFinancialAccountActions.setPrimaryOwner(records);
  }
}
