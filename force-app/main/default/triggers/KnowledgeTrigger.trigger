trigger KnowledgeTrigger on Knowledge__kav(before insert) {
  KnowledgeTrigggerHandler handler = new KnowledgeTrigggerHandler();
}
