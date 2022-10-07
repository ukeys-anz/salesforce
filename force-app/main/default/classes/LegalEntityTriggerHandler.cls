/**
 * @description LegalEntityTriggerHandler is the handler class for Legal Entity Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Mairaj Haider
 * @since 06/2022
 */
public with sharing class LegalEntityTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LegalEntityTriggerHandler
   */
  public LegalEntityTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMLegalEntityActions.validateAccount(records, null);
    CCRMLegalEntityActions.populateEntityFields(records, null);
  }

  /**
   * @description onAfterInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onAfterInsert() {
    CCRMLegalEntityActions.updateHasLegalEntity(records, null);
    CCRMLegalEntityActions.updateAccountOnOpportunity(records, null);
  }
}
