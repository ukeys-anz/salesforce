trigger CaseCommentsTrigger on CaseComment(
  before delete,
  before insert,
  before update,
  after insert
) {
  CaseCommentsTriggerHandler handler = new CaseCommentsTriggerHandler();
}
