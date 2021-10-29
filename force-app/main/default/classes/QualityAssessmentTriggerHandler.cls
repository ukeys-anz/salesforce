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
}
