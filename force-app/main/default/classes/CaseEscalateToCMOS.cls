/**
 * @author Mouhamed "Mo" Assafiri
 * @since Sept 2021
 * @description Escalates Cases from ANZx to CMOS IDR EveryDay Banking
 * Set the whole class to without sharing since we need to enable the user to generate
 * Case comments regardless of whether current user is the owner or not
 */

public without sharing class CaseEscalateToCMOS {
  private static final String QUEUE_DEV_NAME = 'IDR_Everyday_Banking';
  private static final String QUEUE_TYPE = 'Queue';
  private static final String BREACHED_STATUS = 'Breached';

  @testVisible
  private static final String DAY_5_ESCALATION_REASON = 'Day 5 auto escalation';

  @testVisible
  private static final String MANUAL_ESCALATION_REASON = 'Manually Escalated';

  @testVisible
  private static Group queue = [
    SELECT Id
    FROM group
    WHERE developername = :QUEUE_DEV_NAME AND Type = :QUEUE_TYPE
  ];

  /**
   * @description Manually Triggers the Case to Escalate to CMOS
   * @param record The record that will be escalated to CMOS
   * @return boolean
   */
  public static Boolean manualEscalateCaseToCMOS(Case record) {
    if (
      Case.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Case.fields.Customer_Notification_Consent__c.isAccessible() &&
      Schema.SObjectType.Account.fields.Source_System_ID__c.isAccessible()
    ) {
      Case caseData = [
        SELECT
          Customer_Notification_Consent__c,
          Account.Source_System_ID__c,
          OwnerId
        FROM Case
        WHERE Id = :record.Id
      ];

      record = updateCaseInfo(record, caseData);
    }
    record.IDR_Escalation_Reason__c = MANUAL_ESCALATION_REASON;

    Database.SaveResult updatingRecord = Database.update(record);

    if (updatingRecord.isSuccess()) {
      List<Case> records = new List<Case>{ record };

      return publishChatterToCaseComments(
        prepareChatterToCaseComments(records)
      );
    }

    String errorMessage = 'Failed Manual Escalation from ANZx to CMOS / CRC: ';
    for (Database.Error err : updatingRecord.getErrors()) {
      errorMessage += err;
    }

    Lib_SystemLog.createSingleLogAsync(
      CaseEscalateToCMOS.class.getName(),
      'manualEscalateCaseToCMOS',
      'CMOSESC-001',
      errorMessage
    );

    return false;
  }

  /**
   * @description Handles the field changes that happen for both manual and auto-escalated cases
   * @param record The record that will be updated
   * @param caseData the same case but contains more information
   * @return The record that was updated
   */
  private static Case updateCaseInfo(Case record, Case caseData) {
    record.OwnerId = queue.Id;
    record.Status = IDRConstants.ESCALATED_STATUS;
    record.SLA_Status__C = BREACHED_STATUS;

    record.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;

    record.Original_Case_Owner__c = caseData.OwnerId;
    record.IDR_Customer_Number__c = caseData.Account.Source_System_ID__c;
    record.IDR_Customer_Notification__c = (Boolean) (caseData.Customer_Notification_Consent__c ==
    'Yes');
    record.IDR_SwitchOff_Customer_Notification__c = (caseData.Customer_Notification_Consent__c ==
    'No');

    return record;
  }

  /**
   * @description Auto Escalation cases that meet the criteria for escalation will be moved to CMOS
   * @param records A List of records which are tested to see if they need to be escalated
   */
  public static void beforeUpdateCaseToCMOS(List<Case> records) {
    List<Case> recordsChatterUpdate = new List<Case>{};
    Map<Id, Case> caseDataMap = new Map<Id, Case>();
    if (
      Case.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Case.fields.Customer_Notification_Consent__c.isAccessible() &&
      Schema.SObjectType.Account.fields.Source_System_ID__c.isAccessible()
    ) {
      caseDataMap = new Map<Id, Case>(
        [
          SELECT
            Customer_Notification_Consent__c,
            Account.Source_System_ID__c,
            OwnerId
          FROM Case
          WHERE Id IN :records
        ]
      );
    }

    for (Case record : records) {
      if (
        record.RecordTypeId == GetHelpConstants.COMPLAINT_RT_ID &&
        record.SLA_Status__C == BREACHED_STATUS &&
        !record.isClosed
      ) {
        Case caseData = CaseDataMap.get(record.Id);
        record = updateCaseInfo(record, caseData);
        if (String.isEmpty(record.IDR_Escalation_Reason__c)) {
          record.IDR_Escalation_Reason__c = DAY_5_ESCALATION_REASON;
        }

        recordsChatterUpdate.add(record);
      }
    }

    publishChatterToCaseComments(
      prepareChatterToCaseComments(recordsChatterUpdate)
    );
  }

  /**
   * @description Prepares the Chatter to Case Comments into a List of case comments
   * @param records A List of Cases where Chatter comments need to change to Case Comments
   * @return newComments - A List of CaseComments which can be bulk inserted
   */
  public static List<CaseComment> prepareChatterToCaseComments(
    List<Case> records
  ) {
    List<CaseComment> newComments = new List<CaseComment>{};

    if (
      FeedItem.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.FeedItem.fields.Body.isAccessible() &&
      Schema.SObjectType.FeedItem.fields.CreatedDate.isAccessible()
    ) {
      try {
        Set<Id> resultIds = (new Map<Id, SObject>(records)).keySet();
        for (FeedItem comment : [
          SELECT Id, Body, CreatedDate, ParentId
          FROM FeedItem
          WHERE Type = 'TextPost' AND ParentId = :resultIds
        ]) {
          String text =
            '[' +
            comment.CreatedDate.format('d MMMM yy - K:m a') +
            '] ' +
            comment.Body.stripHtmlTags();

          newComments.add(
            new CaseComment(
              CommentBody = text,
              IsPublished = true,
              ParentId = comment.ParentId
            )
          );
        }
      } catch (Exception e) {
        Lib_SystemLog.createSingleLogAsync(
          CaseEscalateToCMOS.class.getName(),
          'prepareChatterToCaseComments',
          'CMOSESC-005',
          e.getMessage()
        );
      }
    }
    return newComments;
  }

  /**
   * @description Inserts a CaseComment List
   * @param comments A List<CaseComment> object which contains all the Case Comments that need to be inserted
   * @return Boolean - True/False if the operation was successful
   */
  public static Boolean publishChatterToCaseComments(
    List<CaseComment> comments
  ) {
    if (!comments.isEmpty()) {
      if (
        Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() &&
        Schema.sObjectType.CaseComment.fields.IsPublished.isCreateable()
      ) {
        try {
          insert comments;
        } catch (Exception e) {
          Lib_SystemLog.createSingleLogAsync(
            CaseEscalateToCMOS.class.getName(),
            'publishChatterToCaseComments',
            'CMOSESC-002',
            e.getMessage()
          );

          return false;
        }
      }
    }

    return true;
  }
}
