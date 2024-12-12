/**
 * @author Nilesh Kalal
 * @since Fri Dec 6 2024
 * @description Controller for Account Closure Wizard
 */

public with sharing class AccountClosureWizardController {
  /**
   * @description
   * @param parentCaseId list of case data from wizard
   * @param caseDataFromLwc list of case data from wizard
   * @return List<Case>
   */
  @AuraEnabled
  public static List<Case> createCasesForAccounts(
    Id parentCaseId,
    List<CaseInput> caseDataFromLwc
  ) {
    // Early Exit: Return an empty list if the input is empty
    if (caseDataFromLwc.isEmpty()) {
      return new List<Case>();
    }

    // Create a list to store new cases to insert and cases to update
    List<Case> casesToInsert = new List<Case>();
    List<Case> casesToUpdate = new List<Case>();

    // Query for existing child cases which act as dummy cases, filtering based on parentCaseId and other criteria
    List<Case> listOfExistingDummyCases = [
      SELECT
        Id,
        CaseNumber,
        ParentId,
        Status,
        Intended_Account_Name__c,
        Intended_Account_BSB__c,
        Intended_Account_Number__c,
        Closure_Reason__c,
        Account_Type__c,
        AccountId,
        FinServ__FinancialAccount__c,
        Account_Product__c
      FROM Case
      WHERE
        ParentId = :parentCaseId
        AND Status != 'Closed'
        AND FinServ__FinancialAccount__c = NULL
        AND RecordTypeId = :GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    ];

    // Now process each case input from the LWC data
    Integer dummyCaseIndex = 0;
    for (CaseInput caseInput : caseDataFromLwc) {
      // This logic ensures to utilise dummy cases in org rather creating new one
      if (dummyCaseIndex < listOfExistingDummyCases.size()) {
        Case existingCase = listOfExistingDummyCases[dummyCaseIndex];
        existingCase.Status = caseInput.status;
        existingCase.Intended_Account_Name__c = caseInput.intendedAccountName;
        existingCase.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
        existingCase.Intended_Account_Number__c = caseInput.intendedAccountNumber;
        existingCase.Closure_Reason__c = caseInput.closureReason;
        existingCase.Account_Type__c = caseInput.accountType;
        existingCase.AccountId = caseInput.accountId;
        existingCase.FinServ__FinancialAccount__c = caseInput.finiancialAccountId;
        existingCase.Account_Product__c = caseInput.productName; // To be revisited, as noted
        // Add to the update list
        casesToUpdate.add(existingCase);
        dummyCaseIndex++;
      } else {
        // If no existing child case is found, create a new one
        Case newCase = new Case();
        newCase.Status = caseInput.status;
        newCase.Intended_Account_Name__c = caseInput.intendedAccountName;
        newCase.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
        newCase.Intended_Account_Number__c = caseInput.intendedAccountNumber;
        newCase.Closure_Reason__c = caseInput.closureReason;
        newCase.Account_Type__c = caseInput.accountType;
        newCase.AccountId = caseInput.accountId;
        newCase.FinServ__FinancialAccount__c = caseInput.finiancialAccountId;
        newCase.Account_Product__c = caseInput.productName; // Needs To be change
        newCase.RecordTypeId = GetHelpConstants.ACCOUNT_CLOSURE_RT_ID;
        // Add to the insert list
        casesToInsert.add(newCase);
      }
    }

    // Perform DML operations: First update existing cases, then insert new cases
    if (!casesToUpdate.isEmpty()) {
      update casesToUpdate;
    }
    if (!casesToInsert.isEmpty()) {
      insert casesToInsert;
    }

    // Initialize the list of IDs for both inserted and updated cases
    Set<Id> caseIdsToQuery = new Set<Id>();

    // Add IDs from the cases to insert and update to the set
    for (Case insertedCase : casesToInsert) {
      caseIdsToQuery.add(insertedCase.Id);
    }
    for (Case updatedCase : casesToUpdate) {
      caseIdsToQuery.add(updatedCase.Id);
    }

    // If there are any case IDs to query, perform the query
    List<Case> listOfInsertedOrUpdatedCases = caseIdsToQuery.isEmpty()
      ? new List<Case>()
      : [
          SELECT
            Id,
            CaseNumber,
            Account_Product__c,
            FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c,
            Account_Type__c,
            FinServ__FinancialAccount__r.FinServ__Balance__c
          FROM Case
          WHERE Id IN :caseIdsToQuery
        ];
    return listOfInsertedOrUpdatedCases;
  }

  /**
   * @description Define a wrapper class for the input data from LWC
   */
  public class CaseInput {
    /**
     * @description Status for the Case
     */
    @AuraEnabled
    public String status { get; set; }
    /**
     * @description Account Name for the Case
     */
    @AuraEnabled
    public String intendedAccountName { get; set; }
    /**
     * @description Account Bsb for the Case
     */
    @AuraEnabled
    public String intendedAccountBsb { get; set; }
    /**
     * @description Account Number for the Case
     */
    @AuraEnabled
    public String intendedAccountNumber { get; set; }
    /**
     * @description Closure Reason for the Case
     */
    @AuraEnabled
    public String closureReason { get; set; }
    /**
     * @description Account Type for the Case
     */
    @AuraEnabled
    public String accountType { get; set; }
    /**
     * @description ProductName for the Case
     */
    @AuraEnabled
    public String productName { get; set; }
    /**
     * @description accountId is Customer Record Id for the Case
     */
    @AuraEnabled
    public String accountId { get; set; }
    /**
     * @description Finiancial Account Id for the Case
     */
    @AuraEnabled
    public String finiancialAccountId { get; set; }
  }
}
