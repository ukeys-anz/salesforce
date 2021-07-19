/**
 * @author Olivier Saier
 * @since 12/2020
 * @description CMOS CaseComment Action methods
 * @group IDR(Internal Dispute Resolution) Igor Matkovic
 */
public without sharing class IDRCaseCommentActions {
  //list of platform events to publish
  @testVisible
  private static IDR_CaseComment_Event__e[] idrCaseCommentEscalationEvents;

  //max number of comments per platform event
  @testVisible
  private static final Integer COMMENTS_PER_EVENT = 28;

  /**
   * @description Escalate new CaseComments to CFMS.
   * @param records case comment records in the trigger context
   */
  public static void escalateNewCommentsToCFMS(CaseComment[] records) {
    CaseComment[] recordsToEscalate = getRecordsToEscalate(records);
    if (!recordsToEscalate.isEmpty()) {
      publishCaseComments(recordsToEscalate);
    }
  }

  /**
   * @description Escalate existing CaseComments to CFMS.
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values
   * @param records case in the trigger context
   */
  public static void escalateExistingCommentsToCFMS(
    Map<Id, SObject> oldMap,
    Case[] records
  ) {
    CaseComment[] recordsToEscalate = getRecordsToEscalate(oldMap, records);
    if (!recordsToEscalate.isEmpty()) {
      publishCaseComments(recordsToEscalate);
    }
  }

  /**
   * @description Allow an admin to retry escalation via anonymous Apex
   * @param commentIds Set of CaseComment Ids reported as having failed to escalate
   */
  public static void retryCommentEscalation(Set<Id> commentIds) {
    CaseComment[] recordsToEscalate = new List<CaseComment>();
    if (
      CaseComment.sObjectType.getDescribe().isQueryable() &&
      Schema.sObjectType.Case.fields.IDR_CFMS_Complaint_Number__c.isAccessible()
    ) {
      recordsToEscalate = [
        SELECT
          CommentBody,
          CreatedDate,
          CreatedBy.Email,
          CreatedBy.Name,
          Id,
          Parent.CaseNumber__c,
          Parent.IDR_CFMS_Complaint_Number__c
        FROM CaseComment
        WHERE Id IN :commentIds AND (NOT CreatedBy.Name LIKE '%CFMS%')
        ORDER BY CreatedDate ASC
      ];
    }
    if (!recordsToEscalate.isEmpty()) {
      publishCaseComments(recordsToEscalate);
    }
  }

  /**
   * @description Publish platform events to escalate CaseComment records to CFMS.
   * Each event's comments__c field will contain a JSON array of case comments.
   * A problem here is one hand we want to publish as few events as possible,
   * and on the other hand a single event containing all Trigger.New may overflow the comments__c max-length.
   * Solution is to consider at most ~4100 chars per comment and 131072 chars per event.comments__c hence split the CaseComment list in COMMENTS_PER_EVENT-comment events
   * @param records List of case comments to escalate
   */
  private static void publishCaseComments(CaseComment[] records) {
    idrCaseCommentEscalationEvents = new List<IDR_CaseComment_Event__e>();
    for (List<CaseComment> comments : splitCommentList(records)) {
      String json = buildCommentsPayload(comments);
      idrCaseCommentEscalationEvents.add(
        new IDR_CaseComment_Event__e(Comments__c = json)
      );
    }
    if (!idrCaseCommentEscalationEvents.isEmpty()) {
      List<Database.SaveResult> results = EventBus.publish(
        idrCaseCommentEscalationEvents
      );
      //log errors to application log
      lib_systemLog log = new lib_systemLog(
        'IDRCaseCommentActions',
        'publishCaseComments'
      );
      log.addDatabaseSaveResult(
        'IDR_CaseComment_Event__e',
        results,
        idrCaseCommentEscalationEvents
      );
      log.insertLogAsync();
    }
  }

  /**
   * @description Filter comments to escalate, typically from a list of new comments.
   * Only escalate if parent has a CFMS ID and if comment is not being inserted by CFMS
   * @param @param records case comment records in the trigger context
   * @return A list of comments to Escalate
   */
  private static CaseComment[] getRecordsToEscalate(CaseComment[] records) {
    if (
      CaseComment.sObjectType.getDescribe().isQueryable() &&
      Schema.sObjectType.Case.fields.IDR_CFMS_Complaint_Number__c.isAccessible()
    ) {
      return [
        SELECT
          CommentBody,
          CreatedDate,
          CreatedBy.Email,
          CreatedBy.Name,
          Id,
          Parent.CaseNumber__c,
          Parent.IDR_CFMS_Complaint_Number__c
        FROM CaseComment
        WHERE
          Id IN :records
          AND Parent.IDR_CFMS_Complaint_Number__c != NULL
          AND (NOT CreatedBy.Name LIKE '%CFMS%')
        ORDER BY CreatedDate ASC
      ];
    } else {
      return new List<CaseComment>();
    }
  }

  /**
   * @description Filter comments to escalate from a list of updated cases.
   * Only escalate if parent has been updated with a CFMS ID and if comment was not by CFMS service account
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values
   * @param records case in the trigger context
   * @return A list of comments to Escalate
   */
  private static CaseComment[] getRecordsToEscalate(
    Map<Id, SObject> oldMap,
    Case[] records
  ) {
    Case[] justEscalatedCases = new List<Case>();
    for (Case record : records) {
      if (
        String.isBlank(
          ((Case) oldMap.get(record.id)).IDR_CFMS_Complaint_Number__c
        ) && String.isNotBlank(record.IDR_CFMS_Complaint_Number__c)
      ) {
        justEscalatedCases.add(record);
      }
    }
    if (
      !justEscalatedCases.isEmpty() &&
      CaseComment.sObjectType.getDescribe().isQueryable() &&
      Case.sObjectType.getDescribe().isQueryable() &&
      Schema.sObjectType.Case.fields.IDR_CFMS_Complaint_Number__c.isAccessible()
    ) {
      return [
        SELECT
          CommentBody,
          CreatedDate,
          CreatedBy.Email,
          CreatedBy.Name,
          Id,
          Parent.CaseNumber__c,
          Parent.IDR_CFMS_Complaint_Number__c
        FROM CaseComment
        WHERE
          ParentId IN :justEscalatedCases
          AND Parent.IDR_CFMS_Complaint_Number__c != NULL
          AND (NOT CreatedBy.Name LIKE '%CFMS%')
        ORDER BY CreatedDate ASC
      ];
    } else {
      return new List<CaseComment>();
    }
  }

  /**
   * @description Split the lists of comments to be escalated into several lists,
   * one list per event to be sent (no comments on different cases in the same event and up to COMMENTS_PER_EVENT comments per event)
   * @param records list of comments to be escalated
   * @return A list containing lists of comments
   */
  private static List<List<CaseComment>> splitCommentList(
    CaseComment[] records
  ) {
    //split list case by case
    List<List<CaseComment>> caseByCaseComments = splitCommentListCaseByCase(
      records
    );
    //then split each list into smaller lists
    List<List<CaseComment>> lists = new List<List<CaseComment>>();
    for (List<CaseComment> comments : caseByCaseComments) {
      for (List<CaseComment> commentList : splitInSmallerLists(comments)) {
        lists.add(commentList);
      }
    }
    return lists;
  }

  /**
   * @description Split a list of comments into one list per case they're children of
   * We do this because CFMS' case notes API only accept a list of comments on the same case
   * @param records a list case comments
   * @return A list containing lists of case comments
   */
  private static List<List<CaseComment>> splitCommentListCaseByCase(
    CaseComment[] records
  ) {
    Set<Id> caseIds = new Set<Id>();
    for (CaseComment comment : records) {
      caseIds.add(comment.ParentId);
    }
    List<List<CaseComment>> commentsByCaseLists = new List<List<CaseComment>>();
    for (Id caseId : caseIds) {
      List<CaseComment> commentsByCaseList = new List<CaseComment>();
      Integer i = 0;
      while (i < records.size()) {
        if (records.get(i).ParentId == caseId) {
          commentsByCaseList.add(records.get(i));
          records.remove(i);
        } else {
          i++;
        }
      }
      commentsByCaseLists.add(commentsByCaseList);
    }
    return commentsByCaseLists;
  }

  /**
   * @description Split a list into smaller lists
   * @param records a list of up to 200 records
   * @return A list containing lists of up to COMMENTS_PER_EVENT records
   */
  @testVisible
  private static List<List<CaseComment>> splitInSmallerLists(
    CaseComment[] records
  ) {
    List<List<CaseComment>> smallLists = new List<List<CaseComment>>();
    for (
      Integer i = 0;
      i < Math.floor(records.size() / COMMENTS_PER_EVENT + 1);
      i++
    ) {
      List<CaseComment> smallList = new List<CaseComment>();
      for (Integer j = 0; j < COMMENTS_PER_EVENT; j++) {
        if (j < records.size() - COMMENTS_PER_EVENT * i) {
          smallList.add(records[j + COMMENTS_PER_EVENT * i]);
        } else {
          break;
        }
      }
      smallLists.add(smallList);
    }
    return smallLists;
  }

  /**
   * @description Build a JSON array (what Mulesoft will expect) out of a list of case comments
   * @param comments case comments to process
   * @return A JSON array of relevant case comment data
   */
  private static string buildCommentsPayload(CaseComment[] comments) {
    PayloadItem[] payload = new List<PayloadItem>();
    for (CaseComment c : comments) {
      PayloadItem p = new PayloadItem();
      p.commentBody = c.CommentBody;
      p.createdDate = c.CreatedDate;
      p.createdByEmail = c.CreatedBy.Email;
      p.createdByName = c.CreatedBy.Name;
      p.id = c.Id;
      p.parentCaseNumber = c.Parent.CaseNumber__c;
      p.parentComId = c.Parent.IDR_CFMS_Complaint_Number__c;
      payload.add(p);
    }
    String json = JSON.serialize(payload, false);
    return json;
  }

  /**
   * @description Model class representing a comment to be serialised
   */
  class PayloadItem {
    String commentBody;
    DateTime createdDate;
    String createdByEmail;
    String createdByName;
    String id;
    String parentCaseNumber;
    String parentComId;
  }
}
