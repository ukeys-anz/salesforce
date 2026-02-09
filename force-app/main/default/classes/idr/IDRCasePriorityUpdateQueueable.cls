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
  Set<Id> updateAccountsEcfTrue;
  Set<Id> updateAccountsEcfFalse;

  /**
   * @description Constructor to accept Account Ids to query related Case records
   * @param accountsEcfTrue - filtered Account Ids where Account is flagged for ExtraCare
   * @param accountsEcfFalse - filtered Account Ids where Account is removed from ExtraCare
   */
  public IDRCasePriorityUpdateQueueable(
    Set<Id> accountsEcfTrue,
    Set<Id> accountsEcfFalse
  ) {
    updateAccountsEcfTrue = accountsEcfTrue;
    updateAccountsEcfFalse = accountsEcfFalse;
  }

  /**
   * @description Queueable apex execute method to query Case records and update the records.
   * @param context contex variable
   */
  public void execute(QueueableContext context) {
    Set<Id> filteredAccountsAll = new Set<Id>(updateAccountsEcfTrue);
    filteredAccountsAll.addAll(updateAccountsEcfFalse);
    List<Case> updatedCases = updateComplaintsPriority(
      CASE_REPOSITORY.queryRelatedCases(filteredAccountsAll)
    );

    // OCV Integration user has Read only access on related Cases so withoutSharing() has been used for DML
    List<Database.SaveResult> results = DML_REPOSITORY.doUpdate(
      updatedCases,
      new DmlConfig().allowPartial().withoutSharing()
    );
    sendInAppNotifications(
      filterSuccessfulVulnerableCases(updatedCases, results)
    );
  }

  /**
   * @description compare the case record's Priority field with Account's Extracare field to determine the Case Priority field value.
   * @param casesToUpdate - Account's related Case records
   * @return List<Case> - updated case records
   */
  @TestVisible
  private List<Case> updateComplaintsPriority(List<Case> casesToUpdate) {
    List<Case> updatedCases = new List<Case>();
    List<Case> casesForVulnerablePriority = ListUtil.filter(casesToUpdate)
      .equals(Case.AccountId, updateAccountsEcfTrue)
      .equals(Case.Priority, IDRConstants.CASE_PRIORITY_STANDARD)
      .toList();
    ListUtil.setField(
      casesForVulnerablePriority,
      Case.Priority,
      IDRConstants.CASE_PRIORITY_VULNERABLE
    );
    updatedCases.addAll(casesForVulnerablePriority);

    List<Case> casesForStandardPriority = ListUtil.filter(casesToUpdate)
      .notEquals(Case.AccountId, updateAccountsEcfTrue)
      .equals(Case.Priority, IDRConstants.CASE_PRIORITY_VULNERABLE)
      .toList();
    ListUtil.setField(
      casesForStandardPriority,
      Case.Priority,
      IDRConstants.CASE_PRIORITY_STANDARD
    );
    updatedCases.addAll(casesForStandardPriority);

    return updatedCases;
  }

  /**
   * @description compare the case record's Priority field with Account's Extracare field to determine the Case Priority field value.
   * @param updatedCases - List of all updated Cases
   * @param results - List of all DML results
   * @return List<Case> - List of filtered Vulnerable Cases which have been updated successfully.
   */
  private List<Case> filterSuccessfulVulnerableCases(
    List<Case> updatedCases,
    List<Database.SaveResult> results
  ) {
    Set<Id> vulnerableCaseIds = ListUtil.getIds(
      ListUtil.filter(updatedCases)
        .equals(Case.Priority, IDRConstants.CASE_PRIORITY_VULNERABLE)
        .toList(),
      Case.Id
    );
    Set<Id> vulnerableSuccessCaseIds = new Set<Id>();
    for (Database.SaveResult sr : results) {
      if (!sr.isSuccess() || !vulnerableCaseIds.contains(sr.getId())) {
        continue;
      }
      vulnerableSuccessCaseIds.add(sr.getId());
    }
    return ListUtil.filter(updatedCases)
      .equals(Case.Id, vulnerableSuccessCaseIds)
      .toList();
  }

  /**
   * @description Send in-app notifications for Case records which have been updated successfully.
   * @param casesToSendNotification - List of Cases to send in-app notifications for.
   */
  @TestVisible
  private void sendInAppNotifications(List<Case> casesToSendNotification) {
    CustomNotificationType cmosNotificationType = CommonUtil.getCustomNotificationTypeByName(
      'CMOS'
    );
    String subjectTemplate = 'Change in Customer\'s Extra Care Needs';
    String description = 'Change in customer\'s Extra Care needs on complaint {0} for {1}';
    for (Case cs : casesToSendNotification) {
      List<Object> lParameters = new List<Object>{
        cs.CaseNumber,
        cs.Account.Name
      };
      String strNotificationDesc = String.format(description, lParameters);
      CommonUtil.sendInAppNotification(
        new InAppNotificationWrapper(
          cmosNotificationType.Id,
          cs.Id,
          cs.OwnerId,
          subjectTemplate,
          strNotificationDesc
        )
      );
    }
  }
}
