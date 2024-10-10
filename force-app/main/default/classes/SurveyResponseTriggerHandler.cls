/**
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description  SurveyResponseTriggerHandler is the handler class for Survey Response Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class SurveyResponseTriggerHandler extends Lib_TriggerHandler {
  private static final String SURVEY_TRIGGER = 'Commercial';
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public SurveyResponseTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of NON A-Z related Survey records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    qualtrics__Survey_Response__c rec = (qualtrics__Survey_Response__c) record;
    return rec.Survey_Trigger__c != SURVEY_TRIGGER;
  }
  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    SurveyResponseActions.beforeInsertActions(records);
    SurveyResponseActions.setSurveyResponseName(records);
  }

  /**
   * @description onAfterInsert to handle after insert trigger actions.
   */
  public override void onAfterInsert() {
    SurveyResponseActions.createCaseForSurveyResponse(records);
  }
}
