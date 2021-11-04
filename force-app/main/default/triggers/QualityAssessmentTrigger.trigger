trigger QualityAssessmentTrigger on Quality_Assessment__c(
  before insert,
  before update,
  after insert,
  after update
) {
  QualityAssessmentTriggerHandler handler = new QualityAssessmentTriggerHandler();
}
