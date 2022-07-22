/**
 * @author Sahil Sachar
 * @since 10/2021
 * @description CampaignFlexFieldTriggerHandler is the handler class for Campaign_Flex_Field__c Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class CampaignFlexFieldTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadTriggerHandler
   */
  public CampaignFlexFieldTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMCampaignFlexFieldActions.populateUUID(records);
  }
}
