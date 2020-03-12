trigger CaseCommentsTrigger on CaseComment(before delete) {
  CaseCommentsTriggerHandler handler = new CaseCommentsTriggerHandler();
}
