/**
 * @description ChatterFeedItemTriggerHandler to prevent chatter comments to be deleted, edited and sensitive info to be masked
 * @author Asteward Mikho
 * @since 07/2021
 */
public with sharing class ChatterFeedItemTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ChatterFeedItemTriggerHandler() {
    super();
  }

  /**
   * @description actions performed onBeforeInsert
   */
  public override void onApplyDefaults() {
    ChatterFeedItemActions.maskDataInChatterFeed((List<FeedItem>) records);
  }

  /**
   * @description onBeforeUpdate to perform processing during the before update phase
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    ChatterFeedItemActions.blockEditChatterFeed((List<FeedItem>) records);
  }

  /**
   * @description onBeforeDelete to prevent feeditem to be deleted
   */
  public override void onBeforeDelete() {
    if (!FeatureManagement.checkPermission('DeleteChatter')) {
      ChatterFeedItemActions.blockDeleteChatterFeed((List<FeedItem>) records);
    }
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    ChatterFeedItemActions.blockFilesAndImagesInChatterFeed(
      (List<FeedItem>) records
    );
  }

  /**
   * @description onBeforeInsert to perform processing during the before insert phase
   */
  public override void onBeforeInsert() {
    if (
      !FeatureManagement.checkPermission(
        'ANZx_Bypass_Chatter_Feed_URL_Validation'
      )
    ) {
      ChatterFeedItemActions.blockEmailsAndURLsInChatterFeed(
        (List<FeedItem>) records
      );
    }
  }
}
