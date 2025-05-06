/**
 * @author       : Hitesh
 * @since        : Feb 2025
 * @description  : MobileLendingOpportunityTriggerHandler is the handler class for Opportunity Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class MobileLendingOpportunityTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name MobileLendingOpportunityTriggerHandler
   */
  public MobileLendingOpportunityTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of ML Opportunity records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Opportunity opportunityRecord = (Opportunity) record;
    return opportunityRecord.RecordTypeId == RTOpportunity.mlOpportunity;
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @name onAfterUpdate
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values of Opportunity.
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    OpportunityActions.updateOCRSyncRecordsOnLARChange(
      records,
      (Map<Id, Opportunity>) oldMap
    );
  }
}
