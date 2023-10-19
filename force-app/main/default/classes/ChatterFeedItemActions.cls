/**
 * @author Batya Aisman Sufrin
 * @since  08/2023
 * @description ChatterFeedItemActions is to handle all the ChatterFeedItemTrigger actions
 */
public with sharing class ChatterFeedItemActions {
  private static final String REMOVE_URL = 'Please remove urls from chatter post';
  private static final String DELETE_ERROR = 'You do not have permission to delete this comment';
  private static final String EDIT_ERROR = 'You cannot edit feed items.';
  private static final string FILE_ERROR = 'Files cannot be shared via chatter. Please remove the file from your message before you post.';
  private static final string IMAGE_ERROR = 'Images cannot be shared via chatter. Please remove the image from your message before you post.';

  /**
   * @description Mask the comments where applicable and Handle Excessive Chatter Body
   * @param records FeedItem records from trigger
   */
  public static void maskDataInChatterFeed(List<FeedItem> records) {
    FeedMaskUtils.maskDataInChatterFeedAndComment(records);
  }

  /**
   * @description Prevents editing Chatter Feed
   * @param records FeedItem records from trigger
   */
  public static void blockEditChatterFeed(List<FeedItem> records) {
    for (FeedItem record : records) {
      record.addError(EDIT_ERROR);
    }
  }

  /**
   * @description Prevents deleting Chatter Feed
   * @param records FeedItem records from trigger
   */
  public static void blockDeleteChatterFeed(List<FeedItem> records) {
    for (FeedItem record : records) {
      record.addError(DELETE_ERROR);
    }
  }

  /**
   * @description Blocks Files or Images in Chatter Feed
   * @param records FeedItem records from trigger
   */
  public static void blockFilesAndImagesInChatterFeed(List<FeedItem> records) {
    for (FeedItem fi : records) {
      if (fi.type == 'ContentPost' && fi.RelatedRecordId != null) {
        fi.addError(FILE_ERROR);
      }
      if (fi.type == 'TextPost' && fi.Body.contains('<img')) {
        fi.addError(IMAGE_ERROR);
      }
    }
  }

  /**
   * @description Blocks URLs or Emails in Chatter Feed
   * @param records FeedItem records from trigger
   */
  public static void blockEmailsAndURLsInChatterFeed(List<FeedItem> records) {
    String urlPattern = '(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w\\.-]*)';
    String excludePattern = '@';

    for (FeedItem fi : records) {
      String bodyTextToCheck = String.valueOf(fi.Body);
      Boolean checkFlag = true;
      String returnString;

      if (fi.LinkUrl != null) {
        fi.addError(REMOVE_URL + ': ' + fi.LinkUrl);
      }

      while (checkFlag) {
        returnString = CommonUtil.filterStringUsingRegEx(
          urlPattern,
          bodyTextToCheck
        );

        checkFlag =
          String.valueOf(fi.Body).contains(excludePattern + returnString) ||
          String.valueOf(fi.Body).contains(returnString + excludePattern);
        if (checkFlag) {
          bodyTextToCheck = bodyTextToCheck.replace(returnString, '');
        }
      }
      if (returnString != bodyTextToCheck && returnString != null) {
        fi.addError(REMOVE_URL + ': ' + returnString);
      }
    }
  }

  /**
   * @description this method will filter the Interaction based on the parent id list and the recordtype ids set
   * @param interactionaIdList parent ids of Interaction for feed item/feed comment
   * @return relatedInteractionMap map of Interaction with Ids
   */
  public static Map<Id, Interaction> filteredInteractionMap(
    List<Id> interactionaIdList
  ) {
    Map<Id, Interaction> relatedInteractionMap = new Map<Id, Interaction>();
    relatedInteractionMap = new Map<Id, Interaction>(
      [
        SELECT Id, RecordTypeId
        FROM Interaction
        WHERE
          Id IN :interactionaIdList
          AND RecordTypeId IN :GetHelpConstants.STORE_CALL_MSG_INTERACTION_RECORTYPEIDS_SET
      ]
    );

    return relatedInteractionMap;
  }
}
