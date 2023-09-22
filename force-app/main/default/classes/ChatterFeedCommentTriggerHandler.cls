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
    List<Id> parentIdList = new List<Id>();

    //creating this list for storing interaction ids for the parent.
    List<Id> interactionaIdList = new List<Id>();

    Map<Id, Interaction> relatedInteractionMap = new Map<Id, Interaction>();

    for (FeedComment record : (List<FeedComment>) records) {
      if (record.parentId != null) {
        parentIdList.add(record.parentId);
        if (record.parentId.getSObjectType() == Interaction.sObjectType) {
          interactionaIdList.add(record.parentId);
        }
      }
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

    //Fetching Interaction records based on the parent id list and recordtypeids list storing Store, Message and Call recordtypeids.
    if (!interactionaIdList.isEmpty()) {
      relatedInteractionMap = ChatterFeedItemActions.filteredInteractionMap(
        interactionaIdList
      );
    }

    for (FeedComment record : (List<FeedComment>) records) {
      Case relatedCase = relatedCaseMap.get(record.parentId);
      Account relatedAcc = relatedAccMap.get(record.parentId);

      //Fetch Interaction Record for the feed comment
      Interaction relatedInteraction = relatedInteractionMap.get(
        record.parentId
      );

      if (
        (relatedCase != null &&
        CheckCaseRecordType.isANZPlusCaseType(relatedCase)) ||
        (relatedAcc != null &&
        relatedAcc.ANZx_Customer__c == true)
      ) {
        record.CommentBody = TextUtils.maskDataAnzx(record.CommentBody);
        if (TextUtils.reactiveLogging(record.CommentBody)) {
          if (relatedCase != null) {
            Logger.info(
              'CaseNumber: ' +
              relatedCase.CaseNumber +
              '; Comment Body: ' +
              record.CommentBody +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          } else {
            Logger.info(
              'CaseNumber: ' +
              relatedAcc.Name +
              '; Comment Body: ' +
              record.CommentBody +
              '; Reason for logging: User entered long digits without needing to mask'
            );
          }
        }
      } else if (relatedInteraction != null) {
        //Added this to mask the number if the feed comment is greater than 15 for Interaction Record same as we are doing for Account and Case.
        record.CommentBody = TextUtils.maskDataAnzx(record.CommentBody);
      } else {
        record.CommentBody = TextUtils.maskData(record.CommentBody);
      }
      if (
        record.CommentType == 'ContentPost' &&
        record.RelatedRecordId != null
      ) {
        record.addError(FILE_ERROR);
      }
    }
    Logger.saveLog();
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
