/**
 * @author Olivier Saier
 * @since 08/2021
 * @description LeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class LeadTriggerHandler extends Lib_TriggerHandler {
  @testVisible
  private static final String DELETE_ERROR = 'You cannot delete leads';

  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadTriggerHandler
   */
  public LeadTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CCRMControllingPostActions.retrieveControllingPost(records, null);
    CCRMLeadUtil.validateUnicaLeads(records);
    CCRMLeadUtil.validateAdobeLeads(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CCRMControllingPostActions.retrieveControllingPost(records, oldMap);
  }

  /**
   * @description onAfterUpdate: After Update Action of Lead.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Lead.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    LeadChatterMigrationHelper.migrateChatterPostsOnConversion(records, oldMap);
  }
}
