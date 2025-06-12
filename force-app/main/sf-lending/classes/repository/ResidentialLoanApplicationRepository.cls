/**
 * @description repository class for Residential Loan Application
 * @author @fangl6
 * @since 24/06/2024
 */
public with sharing class ResidentialLoanApplicationRepository {
  /**
   * @description
   * @param loanId loan appklciation id
   * @param propertyIds set of property ids
   * @return  `List<LoanApplicationProperty>` properties related to the RLAs
   */
  public List<LoanApplicationProperty> queryRelatedProperties(
    Id loanId,
    Set<String> propertyIds
  ) {
    if (propertyIds.isEmpty()) {
      return new List<LoanApplicationProperty>();
    }
    return [
      SELECT Id, Name, Property_ID__c, PropertyValue, Address_Details__c
      FROM LoanApplicationProperty
      WHERE
        LoanApplicationId = :loanId
        AND Property_ID__c IN :propertyIds
        AND Property_ID__c != NULL
      WITH USER_MODE
    ];
  }
  /**
   * @description get multiple loan application record details
   * @return List<ResidentialLoanApplication>
   * @param loanIds List of ResidentialLoanapplication Ids
   */
  public List<ResidentialLoanApplication> queryLoanApplications(
    List<Id> loanIds
  ) {
    if (loanIds.isEmpty()) {
      return new List<ResidentialLoanApplication>();
    }
    return [
      SELECT
        Id,
        Name,
        Sync_Status__c,
        ApplicationExtIdentifier,
        Account.External_Id__c
      FROM ResidentialLoanApplication
      WHERE Id IN :loanIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get RLA by id
   * @param recordId RLA recordId
   * @return  `ResidentialLoanApplication`
   */
  public ResidentialLoanApplication queryRLAById(String recordId) {
    return [
      SELECT
        Id,
        Assessment_Outcome__c,
        Status,
        Credit_ID__c,
        SOP_Id__c,
        Name,
        Account.OCV_ID__c,
        Credit_Reassess_Required__c
      FROM ResidentialLoanApplication
      WHERE Id = :recordId
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description query account based on OCVId
   * @param ocvId List of ocvids to search account details
   * @return  `List<Account>` the result of accounts
   */
  public List<Account> getAccountsFromOcvIds(List<String> ocvId) {
    if (ocvId.isEmpty()) {
      return new List<Account>();
    }

    List<Account> accList = [
      SELECT FirstName, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c IN :ocvId
      WITH USER_MODE
    ];

    return accList;
  }

  /**
   * @description query expense control based on justification codes
   * @param expenseCodeSet set of justification codes
   * @return  `List<Expense_Control__c>` the result of exepense control
   */
  public List<Expense_Control__c> getExpenseControl(
    Set<String> expenseCodeSet
  ) {
    if (expenseCodeSet.isEmpty()) {
      return new List<Expense_Control__c>();
    }
    List<Expense_Control__c> controlList = [
      SELECT Id, Justification_Code__c, Justification_Description__c
      FROM Expense_Control__c
      WHERE Justification_Code__c IN :expenseCodeSet
      WITH USER_MODE
    ];
    return controlList;
  }

  /**
   * @description query for loan application liabilities
   * @param loanId RLA id
   * @return  `List<LoanApplicationLiability>` list of liabilities
   */
  public List<LoanApplicationLiability> getLoanApplicationLiability(
    String loanId
  ) {
    if (String.isBlank(loanId)) {
      return new List<LoanApplicationLiability>();
    }

    return [
      SELECT Name
      FROM LoanApplicationLiability
      WHERE LoanApplicationId = :loanId
      WITH USER_MODE
    ];
  }

  /**
   * @description query for loan applicants=
   * @param ocvIds list of ocv ids
   * @param loanAppId loan application id
   * @return  `List<LoanApplicant>` list of applicants
   */
  public List<LoanApplicant> getLoanApplicants(
    List<String> ocvIds,
    Id loanAppId
  ) {
    if (ocvIds.isEmpty()) {
      return new List<LoanApplicant>();
    }

    //LoanApplicant stores OCV Ids in Party Id field
    return [
      SELECT Id, Account__r.Name, Party_ID__c
      FROM LoanApplicant
      WHERE Party_ID__c IN :ocvIds AND LoanApplicationId = :loanAppId
      WITH USER_MODE
    ];
  }

  /**
   * @description
   * @param rlaRecordIds set of RLA ids
   * @return  `List<Case>` Cases related to the RLAs
   */
  public List<Case> queryRelatedCreditReferralCases(Set<Id> rlaRecordIds) {
    if (rlaRecordIds.isEmpty()) {
      return new List<Case>();
    }
    return [
      SELECT Id, Loan_Application__c
      FROM Case
      WHERE
        Loan_Application__c IN :rlaRecordIds
        AND RecordTypeId = :RTCase.creditReferral
        AND IsClosed = FALSE
      WITH USER_MODE
    ];
  }
}
