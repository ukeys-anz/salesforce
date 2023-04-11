/**
 * @description ChatterFeedItemTriggerHandler to prevent chatter comments to be deleted, edited and sensitive info to be masked
 * @author Asteward Mikho
 * @since 07/2021
 */
public with sharing class ChatterFeedItemTriggerHandler extends Lib_TriggerHandler {
  private static final String REMOVE_URL = 'Please remove urls from chatter post';
  private static final String DELETE_ERROR = 'You do not have permission to delete this comment';
  private static final String EDIT_ERROR = 'You cannot edit feed items.';
  private static final string FILE_ERROR = 'Files cannot be shared via chatter. Please remove the file from your message before you post.';
  private static final string IMAGE_ERROR = 'Images cannot be shared via chatter. Please remove the image from your message before you post.';
  private static final string EXCESSIVE_LENGTH_ERROR = 'Error: Your post is too long';

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
    List<Id> parentIdList = new List<Id>();
    for (FeedItem record : (List<FeedItem>) records) {
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

    for (FeedItem record : (List<FeedItem>) records) {
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
    if (!FeatureManagement.checkPermission('DeleteChatter')) {
      for (FeedItem record : (List<FeedItem>) records) {
        record.addError(DELETE_ERROR);
      }
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

  public override void onBeforeInsert() {
    String urlPattern = '(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w\\.-]*)';
    String excludePattern = '@';

    for (FeedItem fi : (List<FeedItem>) records) {
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
