/**
 * @author Victor Wang
 * @since 09/2021
 * @description  QualityAssessmentTriggerHandler is the handler class for Quality Assessment Trigger which extends Lib_TriggerHandler the trigger framework used.
 * We are checking recursion in after update so that update doesnt get called repeatedly for the same transaction.
 * Recursion is checked based on https://help.salesforce.com/articleView?id=000332407&type=1&mode=1
 */

public with sharing class QualityAssessmentTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public QualityAssessmentTriggerHandler() {
    super();
  }

  private static final String QA_RECORD_VALIDATION_ERROR_MSG = 'Related case must be under the same customer as the QA record.';

  /**
   * @description onAfterInsert to update the list of records which were identified in onValidate() method
   */
  public override void onAfterInsert() {
    QualityAssessmentActions.populateFields(records);
    QualityAssessmentTaskActions.createComplianceTasks(records, null);
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    QualityAssessmentTaskActions.createComplianceTasks(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }

  /**
   * @description onBeforeUpdate to handle before insert trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    QualityAssessmentActions.assignToQueue(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }

  /**
   * @description onApplyDefaults method is called before onBeforeInsert to set the default values for the records.
   */
  public override void onApplyDefaults() {
    QualityAssessmentActions.assignToQueue(records, null);
  }

  /**
   * @description onValidate method is called on after insert and after update to validate qa values
   */
  public override void onValidate() {
    validateQArecords(records);
  }

  /**
   * @description validates qa records
   * @param records the QA records being validated
   */
  private static void validateQArecords(List<Quality_Assessment__c> records) {
    Map<Id, Quality_Assessment__c> qaMap = new Map<Id, Quality_Assessment__c>(
      records
    );
    if (Quality_Assessment__c.SObjectType.getDescribe().isAccessible()) {
      for (Quality_Assessment__c record : [
        SELECT Id, Customer__c, Related_Case__r.AccountId
        FROM Quality_Assessment__c
        WHERE Id IN :records
      ]) {
        if (
          record.Customer__c != null &&
          record.Customer__c != record.Related_Case__r?.AccountId
        ) {
          qaMap.get(record.Id).addError(QA_RECORD_VALIDATION_ERROR_MSG);
        }
      }
    }
  }
}
