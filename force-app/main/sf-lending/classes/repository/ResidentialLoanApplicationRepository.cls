/**
 * @description repository class for Residential Loan Application
 * @author @fangl6
 * @since 24/06/2024
 */
public with sharing class ResidentialLoanApplicationRepository {
  @TestVisible
  private static Map<String, Loan_Application_Validity__mdt> loanApplicationValidityMap = new Map<String, Loan_Application_Validity__mdt>();

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
        RecordTypeId,
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

  /**
   * @description get custom metadata type for RLA's status
   * @param recordTypeName Record type name of RLA
   * @param status Status of RLA
   * @return Loan_Application_Validity__mdt cutom metadata type
   */
  public Loan_Application_Validity__mdt getLoanApplicationValidityMetadata(
    String recordTypeName,
    String status
  ) {
    String key = recordTypeName + '_' + status;
    Loan_Application_Validity__mdt loanApplicationValidityMDT = loanApplicationValidityMap.get(
      key
    );
    if (loanApplicationValidityMDT != null) {
      return loanApplicationValidityMDT;
    }
    loanApplicationValidityMDT = Loan_Application_Validity__mdt.getInstance(
      key
    );
    loanApplicationValidityMap.put(key, loanApplicationValidityMDT);
    return loanApplicationValidityMDT;
  }
}
