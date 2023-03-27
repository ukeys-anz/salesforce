/**
 * @author Boobalakrishnan Duraisamy
 * @since 12/2020
 * @description  ContentDocumentLinkTriggerHandler is the handler class for Content Document Link Trigger which extends Lib_TriggerHandler the trigger framework used.
 * without sharing: used to query the cases related to the Content Document as the banker may not have to all case records
 * @runTests ContentDocumentLinkTriggerHandlerTest
 */
public without sharing class ContentDocumentLinkTriggerHandler extends Lib_TriggerHandler {
  /**
   * @description onAfterInsert to manage after insert actions to handle notifications
   */
  public override void onAfterInsert() {
    manageNotification((List<ContentDocumentLink>) records);
  }

  public override void onBeforeDelete() {
    logFileDelete((List<ContentDocumentLink>) records);
  }
  /**
   * @description Assesses whether or not to generate a log (generate only for CMOS complaint and enquiry) and creates a log entry.
   * @param records ContentDocumentLink records in current trigger context
   */
  public void logFileDelete(List<ContentDocumentLink> records) {
    List<ContentDocumentLink> docList = new List<ContentDocumentLink>();
    Set<Id> linkedEntityIdList = new Set<Id>();
    Set<Id> linkIdList = new Set<Id>();

    Map<Id, Case> caseMap = getCaseRecords(records);
    Map<Id, Case> mpUpdateCases = new Map<Id, Case>();

    if (!caseMap.isEmpty()) {
      Case oCase;
      for (ContentDocumentLink record : (List<ContentDocumentLink>) records) {
        if (
          record.LinkedEntityId.getSobjectType() ==
          Schema.getGlobalDescribe().get('Case') &&
          (oCase = caseMap.get(record.LinkedEntityId)) != null &&
          (oCase.RecordTypeId == IDRConstants.GENERAL_INQUIRY_CMOS_RT_ID ||
          IDRCaseActions.isIDRComplaintType(oCase))
        ) {
          linkedEntityIdList.add(oCase.Id);
          linkIdList.add(record.Id);
        }
      }
      if (ContentDocumentLink.SObjectType.getDescribe().isQueryable()) {
        docList = [
          SELECT
            Id,
            ContentDocument.LatestPublishedVersion.Document_Flag__c,
            ContentDocument.Title,
            LinkedEntityId,
            ContentDocument.CreatedDate,
            ContentDocument.Owner.Name,
            ContentDocument.FileExtension,
            ContentDocument.LatestPublishedVersion.FileType,
            ContentDocument.LatestPublishedVersion.Date_of_Document__c,
            ContentDocument.LatestPublishedVersion.Party_who_sent_created_file__c,
            ContentDocument.LatestPublishedVersion.Document_Category__c,
            ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId IN :linkedEntityIdList AND Id IN :linkIdList
          ORDER BY
            ContentDocument.CreatedDate DESC,
            ContentDocument.Title ASC,
            ContentDocument.FileExtension ASC
        ];
      }

      for (ContentDocumentLink record : docList) {
        String objectAPIName = 'ContentDocumentLink';
        String strDate = String.valueOf(Date.today());
        String strUserName = UserInfo.getName();
        String strDocTitle = (record.ContentDocument.Title == null)
          ? ''
          : record.ContentDocument.Title;
        String strDocCategory = (record.ContentDocument.LatestPublishedVersion.Document_Category__c ==
          null)
          ? ''
          : record.ContentDocument.LatestPublishedVersion.Document_Category__c;

        String errorDescription =
          'Doc Deleted: ' +
          (oCase = caseMap.get(record.LinkedEntityId))?.CaseNumber +
          ', ' +
          strUserName +
          ', ' +
          strDocTitle.abbreviate(50) +
          ', ' +
          record.ContentDocumentId +
          ', ' +
          strDate +
          ', ' +
          record.ContentDocument.LatestPublishedVersion.FileType;

        Logger.error(errorDescription, record.Id);
        if ( oCase != null ) {
          // CC-1999 Update Case causes LastModifiedDate to be updated even if no fields are changed.
          mpUpdateCases.put(oCase.Id, oCase);
        }
      }
      Logger.saveLog();
      if ( mpUpdateCases.size() > 0 &&
          Case.SObjectType.getDescribe().isUpdateable()) {
        update mpUpdateCases.values();
      }
    }
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
    Task[] assiTasks = new List<Task>();
    Map<Id, Case> mpUpdateCases = new Map<Id, Case>();

    for (ContentDocumentLink record : (List<ContentDocumentLink>) records) {
      if (
        record.LinkedEntityId.getSobjectType() ==
        Schema.getGlobalDescribe().get('Case') &&
        contentDocMap.containsKey(record.ContentDocumentId) &&
        (oCase = caseMap.get(record.LinkedEntityId)) != null
      ) {
        if (
          oCase.OwnerId !=
          contentDocMap.get(record.ContentDocumentId).OwnerId &&
          UserInfo.getFirstName() != IDRConstants.EMAIl_USER_FNAME &&
          IDRCaseActions.isIDRComplaintType(oCase) &&
          !(oCase.Status == 'Closed' ||
          oCase.Status == 'Withdrawn' ||
          oCase.Status == 'Resolved')
        ) {
          String customerName = (oCase.IDR_NC_First_Name__c != null ||
            oCase.IDR_NC_Last_Name__c != null)
            ? ('Customer Name : ' +
              (oCase.IDR_NC_First_Name__c != null
                ? oCase.IDR_NC_First_Name__c + ' '
                : '') +
              (oCase.IDR_NC_Last_Name__c != null
                ? oCase.IDR_NC_Last_Name__c
                : ''))
            : '';
          String subjectStr = (customerName != '')
            ? ('New File added by ' +
              UserInfo.getName() +
              ' on case ' +
              oCase.CaseNumber +
              ' ' +
              customerName)
            : ('New File added by ' +
              UserInfo.getName() +
              ' on case ' +
              oCase.CaseNumber);
          assiTasks.add(IDRTaskActions.createAssignmentTask(oCase, subjectStr));
        }

        if (
          oCase.Status == 'Closed' ||
          oCase.Status == 'Withdrawn' ||
          oCase.Status == 'Resolved'
        ) {
          caseCommentList.add(
            createCaseCloseNotification(
              record,
              contentDocMap.get(record.ContentDocumentId)
            )
          );
        }
        // CC-1999 Update Case causes LastModifiedDate to be updated even if no fields are changed.
        mpUpdateCases.put(oCase.Id, oCase);
      }
    }

    if (!assiTasks.isEmpty()) {
      //insert Assignment Tasks on New File Attached
      IDRTaskActions.insertAssignmentTask(assiTasks);
    }
    try {
      if (!caseCommentList.isEmpty()) {
        insert caseCommentList;
      }
    } catch (Exception err) {
      Logger.error(
        'Error in creating Case Comment when attachment is added for the existing Case :' +
          oCase.Id +
          err.getMessage(),
        err
      );
      Logger.saveLog();
    }
    if ( mpUpdateCases.size() > 0 &&
        Case.SObjectType.getDescribe().isUpdateable()) {
      update mpUpdateCases.values();
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
      SELECT
        Id,
        RecordTypeId,
        CaseNumber,
        OwnerId,
        Status,
        IDR_NC_First_Name__c,
        IDR_NC_Last_Name__c
      FROM Case
      WHERE Id IN :caseIds AND Owner.IsActive = TRUE
    ]) {
      getCaseMap.put(c.Id, c);
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
   * @param customerName customer name from case record
   * @return IDRBankerNotificationWrapper new instance of wrapper class
   */
  private static IDRBankerNotificationWrapper createNotification(
    Case record,
    ContentDocument cdRecord,
    String customerName
  ) {
    IDRBankerNotificationWrapper wrapper = new IDRBankerNotificationWrapper(
      cdRecord,
      new List<Id>{ record.OwnerId },
      record.CaseNumber,
      customerName + 'New File added by ' + UserInfo.getName(),
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
      IsPublished = true,
      ParentId = cdlRecord.LinkedEntityId,
      CommentBody = 'New attachment added; ' + cdRecord.Title
    );
    return caseCommentObject;
  }
}
