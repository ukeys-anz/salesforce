/**
 * @description ChatterFeedItemTriggerHandler to prevent chatter comments to be deleted, edited and sensitive info to be masked
 * @author Asteward Mikho
 * @since 07/2021
 */
public with sharing class ChatterFeedItemTriggerHandler extends Lib_TriggerHandler {
  private static final String DELETE_ERROR = 'You cannot delete feed items.';
  private static final String EDIT_ERROR = 'You cannot edit feed items.';
  private static final string FILE_ERROR = 'Files cannot be shared via chatter. Please remove the file from your message before you post.';
  private static final string IMAGE_ERROR = 'Images cannot be shared via chatter. Please remove the image from your message before you post.';

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ChatterFeedItemTriggerHandler() {
    super();
  }

  /**
   * @description  Mask the comments where applicable.
   */
  public override void onApplyDefaults() {
    for (FeedItem record : (List<FeedItem>) records) {
      record.Body = TextUtils.maskData(record.Body);
      if (record.type == 'ContentPost' && record.RelatedRecordId != null) {
        record.addError(FILE_ERROR);
      }
    }
  }

  /**
   * @description  Mask the comments where applicable and prevents editing.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (FeedItem record : (List<FeedItem>) records) {
      record.addError(EDIT_ERROR);
    }
  }

  /**
   * @description onBeforeDelete to prevent feeditem to be deleted
   */
  public override void onBeforeDelete() {
    for (FeedItem record : (List<FeedItem>) records) {
      record.addError(DELETE_ERROR);
    }
  }
  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    for (FeedItem fi : (List<FeedItem>) records) {
      if (fi.type == 'ContentPost' && fi.RelatedRecordId != null) {
        fi.addError(FILE_ERROR);
      }
      if (fi.type == 'TextPost' && fi.Body.contains('<img')) {
        fi.addError(IMAGE_ERROR);
      }
    }
  }
}
