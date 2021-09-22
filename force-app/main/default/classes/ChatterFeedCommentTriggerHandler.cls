/**
 * @description ChatterFeedCommentriggerHandler to prevent chatter comments to be deleted, edited and sensitive info to be masked
 * @author Asteward Mikho
 * @since 07/2021
 */
public with sharing class ChatterFeedCommentTriggerHandler extends Lib_TriggerHandler {
  private static final String DELETE_ERROR = 'You do not have permission to delete this comment';
  private static final String EDIT_ERROR = 'You cannot edit feed comments.';
  private static final String FILE_ERROR = 'Files cannot be shared via chatter. Please remove the file from your message before you post.';
  private static final string IMAGE_ERROR = 'Images cannot be shared via chatter. Please remove the image from your message before you post.';

  /**
   * @description Constructor to initialise Trigger Handler library
   */
  public ChatterFeedCommentTriggerHandler() {
    super();
  }

  /**
   * @description  Mask the comments where applicable.
   */
  public override void onApplyDefaults() {
    for (FeedComment record : (List<FeedComment>) records) {
      record.CommentBody = TextUtils.maskData(record.CommentBody);
      if (
        record.CommentType == 'ContentPost' &&
        record.RelatedRecordId != null
      ) {
        record.addError(FILE_ERROR);
      }
    }
  }
  /**
   * @description  Mask the comments where applicable and prevents editing.
   * @param oldMap
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    for (FeedComment record : (List<FeedComment>) records) {
      record.addError(EDIT_ERROR);
    }
  }

  /**
   * @description onBeforeDelete to prevent case comments to be deleted
   */
  public override void onBeforeDelete() {
    for (FeedComment record : (List<FeedComment>) records) {
      record.addError(DELETE_ERROR);
    }
  }

  /**
   * @description onAfterInsert to perform processing during the after insert phase
   */
  public override void onAfterInsert() {
    for (FeedComment fi : (List<FeedComment>) records) {
      if (fi.CommentType == 'ContentComment' && fi.RelatedRecordId != null) {
        fi.addError(FILE_ERROR);
      }
      if (fi.CommentType == 'TextComment' && fi.CommentBody.contains('<img')) {
        fi.addError(IMAGE_ERROR);
      }
    }
  }
}
