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
  public static final String BROKER_ORG_BROKER_CODE = 'Broker Org';

  /**
   * @description Orchestration method for updating the Customer Sync Status
   * @param loanApplicantIds loan applicants to process
   */
  public static void synchronizeAndUpdateCustomerSyncStatus(
    Set<Id> loanApplicantIds
  ) {
    List<Database.SaveResult> updateResults;
    List<LoanApplicant> loanApplicantList = LOAN_APPLICANT_REPOSITORY.queryLoanApplicationAndCustomerDetailsOfApplicants(
      loanApplicantIds
    );
    Map<Id, String> accountIdAndSyncStatusMap = createAccountVsProposedSyncStatusMap(
      loanApplicantList
    );
    if (accountIdAndSyncStatusMap.keySet().isEmpty()) {
      return;
    }
    List<Account> accountList = LOAN_APPLICANT_REPOSITORY.queryAccounts(
      accountIdAndSyncStatusMap.keySet()
    );
    accountList = createResultantSyncStatusMultiSelectPicklistValue(
      accountList,
      accountIdAndSyncStatusMap
    );
    updateResults = DML_REPOSITORY.updateRecords(
      accountList,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description Create map of Sync Status and respective accounts
   * @param loanApplicantList list of Loan Applicants
   * @return Map<Id, String> map of accounts id and Sync Status
   */
  public static Map<Id, String> createAccountVsProposedSyncStatusMap(
    List<LoanApplicant> loanApplicantList
  ) {
    Map<Id, String> accountIdAndSyncStatusMap = new Map<Id, String>();
    for (LoanApplicant eachLoanApplicant : loanApplicantList) {
      if (
        String.isNotBlank(
          eachLoanApplicant.LoanApplication.Assisted_Broker_TPMI_SAO__c
        )
      ) {
        accountIdAndSyncStatusMap.put(
          eachLoanApplicant.Account__c,
          BROKER_ORG_BROKER_CODE
        );
      }
    }
    return accountIdAndSyncStatusMap;
  }

  /**
   * @description Sets the Account Sync Status picklist value from Map
   * @param accountList list of Accounts
   * @param accountIdAndSyncStatusMap Map of account Id and Sync Status
   * @return List<Account> accountList updated accountList
   */
  public static List<Account> createResultantSyncStatusMultiSelectPicklistValue(
    List<Account> accountList,
    Map<Id, String> accountIdAndSyncStatusMap
  ) {
    for (Account eachAccountRecord : accountList) {
      List<String> picklistValues = new List<String>();
      if (String.isBlank(eachAccountRecord.Sync_Status__c)) {
        eachAccountRecord.Sync_Status__c = accountIdAndSyncStatusMap.get(
          eachAccountRecord.Id
        );
        continue;
      }
      if (eachAccountRecord.Sync_Status__c.contains(BROKER_ORG_BROKER_CODE)) {
        continue;
      }
      picklistValues.add(accountIdAndSyncStatusMap.get(eachAccountRecord.Id));
      eachAccountRecord.Sync_Status__c = PicklistUtil.addMultiPicklistValues(
        eachAccountRecord.Sync_Status__c,
        picklistValues
      );
    }
    return accountList;
  }
}
