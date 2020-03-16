trigger CaseCommentsTrigger on CaseComment(before delete, before update) {
  CaseCommentsTriggerHandler handler = new CaseCommentsTriggerHandler();
}
