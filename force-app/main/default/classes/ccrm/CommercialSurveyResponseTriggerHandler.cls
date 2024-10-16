/**
 * @author Nabia Nadir
 * @since 08/2024
 * @description  CommercialSurveyResponseTriggerHandler is the handler class for Survey Response Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public class CommercialSurveyResponseTriggerHandler extends Lib_TriggerHandler {
  private static final String SURVEY_TRIGGER = 'Commercial';
  private static final String SURVEY_NAME = 'A-Z Reviews';

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public CommercialSurveyResponseTriggerHandler() {
    super();
  }
  /**
   * @description Implementation of isValidRecord on Lib_TriggerHandler, returns a list of CCRM Interaction records
   * @param record record to check if relevant to the execution context
   * @return `Boolean` returns true if record is relevant, false if record is not relevant
   */
  public override Boolean isValidRecord(SObject record) {
    qualtrics__Survey_Response__c rec = (qualtrics__Survey_Response__c) record;
    return rec.Survey_Trigger__c == SURVEY_TRIGGER &&
      rec.Survey_Name__c == SURVEY_NAME;
  }
  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    CommercialSurveyResponseActions.setFieldsForSurveyResponseOnInsert(records);
  }
}
