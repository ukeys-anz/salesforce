/**
 * @author Ashish Kumar
 * @since 07/2023
 * @description MLCRMTerritorySharingTriggerHandler is the handler class for Territory Sharing Trigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class MLCRMTerritorySharingTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name LeadTriggerHandler
   */
  public MLCRMTerritorySharingTriggerHandler() {
    super();
  }

  /**
   * @description onAfterInsert: After Insert actions on Lead.
   * @name onAfterInsert
   */
  public override void onAfterInsert() {
    MLCRMTerritorySharingActions.subscribeTerritoryRecord(records);
  }
}
