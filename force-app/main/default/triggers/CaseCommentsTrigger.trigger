trigger CaseCommentsTrigger on CaseComment(
  before delete,
  before insert,
  before update
) {
  CaseCommentsTriggerHandler handler = new CaseCommentsTriggerHandler();
}
