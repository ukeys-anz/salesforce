/**
 * @author Afreen Khan
 * @since 04/2021
 * @description  LetterApprovalTriggerHandler is the handler class for Letter Approval Trigger which extends Lib_TriggerHandler the trigger framework used.
 *
 */
public with sharing class LetterApprovalTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public LetterApprovalTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    IDRLetterApprovalActions.populateCustomerData(
      (List<IDR_Letter_Approval__c>) records,
      null
    );
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRLetterApprovalActions.populateCustomerData(
      (List<IDR_Letter_Approval__c>) records,
      (Map<Id, IDR_Letter_Approval__c>) oldMap
    );
  }
}
