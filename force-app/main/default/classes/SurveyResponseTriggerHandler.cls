/**
 * @author Jasmine Nguyen
 * @since 03/2022
 * @description  SurveyResponseTriggerHandler is the handler class for Survey Response Trigger which extends Lib_TriggerHandler the trigger framework used.
 */

public with sharing class SurveyResponseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public SurveyResponseTriggerHandler() {
    super();
  }

  /**
   * @description onBeforeInsert to handle before insert trigger actions.
   */
  public override void onBeforeInsert() {
    SurveyResponseActions.beforeInsertActions(records);
  }
}
