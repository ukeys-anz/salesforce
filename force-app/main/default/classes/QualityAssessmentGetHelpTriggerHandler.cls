/**
 * @author Aman
 * @since 05/2025
 * @description  QualityAssessmentGetHelpTriggerHandler is the handler class for Quality Assessment Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class QualityAssessmentGetHelpTriggerHandler extends Lib_TriggerHandler {
  private static final Set<Id> GET_HELP_RT_IDS = new Set<Id>{
    RTQualityAssessment.getHelp,
    RTQualityAssessment.getHelpAppointment
  };
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public QualityAssessmentGetHelpTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns true always as it needs to be implemented on all Quality Assessment records. Later on we can in extend tis method to incorporate new scopes, if added.
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true
   */
  public override Boolean isValidRecord(SObject record) {
    Quality_Assessment__c qaRecord = (Quality_Assessment__c) record;
    return GET_HELP_RT_IDS.contains(qaRecord.RecordTypeId);
  }

  /**
   * @description onBeforeUpdate to handle before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    QualityAssessmentTriggerActions.calculateQAGetHelp(
      (List<Quality_Assessment__c>) records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    QualityAssessmentTriggerActions.createQAShareRecord(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }
}
