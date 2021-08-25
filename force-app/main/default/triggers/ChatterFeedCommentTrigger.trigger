trigger ChatterFeedCommentTrigger on FeedComment(
  before insert,
  before update,
  before delete,
  after insert
) {
  ChatterFeedCommentTriggerHandler handler = new ChatterFeedCommentTriggerHandler();
}
