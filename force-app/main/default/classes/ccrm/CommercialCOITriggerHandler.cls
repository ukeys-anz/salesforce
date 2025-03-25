/**
 * @author       : Naman Garg
 * @since        : Feb 2025
 * @description  : CommercialCOITriggerHandler is the handler class for Circle of Influence Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialCOITriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialCOITriggerHandler
   */
  public CommercialCOITriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of Commercial Circle_Of_Influence__c records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Circle_Of_Influence__c coiRecord = (Circle_Of_Influence__c) record;
    return coiRecord.RecordTypeId == RTCOI.companyMember;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialCOIActions.populateCOINameOnInsert(records);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialCOIActions.populateCOINameOnUpdate(
      (List<Circle_Of_Influence__c>) records,
      (Map<Id, Circle_Of_Influence__c>) oldMap
    );
  }
}
