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
    Set<Id> accountIdSet = createFilteredAccountIdSet(loanApplicantList);
    List<Account> accountList = LOAN_APPLICANT_REPOSITORY.queryAccounts(
      accountIdSet
    );
    accountList = createResultantSyncStatus(accountList);
    updateResults = DML_REPOSITORY.updateRecords(
      accountList,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description Create filterd set of accounts
   * @param loanApplicantList list of Loan Applicants
   * @return Set<Id> set of accounts id
   */
  public static Set<Id> createFilteredAccountIdSet(
    List<LoanApplicant> loanApplicantList
  ) {
    Set<Id> filteredAccountIdSet = new Set<Id>();
    for (LoanApplicant eachLoanApplicant : loanApplicantList) {
      if (
        String.isNotBlank(
          eachLoanApplicant.LoanApplication.Assisted_Broker_TPMI_SAO__c
        )
      ) {
        filteredAccountIdSet.add(eachLoanApplicant.Account__c);
      }
    }
    return filteredAccountIdSet;
  }

  /**
   * @description Sets the Account Sync Status picklist value from Map
   * @param accountList list of Accounts
   * @return List<Account> accountList updated accountList
   */
  public static List<Account> createResultantSyncStatus(
    List<Account> accountList
  ) {
    for (Account eachAccountRecord : accountList) {
      List<String> picklistValues = new List<String>();
      if (String.isBlank(eachAccountRecord.Sync_Status__c)) {
        eachAccountRecord.Sync_Status__c = SYNC_STATUS_BROKER_ORG;
        continue;
      }
      if (eachAccountRecord.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG)) {
        continue;
      }
      picklistValues.add(SYNC_STATUS_BROKER_ORG);
      eachAccountRecord.Sync_Status__c = PicklistUtil.addMultiPicklistValues(
        eachAccountRecord.Sync_Status__c,
        picklistValues
      );
    }
    return accountList;
  }
}
