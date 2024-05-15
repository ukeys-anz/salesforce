/**
 * @description Reusable code for Masking the feed comments and chatter feed where applicable
 * This class is created to get rid of tech debt i.e, repatative code which were used in ChatterFeedItemActions and ChatterFeedCommentTriggerHandler classes
 * @author Nilesh Kalal
 * @since 13/10/2023
 */
public with sharing class FeedMaskUtils {
  private static final string FILE_ERROR = 'Files cannot be shared via chatter. Please remove the file from your message before you post.';
  private static final string EXCESSIVE_LENGTH_ERROR = 'Error: Your post is too long';

  /**
   * @description Mask the comments where applicable.
   * @param records Feed records (FeedItem/FeedComment) from trigger
   */
  public static void maskDataInChatterFeedAndComment(List<Sobject> records) {
    List<Id> parentIdList = new List<Id>();
    List<Id> interactionIdList = new List<Id>();
    Map<Id, Interaction> relatedInteractionMap = new Map<Id, Interaction>();
    Map<Id, Case> relatedCaseMap = new Map<Id, Case>();
    Map<Id, Account> relatedAccMap = new Map<Id, Account>();

    prepareListOfParentAndInteractionIds(
      interactionIdList,
      parentIdList,
      records
    );
    if (!parentIdList.isEmpty()) {
      relatedCaseMap = getRelatedCaseMap(parentIdList);
      relatedAccMap = getRelatedAccMap(parentIdList);
    }
    //Fetching Interaction records based on the parent id list and recordtypeids list storing Store, Message and Call recordtypeids.
    if (!interactionIdList.isEmpty()) {
      relatedInteractionMap = filteredInteractionMap(interactionIdList);
    }
    for (Sobject record : records) {
      FeedItem feedItemObj;
      FeedComment feedCommentObj;
      String feedRecordBody;
      if (record.getSObjectType() == FeedItem.getSObjectType()) {
        feedItemObj = (FeedItem) record;
      } else if (record.getSObjectType() == FeedComment.getSObjectType()) {
        feedCommentObj = (FeedComment) record;
      }
      Id parentIdOfFeedRecord = (Id) record.get('ParentId');
      Case relatedCase = relatedCaseMap.get(parentIdOfFeedRecord);
      Account relatedAcc = relatedAccMap.get(parentIdOfFeedRecord);
      Interaction relatedInteraction = relatedInteractionMap.get(
        parentIdOfFeedRecord
      );

      if (
        (relatedCase != null &&
        CheckCaseRecordType.isANZPlusCaseType(relatedCase)) ||
        (relatedAcc != null &&
        relatedAcc.ANZx_Customer__c == true)
      ) {
        feedRecordBody = applyAnzxMaskingToBody(feedItemObj, feedCommentObj);
        if (TextUtils.reactiveLogging(feedRecordBody)) {
          String caseOrAccountLog = relatedCase != null
            ? 'CaseNumber: ' + relatedCase.CaseNumber
            : 'Account Name: ' + relatedAcc.Name;
          Logger.info(
            caseOrAccountLog +
              '; Body: ' +
              feedRecordBody +
              '; Reason for logging: User entered long digits without needing to mask'
          );
        }
      } else if (relatedInteraction != null) {
        feedRecordBody = applyAnzxMaskingToBody(feedItemObj, feedCommentObj);
      } else {
        if (record.getSObjectType() == FeedItem.getSObjectType()) {
          feedItemObj.Body = TextUtils.maskData(feedItemObj.Body);
        } else {
          feedCommentObj.CommentBody = TextUtils.maskData(
            feedCommentObj.CommentBody
          );
        }
      }
      if (
        (record.getSObjectType() == FeedItem.getSObjectType()
          ? feedItemObj.type
          : feedCommentObj.CommentType) == 'ContentPost' &&
        record.get('RelatedRecordId') != null
      ) {
        record.addError(FILE_ERROR);
      }
      if (record.getSObjectType() == FeedItem.getSObjectType()) {
        handleExcessiveChatterBody(feedItemObj, relatedCase);
      }
    }
  }

  /**
   * @description Prepare List of Parent Id's Of Feed Records (FeedItem/FeedComment)
   * @param interactionIdList list of interactions
   * @param parentIdList list of parent Id's of Feed Records
   * @param records list of Feed records
   */
  public static void prepareListOfParentAndInteractionIds(
    List<Id> interactionIdList,
    List<Id> parentIdList,
    List<Sobject> records
  ) {
    for (Sobject record : records) {
      Id parentIdOfFeedRecord = (Id) record.get('ParentId');
      if (parentIdOfFeedRecord != null) {
        if (parentIdOfFeedRecord.getSObjectType() == Interaction.sObjectType) {
          interactionIdList.add(parentIdOfFeedRecord);
        } else {
          parentIdList.add(parentIdOfFeedRecord);
        }
      }
    }
  }

  /**
   * @description This method will filter the Case based on the parent id list
   * @param parentIdList parent ids of Feed records
   * @return relatedCaseMap map of Case with Ids
   */
  public static Map<Id, Case> getRelatedCaseMap(List<Id> parentIdList) {
    Map<Id, Case> relatedCaseMap = new Map<Id, Case>();
    relatedCaseMap = new Map<Id, Case>(
      [
        SELECT Id, CaseNumber, RecordTypeId, Origin
        FROM Case
        WHERE Id IN :parentIdList
      ]
    );
    return relatedCaseMap;
  }

  /**
   * @description This method will filter the Account based on the parent id list
   * @param parentIdList parent ids of Feed records
   * @return relatedAccMap map of Account with Ids
   */
  public static Map<Id, Account> getRelatedAccMap(List<Id> parentIdList) {
    Map<Id, Account> relatedAccMap = new Map<Id, Account>();
    relatedAccMap = new Map<Id, Account>(
      [SELECT Id, Name, ANZx_Customer__c FROM Account WHERE Id IN :parentIdList]
    );
    return relatedAccMap;
  }

  /**
   * @description This method will filter the Interaction based on the parent id list and the recordtype ids set
   * @param interactionIdList parent ids of Interaction for feed item/feed comment
   * @return relatedInteractionMap map of Interaction with Ids
   */
  public static Map<Id, Interaction> filteredInteractionMap(
    List<Id> interactionIdList
  ) {
    Map<Id, Interaction> relatedInteractionMap = new Map<Id, Interaction>();
    relatedInteractionMap = new Map<Id, Interaction>(
      [
        SELECT Id, RecordTypeId
        FROM Interaction
        WHERE
          Id IN :interactionIdList
          AND RecordTypeId IN :GetHelpConstants.STORE_CALL_MSG_INTERACTION_RECORTYPEIDS_SET
      ]
    );
    return relatedInteractionMap;
  }

  /**
   * @description This method will apply masking on record body (anzx masking of 15 digits)
   * @param feedItemObj
   * @param feedCommentObj
   * @return feedItemObj.Body value of body field of feedItemObj
   * @return feedCommentObj.Body value of body field of feedCommentObj
   */
  public static String applyAnzxMaskingToBody(
    FeedItem feedItemObj,
    FeedComment feedCommentObj
  ) {
    if (feedItemObj != null) {
      feedItemObj.Body = TextUtils.maskDataAnzx(feedItemObj.Body);
      return feedItemObj.Body;
    }
    feedCommentObj.CommentBody = TextUtils.maskDataAnzx(
      feedCommentObj.CommentBody
    );
    return feedCommentObj.CommentBody;
  }

  /**
   * @description Handle Excessive Chatter Body
   * Limit of Case CommentBody is 4000 bytes. We are allowing small buffer
   * for the CreatedDate string which is pre-pended during conversion
   * @param record
   * @param relatedCase
   */
  public static void handleExcessiveChatterBody(
    FeedItem record,
    Case relatedCase
  ) {
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
