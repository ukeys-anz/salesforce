/**
 * @description AssessmentQuestionResponseTriggerHandler is the handler class for AssessmentQuestionResponse Trigger which extends Lib_TriggerHandler the trigger framework used.
 * @author Somya Tiwari
 * @since 05/2024
 */
public with sharing class AssessmentQuestionResponseTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public AssessmentQuestionResponseTriggerHandler() {
    super();
  }

  /**
   * @description  Mask the comments where applicable.
   * This is implemented for project Augur however as this is APRA requirements this will be same for ANZx.
   */
  public override void onApplyDefaults() {
    for (
      AssessmentQuestionResponse record : (List<AssessmentQuestionResponse>) records
    ) {
      TextUtils.maskDataCmos(record, 'ResponseText');
      TextUtils.maskDataCmos(record, 'ResponseValue');
    }
  }
}
