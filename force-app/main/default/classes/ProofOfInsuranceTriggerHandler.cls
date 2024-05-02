/**
 * @author Peter Charalambous
 * @since Mon Mar 25 2024
 * @description Trigger handler for proof of insurance trigger
 */
public with sharing class ProofOfInsuranceTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public ProofOfInsuranceTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    ProofOfInsuranceActions.populateCustomerName(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ProofOfInsuranceActions.populateCustomerName(records);
  }
}
