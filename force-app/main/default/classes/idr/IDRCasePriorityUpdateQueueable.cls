/**
 * @author CMOS
 * @since 08/2025
 * @description Update relevant Customer Complaint records associated with Accounts flagged for Extra Care to ensure complaints from vulnerable customers are prioritized appropriately
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCasePriorityUpdateQueueable implements Queueable {
  static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  static final IDRCaseActionsRepository CASE_REPOSITORY = (IDRCaseActionsRepository) Lib_InstanceProvider.forType(
    IDRCaseActionsRepository.class
  );
  Set<Id> sEcfChangedAccountIds;

  /**
   * @description Constructor to accept Account Ids to query related Case records
   * @param sFilteredAccountIds - filtered Account Ids to query related Case records
   */
  public IDRCasePriorityUpdateQueueable(Set<Id> sFilteredAccountIds) {
    sEcfChangedAccountIds = sFilteredAccountIds;
  }

  /**
   * @description Queueable apex execute method to query Case records and update the records.
   * @param context contex variable
   */
  public void execute(QueueableContext context) {
    Map<Id, Case> mCasesToUpdate = new Map<Id, Case>(
      CASE_REPOSITORY.queryRelatedCases(sEcfChangedAccountIds)
    );
    List<Case> lCasesToUpdate = updateComplaintsPriority(
      mCasesToUpdate.values()
    );

    // OCV Integration user has Read only access on related Cases so withoutSharing() has been used for DML
    List<Database.SaveResult> results = DML_REPOSITORY.doUpdate(
      lCasesToUpdate,
      new DmlConfig().allowPartial().withoutSharing()
    );
    CustomNotificationType oNotificationType = CommonUtil.getCustomNotificationTypeByName(
      'CMOS'
    );
    sendInAppNotifications(results, mCasesToUpdate, oNotificationType.Id);
  }

  /**
   * @description compare the case record's Priority field with Account's Extracare field to determine the Case Priority field value.
   * @param lCasesToUpdate - Account's related Case records
   * @return List<Case> - updated case records
   */
  @TestVisible
  private List<Case> updateComplaintsPriority(List<Case> lCasesToUpdate) {
    List<Case> lUpdatedCases = new List<Case>();
    for (Case updateCase : lCasesToUpdate) {
      if (
        IDRConstants.ECF_FLAG_TRUE.contains(
          updateCase.Account.ExtraCareTimePeriod__c
        ) && updateCase.Priority == IDRConstants.CASE_PRIORITY_STANDARD
      ) {
        updateCase.Priority = IDRConstants.CASE_PRIORITY_VULNERABLE;
        lUpdatedCases.add(updateCase);
        continue;
      }
      if (
        !IDRConstants.ECF_FLAG_TRUE.contains(
          updateCase.Account.ExtraCareTimePeriod__c
        ) && updateCase.Priority == IDRConstants.CASE_PRIORITY_VULNERABLE
      ) {
        updateCase.Priority = IDRConstants.CASE_PRIORITY_STANDARD;
        lUpdatedCases.add(updateCase);
      }
    }
    return lUpdatedCases;
  }

  /**
   * @description Send in-app notifications for Case records which have been updated successfully.
   * @param results - DML results of Case update
   * @param mCasesToUpdate - map of Account's related Case records to fetch OwnerId, CaseNumber and Account Name
   * @param oNotificationTypeId - CMOS Custom Notification Id to be used for sending notifications
   */
  @TestVisible
  private void sendInAppNotifications(
    List<Database.SaveResult> results,
    Map<Id, Case> mCasesToUpdate,
    String oNotificationTypeId
  ) {
    String subjectTemplate = 'Change in Customer\'s Extra Care Needs';
    String description = 'Change in customer\'s Extra Care needs on complaint {0} for {1}';
    for (Database.SaveResult sr : results) {
      if (!sr.isSuccess()) {
        continue;
      }
      List<Object> lParameters = new List<Object>{
        mCasesToUpdate.get(sr.getId()).CaseNumber,
        mCasesToUpdate.get(sr.getId()).Account.Name
      };
      String strNotificationDesc = String.format(description, lParameters);
      CommonUtil.sendInAppNotification(
        new InAppNotificationWrapper(
          oNotificationTypeId,
          sr.getId(),
          mCasesToUpdate.get(sr.getId()).OwnerId,
          subjectTemplate,
          strNotificationDesc
        )
      );
    }
  }
}
