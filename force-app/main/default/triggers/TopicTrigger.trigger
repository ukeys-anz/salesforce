trigger TopicTrigger on Topic(before insert) {
  TopicHandler handler = new TopicHandler();
}
