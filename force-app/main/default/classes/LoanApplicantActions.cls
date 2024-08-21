public with sharing class LoanApplicantActions {
  private static final LoanApplicantRepository LOAN_APPLICANT_REPOSITORY = (LoanApplicantRepository) Lib_InstanceProvider.forType(
    LoanApplicantRepository.class
  );
  public static void synchronizeAndUpdateCustomerSyncStatus(
    Set<Id> loanApplicantIds
  ) {
    List<LoanApplicant> loanApplicantList = LOAN_APPLICANT_REPOSITORY.queryLoanApplicationAndCustomerDetailsOfApplicants(
      loanApplicantIds
    );
    Map<Id, String> accountIdAndSyncStatusMap = createAccountVsProposedSyncStatusMap(
      loanApplicantList
    );
    System.debug(accountIdAndSyncStatusMap);

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
    update accountList;
  }

  private static Map<Id, String> createAccountVsProposedSyncStatusMap(
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
          'Broker Org'
        );
      } else {
        accountIdAndSyncStatusMap.put(eachLoanApplicant.Account__c, '');
      }
    }
    return accountIdAndSyncStatusMap;
  }

  private static List<Account> createResultantSyncStatusMultiSelectPicklistValue(
    List<Account> accountList,
    Map<Id, String> accountIdAndSyncStatusMap
  ) {
    for (Account eachAccountRecord : accountList) {
      if (String.isBlank(accountIdAndSyncStatusMap.get(eachAccountRecord.Id))) {
        continue;
      }
      if (String.isBlank(eachAccountRecord.Sync_Status__c)) {
        eachAccountRecord.Sync_Status__c = accountIdAndSyncStatusMap.get(
          eachAccountRecord.Id
        );
        continue; 
      }
      List<String> picklistValues = eachAccountRecord.Sync_Status__c.split(';');
      picklistValues.add(accountIdAndSyncStatusMap.get(eachAccountRecord.Id));
      eachAccountRecord.Sync_Status__c = String.join(picklistValues, ';');
    }
    return accountList;
  }
}
