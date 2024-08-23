/**
 * @description repository class for Residential Loan Application
 * @author Deepro De
 * @since August 2024
 */
public with sharing class LoanApplicantRepository {
  /**
   * @description get associated ResidentialLoanApplicantRecords
   * @return List<ResidentialLoanApplication>
   * @param loanApplicantIds List of LoanApplicant Ids
   */
  public List<LoanApplicant> queryLoanApplicationOfApplicants(
    Set<Id> loanApplicantIds
  ) {
    List<LoanApplicant> loanApplicantRecords = new List<LoanApplicant>();
    if (
      loanApplicantIds.isEmpty() ||
      !LoanApplicant.SObjectType.getDescribe().isQueryable()
    ) {
      return loanApplicantRecords;
    }
    loanApplicantRecords = [
      SELECT
        Id,
        LoanApplication.Assisted_Broker_TPMI_SAO__c,
        Account__r.Sync_Status__c,
        Account__c
      FROM LoanApplicant
      WHERE Id IN :loanApplicantIds
    ];
    return loanApplicantRecords;
  }


  /**
   * @description get Account Records
   * @return List<Account>
   * @param accountIds List of Account Ids
   */
  public List<Account> queryAccounts(
    Set<Id> accountIds
  ) {
    List<Account> accountRecords = new List<Account>();
    if (
        accountIds.isEmpty() ||
      !Account.SObjectType.getDescribe().isQueryable()
    ) {
      return accountRecords;
    }
    accountRecords = [
      SELECT
        Id,
        Sync_Status__c
      FROM Account
      WHERE Id IN :accountIds
    ];
    return accountRecords;
  }
}
