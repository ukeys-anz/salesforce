trigger KnowledgeTrigger on Knowledge__kav(before insert, before update) {
  KnowledgeTrigggerHandler handler = new KnowledgeTrigggerHandler();
}
