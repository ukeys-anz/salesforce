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
    Set<Id> caseIds = new Set<Id>();
    Set<Id> accountIds = new Set<Id>();
    extractParentIds(records, caseIds, accountIds);
    Map<Id, Case> caseMap = queryCaseMap(caseIds);
    Map<Id, Account> accountMap = queryAccountMap(accountIds);

    for (Sobject record : records) {
      String feedType;
      String fieldToMask;

      if (record instanceof FeedItem) {
        feedType = (String) record.get('Type');
        fieldToMask = 'Body';
      } else if (record instanceof FeedComment) {
        feedType = (String) record.get('CommentType');
        fieldToMask = 'CommentBody';
      }

      preventFileSharing(record, feedType);
      preventExcessiveChatterBody(record, caseMap);
      maskFeedBody(record, fieldToMask, caseMap, accountMap);
    }
  }

  /**
   * @description Masks the feed body of a record, then log if related to ANZX case or account.
   * @param feedRecord The feed record whose feed body needs to be masked.
   * @param fieldToMask The name of the field to mask.
   * @param caseMap A map of related Case records
   * @param accountMap A map of related Account records
   */
  private static void maskFeedBody(
    SObject feedRecord,
    String fieldToMask,
    Map<Id, Case> caseMap,
    Map<Id, Account> accountMap
  ) {
    Id parentId = (Id) feedRecord.get('ParentId');
    Boolean isAnzxCase = CheckCaseRecordType.isANZPlusCaseType(
      caseMap.get(parentId)
    );
    Boolean isAnzxAccount = accountMap.get(parentId)?.ANZx_Customer__c == true;

    if (isAnzxAccount || isAnzxCase) {
      SObject parent = parentId.getSobjectType().newSObject(parentId);
      TextUtils.maskAndLog(feedRecord, fieldToMask, parent);
    } else {
      TextUtils.maskDataAnzx(feedRecord, fieldToMask);
    }
  }

  /**
   * @description Populate set of parent Case IDs and parent AccountIDs from chatter feeds
   * @param records The list of SObjects from which to extract parent record IDs.
   * @param caseIds The variable to hold extracted case IDs
   * @param accountIds The variable to hold extracted account IDs
   */
  private static void extractParentIds(
    List<SObject> records,
    Set<Id> caseIds,
    Set<Id> accountIds
  ) {
    String casePrefix = Schema.SObjectType.Case.getKeyPrefix();
    String accountPrefix = Schema.SObjectType.Account.getKeyPrefix();

    for (SObject record : records) {
      Id parentId = (Id) record.get('ParentId');
      String parentIdPrefix = parentId.toString().left(3);
      if (parentIdPrefix == casePrefix) {
        caseIds.add(parentId);
      } else if (parentIdPrefix == accountPrefix) {
        accountIds.add(parentId);
      }
    }
  }

  /**
   * @description Returns a map of Case records based on the provided set of IDs.
   * @param recordIds The set of IDs to query.
   * @return A map of Case records.
   */
  private static Map<Id, Case> queryCaseMap(Set<Id> recordIds) {
    if (recordIds.isEmpty()) {
      return new Map<Id, Case>();
    }
    return new Map<Id, Case>(
      [SELECT Id, RecordTypeId FROM Case WHERE Id IN :recordIds]
    );
  }

  /**
   * @description Returns a map of Account records based on the provided set of IDs.
   * @param recordIds The set of IDs to query.
   * @return A map of Account records.
   */
  private static Map<Id, Account> queryAccountMap(Set<Id> recordIds) {
    if (recordIds.isEmpty()) {
      return new Map<Id, Account>();
    }
    return new Map<Id, Account>(
      [SELECT Id, ANZx_Customer__c FROM Account WHERE Id IN :recordIds]
    );
  }

  /**
   * @description Handle Excessive Chatter Body
   * Limit of Case CommentBody is 4000 bytes. We are allowing small buffer
   * for the CreatedDate string which is pre-pended during conversion
   * @param feedRecord
   * @param caseMap A map of related Case records
   */
  private static void preventExcessiveChatterBody(
    SObject feedRecord,
    Map<Id, Case> caseMap
  ) {
    if (!(feedRecord instanceof FeedItem)) {
      return;
    }
    FeedItem record = (FeedItem) feedRecord;
    if (CheckCaseRecordType.isANZPlusComplaint(caseMap.get(record.ParentId))) {
      Blob bodyBlob = Blob.valueOf(record.Body);
      if (bodyBlob.size() >= 3970) {
        record.addError(EXCESSIVE_LENGTH_ERROR);
      }
    }
  }

  /**
   * @description Checks and prevent file shared via chatter
   * @param feedRecord The SObject representing the feed record.
   * @param feedType The type of the feed.
   */
  private static void preventFileSharing(SObject feedRecord, String feedType) {
    if (
      feedType == 'ContentPost' &&
      feedRecord.get('RelatedRecordId') != null
    ) {
      feedRecord.addError(FILE_ERROR);
    }
  }
}
