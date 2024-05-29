trigger AssessmentQuestionResponseTrigger on AssessmentQuestionResponse(
  before insert,
  before update,
  after insert,
  after update,
  before delete
) {
  AssessmentQuestionResponseTriggerHandler handler = new AssessmentQuestionResponseTriggerHandler();
}
