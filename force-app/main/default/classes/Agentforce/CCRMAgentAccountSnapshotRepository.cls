/**
 * @author Prasanjeet Dutta
 * @since Jan 2026
 * @description Repository for CCRM Agent Account Snapshot data.
 *
 */
public with sharing class CCRMAgentAccountSnapshotRepository {
  /**
   * @description Fetch Portfolio Of Loans for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Portfolio_Of_Loan__x> The list of portfolio of loans.
   */
  public List<Portfolio_Of_Loan__x> fetchPortfolioOfLoansByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Portfolio_Of_Loan__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Expires__c
      FROM Portfolio_Of_Loan__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Other Limits and Liabilities for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Other_Limits_and_Liabilities__x> The list of other limits and liabilities.
   */
  public List<Other_Limits_and_Liabilities__x> fetchOtherLimitsByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Other_Limits_and_Liabilities__x>();
    }
    return [
      SELECT Id, Account_Status__c
      FROM Other_Limits_and_Liabilities__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Asset Finance AMBIT Contract for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Asset_Finance_AMBIT_Contract__x> The list of asset finance AMBIT contracts.
   */
  public List<Asset_Finance_AMBIT_Contract__x> fetchAssetFinanceAmbitByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Asset_Finance_AMBIT_Contract__x>();
    }
    return [
      SELECT Id, Status__c, Contract_Number__c, Product_Name__c, Expiry_Date__c
      FROM Asset_Finance_AMBIT_Contract__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Asset Finance (ELS) for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Asset_Finance_ELS__x> The list of asset finance ELS records.
   */
  public List<Asset_Finance_ELS__x> fetchAssetFinanceELSByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Asset_Finance_ELS__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Expires__c
      FROM Asset_Finance_ELS__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Deposit Accounts for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Deposit_Account__x> The list of deposit accounts.
   */
  public List<Deposit_Account__x> fetchDepositAccountsByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Deposit_Account__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Expiry_Date__c,
        Overdraft_Expiry_Date__c,
        Balance_Available__c
      FROM Deposit_Account__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Loan Accounts for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Loan_Account__x> The list of loan accounts.
   */
  public List<Loan_Account__x> fetchLoanAccountsByExternalId(String extId) {
    if (String.isBlank(extId)) {
      return new List<Loan_Account__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Expires__c,
        Repayment_Details_Days_Delinquent__c
      FROM Loan_Account__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Term Deposits for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Term_Deposit__x> The list of term deposits.
   */
  public List<Term_Deposit__x> fetchTermDepositsByExternalId(String extId) {
    if (String.isBlank(extId)) {
      return new List<Term_Deposit__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Maturity_Date__c
      FROM Term_Deposit__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Credit Cards for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Credit_Card__x> The list of credit cards.
   */
  public List<Credit_Card__x> fetchCreditCardsByExternalId(String extId) {
    if (String.isBlank(extId)) {
      return new List<Credit_Card__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Product_Name__c,
        Available_Funds__c,
        Days_Delinquent__c
      FROM Credit_Card__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Commercial Bills for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Commercial_Bill__x> The list of commercial bills.
   */
  public List<Commercial_Bill__x> fetchCommercialBillsByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Commercial_Bill__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Expires__c
      FROM Commercial_Bill__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Indemnity Guarantees for a customer external Id.
   * @param extId The external ID of the customer.
   * @return List<Indemnity_Guarantee__x> The list of indemnity guarantees.
   */
  public List<Indemnity_Guarantee__x> fetchIndemnityGuaranteesByExternalId(
    String extId
  ) {
    if (String.isBlank(extId)) {
      return new List<Indemnity_Guarantee__x>();
    }
    return [
      SELECT
        Id,
        Account_Status__c,
        Account_Number__c,
        Account_Name__c,
        Expiry_Date__c,
        ExternalId
      FROM Indemnity_Guarantee__x
      WHERE Customer__r.External_Id__c = :extId
      WITH USER_MODE
    ];
  }

  /**
   * @description Fetch Facility Fee Next Due Date for a given IG ExternalId from Facility_Fee__x.
   * @param igExternalId The external ID of the indemnity guarantee.
   * @return List<Facility_Fee__x> The list of facility fees.
   */
  public List<Facility_Fee__x> fetchFacilityFeeNextDueDateByIGExternalId(
    String igExternalId
  ) {
    if (String.isBlank(igExternalId)) {
      return new List<Facility_Fee__x>();
    }
    return [
      SELECT Id, Next_Due_Date__c
      FROM Facility_Fee__x
      WHERE Indemnity_Guarantee__r.ExternalId = :igExternalId
      WITH USER_MODE
      LIMIT 1
    ];
  }
}
