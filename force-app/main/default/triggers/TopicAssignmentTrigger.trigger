trigger TopicAssignmentTrigger on TopicAssignment(
  before insert,
  before update,
  after insert,
  after update,
  before delete,
  after delete
) {
  InteractionTopicAssignmentHandler handler = new InteractionTopicAssignmentHandler();
}
