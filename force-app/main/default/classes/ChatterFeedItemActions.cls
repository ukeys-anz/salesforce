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
  private static final string EXCESSIVE_LENGTH_ERROR = 'Error: Your post is too long';

  /**
   * @description Mask the comments where applicable and Handle Excessive Chatter Body
   * @param records FeedItem records from trigger
   */
  public static void maskDataInChatterFeed(List<FeedItem> records) {
    List<Id> parentIdList = new List<Id>();
    for (FeedItem record : records) {
      parentIdList.add(record.parentId);
    }
    Map<Id, Case> relatedCaseMap = new Map<Id, Case>(
      [
        SELECT Id, CaseNumber, RecordTypeId, Origin
        FROM Case
        WHERE Id IN :parentIdList
      ]
    );
    Map<Id, Account> relatedAccMap = new Map<Id, Account>(
      [SELECT Id, Name, ANZx_Customer__c FROM Account WHERE Id IN :parentIdList]
    );

    for (FeedItem record : records) {
      Case relatedCase = relatedCaseMap.get(record.parentId);
      Account relatedAcc = relatedAccMap.get(record.parentId);

      if (
        (relatedCase != null &&
        CheckCaseRecordType.isANZPlusCaseType(relatedCase)) ||
        (relatedAcc != null &&
        relatedAcc.ANZx_Customer__c == true)
      ) {
        record.Body = TextUtils.maskDataAnzx(record.Body);
        if (TextUtils.reactiveLogging(record.Body)) {
          if (relatedCase != null) {
            Logger.info(
              'CaseNumber: ' +
              relatedCase.CaseNumber +
              '; Body: ' +
              record.Body +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          } else {
            Logger.info(
              'Account Name: ' +
              relatedAcc.Name +
              '; Body: ' +
              record.Body +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          }
        }
      } else {
        record.Body = TextUtils.maskData(record.Body);
      }

      if (record.type == 'ContentPost' && record.RelatedRecordId != null) {
        record.addError(FILE_ERROR);
      }

      // Handle Excessive Chatter Body
      // Limit of Case CommentBody is 4000 bytes. We are allowing small buffer
      // for the CreatedDate string which is pre-pended during conversion
      if (
        relatedCase != null &&
        relatedCase.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID
      ) {
        Blob bodyBlob = Blob.valueOf(record.Body);
        if (bodyBlob.size() >= 3970) {
          record.addError(EXCESSIVE_LENGTH_ERROR);
        }
      }
    }
    Logger.saveLog();
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
}
