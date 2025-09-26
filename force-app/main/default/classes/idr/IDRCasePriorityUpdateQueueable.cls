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
    sendInAppNotifications(results, updatedCases);
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
   * @description Send in-app notifications for Case records which have been successfully to 'Customer experiencing vulnerability'.
   * @param results - DML results of Case update
   * @param updatedCases - List of updated Case records
   */
  private void sendInAppNotifications(
    List<Database.SaveResult> results,
    List<Case> updatedCases
  ) {
    CustomNotificationType oNotificationType = CommonUtil.getCustomNotificationTypeByName(
      'CMOS'
    );
    Set<Id> vulnerableCaseIds = ListUtil.getIds(
      ListUtil.filter(updatedCases)
        .equals(Case.Priority, IDRConstants.CASE_PRIORITY_VULNERABLE)
        .toList(),
      Case.Id
    );
    if (vulnerableCaseIds.isEmpty()) {
      return;
    }
    String subjectTemplate = 'Change in Customer\'s Extra Care Needs';
    String description = 'Change in customer\'s Extra Care needs on complaint {0} for {1}';
    for (Integer i = 0; i < results.size(); i++) {
      Database.SaveResult sr = results[i];
      if (!sr.isSuccess() && !vulnerableCaseIds.contains(sr.getId())) {
        continue;
      }
      List<Object> lParameters = new List<Object>{
        updatedCases[i].CaseNumber,
        updatedCases[i].Account.Name
      };
      String strNotificationDesc = String.format(description, lParameters);
      CommonUtil.sendInAppNotification(
        new InAppNotificationWrapper(
          oNotificationType.Id,
          sr.getId(),
          updatedCases[i].OwnerId,
          subjectTemplate,
          strNotificationDesc
        )
      );
    }
  }
}
