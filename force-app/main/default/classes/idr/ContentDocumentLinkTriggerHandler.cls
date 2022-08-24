/**
 * @author Boobalakrishnan Duraisamy
 * @since 12/2020
 * @description  ContentDocumentLinkTriggerHandler is the handler class for Content Document Link Trigger which extends Lib_TriggerHandler the trigger framework used.
 */
public without sharing class ContentDocumentLinkTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onAfterInsert to manage after insert actions to handle notifications
   */
  public override void onAfterInsert() {
    manageNotification((List<ContentDocumentLink>) records);
  }

  /**
   * @description Assesses whether or not to generate a banker notification
   * @param records ContentDocumentLink records in current trigger context
   */
  public static void manageNotification(List<ContentDocumentLink> records) {
    List<IDRBankerNotificationWrapper> wrapperList = new List<IDRBankerNotificationWrapper>();
    List<CaseComment> caseCommentList = new List<CaseComment>();
    Map<Id, Case> caseMap = getCaseRecords(records);
    Map<Id, ContentDocument> contentDocMap = getContentDocRecords(records);
    Case oCase;

    for (ContentDocumentLink record : (List<ContentDocumentLink>) records) {
      if (record.LinkedEntityId.getSobjectType() ==
          Schema.getGlobalDescribe().get('Case') &&
          contentDocMap.containsKey(record.ContentDocumentId) &&
          (oCase = caseMap.get(record.LinkedEntityId)) != null
         ) {
        if (
        oCase.OwnerId !=
        contentDocMap.get(record.ContentDocumentId).OwnerId &&
        IDRCaseActions.isIDRComplaintType(oCase)
        ) {
            wrapperList.add(
              createNotification(
              oCase,
              contentDocMap.get(record.ContentDocumentId)
            )
          ); 
        }
        if (
        oCase.Status == 'Closed'
        ) {
            caseCommentList.add(
            createCaseCloseNotification(
            record,
            contentDocMap.get(record.ContentDocumentId)
          )
         );
        } 
      }
    }


    if (!wrapperList.isEmpty()) {
      IDRBankerNotificationBuilder.sendNotification(wrapperList);
    }
    try{
    if (!caseCommentList.isEmpty()) {
      insert caseCommentList;
    }
    }
    catch (Exception err) {
      Lib_SystemLog log = new Lib_SystemLog(
        ContentDocumentLinkTriggerHandler.class.getName(),
        'manageNotification'
      );
      log.error(
        'DMLException',
        'Error in creating Case Comment when attachment is added for the existing Case :' +
        oCase.Id +
        err.getMessage()
      );
      log.publishEvent();
    }
  }

  /**
   * @description get case record details associated with the content document link
   * @param records content document link records from the trigger
   * @return getCaseMap case map
   */
  private static Map<Id, Case> getCaseRecords(
    List<ContentDocumentLink> records
  ) {
    Set<Id> caseIds = new Set<Id>();
    Map<Id, Case> getCaseMap = new Map<Id, Case>();

    for (ContentDocumentLink record : (List<ContentDocumentLink>) records) {
      if (
        record.LinkedEntityId.getSobjectType() ==
        Schema.getGlobalDescribe().get('Case')
      ) {
        caseIds.add(record.LinkedEntityId);
      }
    }

    for (Case c : [
      SELECT Id, RecordTypeId, CaseNumber, OwnerId, Status
      FROM Case
      WHERE Id IN :caseIds AND Owner.isActive = TRUE
    ]) {
      getCaseMap.put(c.id, c);
    }
    return getCaseMap;
  }

  /**
   * @description get content document record details associated with the content document link
   * @param records content document link records from the trigger
   * @return contentDocMap content document map
   */
  private static Map<Id, ContentDocument> getContentDocRecords(
    List<ContentDocumentLink> records
  ) {
    Set<Id> contentDocIds = new Set<Id>();
    Map<Id, ContentDocument> contentDocMap = new Map<Id, ContentDocument>();

    for (ContentDocumentLink record : (List<ContentDocumentLink>) records) {
      if (
        record.LinkedEntityId.getSobjectType() ==
        Schema.getGlobalDescribe().get('Case')
      ) {
        contentDocIds.add(record.ContentDocumentId);
      }
    }

    for (ContentDocument cd : [
      SELECT Id, OwnerId, Title
      FROM ContentDocument
      WHERE Id IN :contentDocIds
    ]) {
      contentDocMap.put(cd.Id, cd);
    }

    return contentDocMap;
  }
  /**
   * @description Builds a notification using IDRBankerNotificationWrapper class
   * @param record case record from the trigger
   * @param cdRecord contentDocument record from the trigger
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  private static IDRBankerNotificationWrapper createNotification(
    Case record,
    ContentDocument cdRecord
  ) {
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      cdRecord,
      new List<Id>{ record.OwnerId },
      record.CaseNumber,
      'New File added by ' + UserInfo.getName(),
      record
    );
    return wrapper;
  }

  /**
   * @description Builds a notification using CaseComment
   * @param cdlRecord ContentDocumentLink record from the trigger
   * @param cdRecord ContentDocument record from the trigger
   * @return caseCommentObject
   */ 
  private static CaseComment createCaseCloseNotification(
    ContentDocumentLink cdlRecord, 
    ContentDocument cdRecord
   ) {
       CaseComment caseCommentObject = new CaseComment(
       isPublished = true,
       ParentId = cdlRecord.LinkedEntityId,
       commentBody = 'New attachment ' + cdRecord.Title + ' has been added to the case');
       return caseCommentObject;
   }
}
