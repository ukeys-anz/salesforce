trigger SurveyResponseTrigger on qualtrics__Survey_Response__c(
  before insert,
  after insert
) {
  SurveyResponseTriggerHandler handler = new SurveyResponseTriggerHandler();
}
