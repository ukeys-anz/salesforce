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

  /**
   * @description Orchestration method for updating the Customer Sync Status
   * @param loanApplicantIds loan applicants to process
   */
  public static void accountSyncStatusUpdate(Set<Id> loanApplicantIds) {
    List<LoanApplicant> loanApplicants = LOAN_APPLICANT_REPOSITORY.queryLoanApplicationOfApplicants(
      loanApplicantIds
    );
    List<Account> accounts = updateAccountSyncStatus(loanApplicants);
    DML_REPOSITORY.updateRecords(
      accounts,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.USER_MODE
    );
  }

  /**
   * @description Sets the Account Sync Status picklist value from LoanApplicant
   * @param loanApplicants LoanApplicants list
   * @return List<Account> accountList updated accountList
   */
  public static List<Account> updateAccountSyncStatus(
    List<LoanApplicant> loanApplicants
  ) {
    List<Account> accounts = new List<Account>();
    List<String> picklistValues = new List<String>{
      BrokerConstants.SYNC_STATUS_BROKER_ORG
    };
    for (LoanApplicant loanApplicant : loanApplicants) {
      Account account = new Account(Id = loanApplicant.Account__c);
      account.Sync_Status__c = PicklistUtil.addMultiPicklistValues(
        loanApplicant.Account__r.Sync_Status__c,
        picklistValues
      );
      accounts.add(account);
    }
    return accounts;
  }
}
