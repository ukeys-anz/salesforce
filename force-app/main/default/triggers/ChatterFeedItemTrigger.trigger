trigger ChatterFeedItemTrigger on FeedItem(
  before insert,
  before update,
  before delete,
  after insert
) {
  ChatterFeedItemTriggerHandler handler = new ChatterFeedItemTriggerHandler();
}
