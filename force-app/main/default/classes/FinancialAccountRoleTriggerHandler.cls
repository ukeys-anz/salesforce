/**
 *
 * @author Tan Phan
 * @since 05/2023
 * @description the handler class for {@link FinancialAccountRoleTrigger.trigger} which extends Lib_TriggerHandler the trigger framework used.
 * @runTests FinancialAccountRoleTriggerHandlerTest
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
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CCRMFinancialAccountRoleActions.setRecordType(records);
    CCRMFinancialAccountRoleActions.mapRoleTypeToRole(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    CCRMFinancialAccountRoleActions.updateFinancialAccountOwner(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMFinancialAccountRoleActions.deactivateEndDatedRecords(
      records,
      (Map<Id, FinServ__FinancialAccountRole__c>) oldMap
    );
    CCRMFinancialAccountRoleActions.setRecordType(records);
    CCRMFinancialAccountRoleActions.checkLastPrimaryOwnerDeactivated(
      records,
      (Map<Id, FinServ__FinancialAccountRole__c>) oldMap
    );
  }
}
