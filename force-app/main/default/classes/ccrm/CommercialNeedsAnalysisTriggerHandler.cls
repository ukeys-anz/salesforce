/**
 * @author       : Mildeep Singh
 * @since        : Aug 2025
 * @description  : This is the handler class for CommercialNeedsAnalysisTrigger
 **/
public with sharing class CommercialNeedsAnalysisTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   * @name CommercialNeedsAnalysisTriggerHandler
   */
  public CommercialNeedsAnalysisTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Lead records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Needs_Analysis__c needsAnalysisRecord = (Needs_Analysis__c) record;
    return needsAnalysisRecord.RecordTypeId ==
      RTNeedsAnalysis.transactionalBankingNeedsAnalysis;
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   * @name onBeforeInsert
   */
  public override void onBeforeInsert() {
    CommercialNeedsAnalysisActions.populateCustomerFromOpportunity(records);
    CommercialNeedsAnalysisActions.restrictImagesInRichTextFields(
      records,
      null
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Money_Held__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Overview__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Money_Out__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Money_In__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Payables__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Receivables__c');
  }

  /**
   * @description onBeforeUpdate to handle before insert trigger actions.
   * @name onBeforeUpdate
   * @param oldMap oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    CommercialNeedsAnalysisActions.restrictImagesInRichTextFields(
      records,
      (Map<Id, Needs_Analysis__c>) oldMap
    );
    TextUtils.maskSObjectDataANZExtended(records, 'Money_Held__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Overview__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Money_Out__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Money_In__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Payables__c');
    TextUtils.maskSObjectDataANZExtended(records, 'Receivables__c');
  }
}
