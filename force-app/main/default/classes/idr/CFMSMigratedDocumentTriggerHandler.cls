/**
 * @author Olivier Saier
 * @since 06/2021
 * @description  CFMSMigratedDocumentTriggerHandler is the handler class for CFMS_Migrated_Case__c Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class CFMSMigratedDocumentTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public CFMSMigratedDocumentTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeDelete to prevent cdeletion
   */
  public override void onBeforeDelete() {
    for (
      CFMS_Migrated_Document__c record : (List<CFMS_Migrated_Document__c>) records
    ) {
      record.addError('You may not delete CFMS migrated documents.');
    }
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    for (
      CFMS_Migrated_Document__c record : (List<CFMS_Migrated_Document__c>) records
    ) {
      record.Description__c = TextUtils.maskData(record.Description__c);
    }
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap Old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (
      CFMS_Migrated_Document__c record : (List<CFMS_Migrated_Document__c>) records
    ) {
      record.Description__c = TextUtils.maskData(record.Description__c);
    }
  }
}
