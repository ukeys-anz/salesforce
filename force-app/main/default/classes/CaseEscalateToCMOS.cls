/**
 * @author Mouhamed "Mo" Assafiri
 * @since Sept 2021
 * @description Escalates Cases from ANZx to CMOS IDR EveryDay Banking
 */

public with sharing class CaseEscalateToCMOS {
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
    record = updateCaseInfo(record);
    record.IDR_Escalation_Reason__c = MANUAL_ESCALATION_REASON;

    Database.SaveResult updatingRecord = Database.update(record);

    if (updatingRecord.isSuccess()) {
      escalateChatterToComments(record);
      return true;
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
   * @return The record that was updated
   */
  private static Case updateCaseInfo(Case record) {
    record.OwnerId = queue.Id;
    record.Status = IDRConstants.ESCALATED_STATUS;

    record.RecordTypeId = IDRConstants.CUSTOMER_COMPLAINT_RT_ID;

    if (
      Case.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.Case.fields.Customer_Notification_Consent__c.isAccessible() &&
      Schema.SObjectType.Account.fields.Source_System_ID__c.isAccessible()
    ) {
      Case caseData = [
        SELECT Customer_Notification_Consent__c, Account.Source_System_ID__c
        FROM Case
        WHERE Id = :Record.Id
      ];

      record.IDR_Customer_Number__c = record.Account.Source_System_ID__c;
      record.IDR_Customer_Notification__c = (Boolean) (caseData.Customer_Notification_Consent__c ==
      'Yes');

      record.IDR_SwitchOff_Customer_Notification__c = (caseData.Customer_Notification_Consent__c ==
      'No');
    }

    return record;
  }

  /**
   * @description Auto Escalation cases that meet the criteria for escalation will be moved to CMOS
   * @param records A List of records which are tested to see if they need to be escalated
   */
  public static void beforeUpdateCaseToCMOS(List<Case> records) {
    for (Case record : records) {
      if (
        record.RecordTypeId == GetHelpCaseActions.COMPLAINT_ID &&
        record.SLA_Status__C == BREACHED_STATUS &&
        !record.isClosed
      ) {
        record = updateCaseInfo(record);
        record.IDR_Escalation_Reason__c = DAY_5_ESCALATION_REASON;

        escalateChatterToComments(record);
      }
    }
  }

  /**
   * @description Queries Chatter for the case and duplicates them to Case Comments
   * @param record The record that will be updated
   */
  public static void escalateChatterToComments(Case record) {
    if (
      FeedItem.SObjectType.getDescribe().isAccessible() &&
      Schema.SObjectType.FeedItem.fields.Body.isAccessible() &&
      Schema.SObjectType.FeedItem.fields.CreatedDate.isAccessible()
    ) {
      List<CaseComment> newComments = new List<CaseComment>{};

      for (FeedItem comment : [
        SELECT Id, Body, CreatedDate, ParentId
        FROM FeedItem
        WHERE Type = 'TextPost' AND ParentId = :record.Id
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

      if (
        Schema.sObjectType.CaseComment.fields.CommentBody.isCreateable() &&
        Schema.sObjectType.CaseComment.fields.IsPublished.isCreateable()
      ) {
        try {
          if (!newComments.isEmpty()) {
            insert newComments;
          }
        } catch (Exception e) {
          Lib_SystemLog.createSingleLogAsync(
            CaseEscalateToCMOS.class.getName(),
            'escalateChatterToComments',
            'CMOSESC-002',
            e.getMessage()
          );
        }
      }
    }
  }
}
