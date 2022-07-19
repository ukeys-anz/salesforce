/**
 * @author Emma Bindi
 * @since 05/2022
 * @description  LeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class LeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onAfterUpdate etc.
   */
  public LeadTriggerHandler() {
    super();
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    LeadChatterMigrationHelper.migrateChatterPostsOnConversion(records, oldMap);
  }
}
