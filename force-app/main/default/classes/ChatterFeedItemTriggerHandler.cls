/**
 * @description ChatterFeedItemTriggerHandler to prevent chatter comments to be deleted, edited and sensitive info to be masked
 * @author Asteward Mikho
 * @since 07/2021
 */
public with sharing class ChatterFeedItemTriggerHandler extends Lib_TriggerHandler {
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
      [SELECT Id, CaseNumber, RecordTypeId FROM Case WHERE Id IN :parentIdList]
    );
    Map<Id, Account> relatedAccMap = new Map<Id, Account>(
      [SELECT Id, Name, ANZx_Customer__c FROM Account WHERE Id IN :parentIdList]
    );

    for (FeedItem record : (List<FeedItem>) records) {
      Case relatedCase = relatedCaseMap.get(record.parentId);
      Account relatedAcc = relatedAccMap.get(record.parentId);

      if (
        (relatedCase != null &&
        GetHelpCaseActionsHelper.isANZPlusCaseType(relatedCase)) ||
        (relatedAcc != null &&
        relatedAcc.ANZx_Customer__c == true)
      ) {
        record.Body = TextUtils.maskDataAnzx(record.Body);
        if (TextUtils.reactiveLogging(record.Body)) {
          lib_systemLog log = new lib_systemLog(
            'ChatterFeedItemTriggerHandler',
            'onApplyDefaults'
          );
          if (relatedCase != null) {
            log.info(
              'CaseNumber: ' +
              relatedCase.CaseNumber +
              '; Body: ' +
              record.Body +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          } else {
            log.info(
              'Account Name: ' +
              relatedAcc.Name +
              '; Body: ' +
              record.Body +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          }
          log.publishEvent();
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
}
