/**
 * @author       : Naman Garg
 * @since        : Nov 2024
 * @description  : CommercialLeadTriggerHandler is the handler class for Lead Trigger which extends Lib_TriggerHandler from the trigger framework used.
 **/
public with sharing class CommercialLeadTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialLeadTriggerHandler
   */
  public CommercialLeadTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Lead leadRecord = (Lead) record;
    return leadRecord.RecordTypeId == RTLead.commercialLead;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialLeadActions.restrictImagesInRichTextFields(records, null);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @name onBeforeUpdate
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialLeadActions.restrictImagesInRichTextFields(
      (List<Lead>) records,
      (Map<Id, Lead>) oldMap
    );
  }
}
