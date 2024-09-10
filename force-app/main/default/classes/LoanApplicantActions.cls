/**
 * @author Deepro De
 * @since August 2024
 * @description class for Loan Applicant actions
 * @runTests LoanApplicantActions
 */
public with sharing class LoanApplicantActions {
  public static final LoanApplicantRepository LOAN_APPLICANT_REPOSITORY = (LoanApplicantRepository) Lib_InstanceProvider.forType(
    LoanApplicantRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  public static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';

  /**
   * @description Orchestration method for updating the Customer Sync Status
   * @param loanApplicantIds loan applicants to process
   */
  public static void synchronizeAndUpdateCustomerSyncStatus(
    Set<Id> loanApplicantIds
  ) {
    List<Database.SaveResult> updateResults;
    List<LoanApplicant> loanApplicantList = LOAN_APPLICANT_REPOSITORY.queryLoanApplicationOfApplicants(
      loanApplicantIds
    );
    Map<Id, String> accountIdAndStatusMap = createFilteredAccountIdMap(
      loanApplicantList
    );
    List<Account> accountList = createResultantSyncStatus(
      accountIdAndStatusMap
    );
    updateResults = DML_REPOSITORY.updateRecords(
      accountList,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description Create filterd set of accounts
   * @param loanApplicantList list of Loan Applicants
   * @return Map<Id, String> set of accounts id
   */
  public static Map<Id, String> createFilteredAccountIdMap(
    List<LoanApplicant> loanApplicantList
  ) {
    Map<Id, String> accountIdAndSyncStatusMap = new Map<Id, String>();
    for (LoanApplicant eachLoanApplicant : loanApplicantList) {
      if (
        String.isBlank(
          eachLoanApplicant.LoanApplication.Assisted_Broker_TPMI_SAO__c
        )
      ) {
        continue;
      }

      String syncStatus = eachLoanApplicant.Account__r.Sync_Status__c;
      if (
        String.isNotBlank(syncStatus) &&
        syncStatus.contains(SYNC_STATUS_BROKER_ORG)
      ) {
        continue;
      }
      accountIdAndSyncStatusMap.put(eachLoanApplicant.Account__c, syncStatus);
    }
    return accountIdAndSyncStatusMap;
  }

  /**
   * @description Sets the Account Sync Status picklist value from Map
   * @param accountMap map of Account Id and Sync Status
   * @return List<Account> accountList updated accountList
   */
  public static List<Account> createResultantSyncStatus(
    Map<Id, String> accountMap
  ) {
    List<Account> finalAccountList = new List<Account>();
    for (Id eachAccountRecordId : accountMap.keySet()) {
      String syncStatus = accountMap.get(eachAccountRecordId);
      Account accRecord = new Account(Id = eachAccountRecordId);
      List<String> picklistValues = new List<String>{ SYNC_STATUS_BROKER_ORG };
      accRecord.Sync_Status__c = PicklistUtil.addMultiPicklistValues(
        syncStatus,
        picklistValues
      );
      finalAccountList.add(accRecord);
    }
    return finalAccountList;
  }
}
