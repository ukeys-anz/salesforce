/**
 * @author CMOS
 * @since 10/2025
 * @description  IDRQualityAssessmentTriggerHandler is the handler class for IDR Quality Assessment Trigger.
 */
public with sharing class IDRQualityAssessmentTriggerHandler extends Lib_TriggerHandler {
  final Set<Id> idrQARecordTypes = new Set<Id>{
    RTQualityAssessment.idrCQQualityId,
    RTQualityAssessment.idrReviewAssessmentId
  };
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public IDRQualityAssessmentTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of C&Q Assessment record types
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record type is either C&Q Assessment or call/letter review else false
   */
  public override Boolean isValidRecord(SObject record) {
    Id qaRTId = ((Quality_Assessment__c) record).RecordTypeId;
    return idrQARecordTypes.contains(qaRTId);
  }
  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    IDRQualityAssessmentActions.setAssessmentOutcomeStatus(records, null);
    IDRQualityAssessmentActions.applyDefaults(
      (List<Quality_Assessment__c>) records,
      null
    );
  }
  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    IDRQualityAssessmentTaskActions.createComplianceTasks(records, null);
    IDRQualityAssessmentTaskActions.createFinalLetterReviewTask(records, null);
    IDRQualityAssessmentTaskActions.createQAShareRecord(records, null);
  }
  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    IDRQualityAssessmentActions.setAssessmentOutcomeStatus(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    IDRQualityAssessmentActions.applyDefaults(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }
  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    IDRQualityAssessmentTaskActions.createComplianceTasks(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    IDRQualityAssessmentTaskActions.createFinalLetterReviewTask(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    IDRQualityAssessmentTaskActions.createQAShareRecord(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }
}
