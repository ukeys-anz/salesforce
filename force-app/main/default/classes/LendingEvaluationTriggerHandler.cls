/**
 * @author Hrushikesh
 * @since 05/2025
 * @description  LendingEvaluationTriggerHandler is the handler class for Quality Assessment Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public with sharing class LendingEvaluationTriggerHandler extends Lib_TriggerHandler {
  private static final Id LENDING_EVALUATION_RT_ID = QueryRt.of(
      Quality_Assessment__c.SObjectType
    )
    .getId('ANZ_Plus_Governance_Lending_Evaluation');
  /**
   * @description Constructor to call the trigger framework
   * which will call the appropriate methods such as onBeforeInsert etc.
   */
  public LendingEvaluationTriggerHandler() {
    super();
  }

  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of disputes Case records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    Quality_Assessment__c qaRecord = (Quality_Assessment__c) record;
    return qaRecord.RecordTypeId == LENDING_EVALUATION_RT_ID;
  }

  /**
   * @description onAfterInsert to handle after update trigger actions.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    LendingEvaluationActions.setProcessExecutionOutcome(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    LendingEvaluationActions.setRiskAndComplianceOutcome(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    LendingEvaluationActions.calculateAndSetNumberOfApplication(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }

  /**
   * @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    LendingEvaluationActions.setProcessExecutionOutcome(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    LendingEvaluationActions.setRiskAndComplianceOutcome(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
    LendingEvaluationActions.calculateAndSetNumberOfApplication(
      records,
      new Map<Id, Quality_Assessment__c>()
    );
  }

  /**
   * @description onAfterUpdate to handle after update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    LendingEvaluationActions.createQAShareRecordsForLendingEvaluation(
      records,
      (Map<Id, Quality_Assessment__c>) oldMap
    );
  }
}
