/**
 * @author Nilesh Kalal
 * @since Fri Dec 6 2024
 * @description Controller for Account Closure Wizard
 */

public with sharing class AccountClosureWizardController {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

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
    if (String.isBlank(parentCaseId) || caseDataFromLwc.isEmpty()) {
      return new List<Case>();
    }
    List<Case> casesToInsert = new List<Case>();
    List<Case> casesToUpdate = new List<Case>();

    List<Case> listOfExistingDummyCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfExistingDummyCases(
      parentCaseId
    );
    Integer dummyCaseIndex = 0;
    for (CaseInput caseInput : caseDataFromLwc) {
      // This logic ensures to utilise dummy cases in org rather creating new one
      if (dummyCaseIndex < listOfExistingDummyCases.size()) {
        // Reuse existing case and update fields
        Case existingCase = listOfExistingDummyCases[dummyCaseIndex];
        populateCaseFields(existingCase, caseInput);
        casesToUpdate.add(existingCase);
        dummyCaseIndex++;
      } else {
        // Create a new case if no existing case is available
        Case newCase = new Case();
        populateCaseFields(newCase, caseInput);
        casesToInsert.add(newCase);
      }
    }
    // Perform DML operations: First update existing cases, then insert new cases
    if (!casesToUpdate.isEmpty()) {
      DML_REPOSITORY.doUpdate(casesToUpdate);
    }
    if (!casesToInsert.isEmpty()) {
      DML_REPOSITORY.doInsert(casesToInsert);
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
    List<Case> listOfInsertedOrUpdatedCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfInsertedOrUpdatedCases(
      caseIdsToQuery
    );
    return listOfInsertedOrUpdatedCases;
  }

  /**
   * @description
   * @param caseObj case object record to be inserted or updated
   * @param caseInput from LWC
   */
  private static void populateCaseFields(Case caseObj, CaseInput caseInput) {
    caseObj.Status = caseInput.status;
    caseObj.Intended_Account_Name__c = caseInput.intendedAccountName;
    caseObj.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
    caseObj.Intended_Account_Number__c = caseInput.intendedAccountNumber;
    caseObj.Closure_Reason__c = caseInput.closureReason;
    caseObj.Account_Type__c = caseInput.accountType;
    caseObj.AccountId = caseInput.accountId;
    caseObj.FinServ__FinancialAccount__c = caseInput.finiancialAccountId;
    caseObj.ProductId = caseInput.productId; // lookup to product table
    caseObj.RecordTypeId = RTCase.accountClosure;
  }

  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return List<FinancialAccountsResponse>
   */
  @AuraEnabled
  public static List<FinancialAccountsResponse> getFilteredFinancialAccounts(
    String ocvId,
    List<String> accountNumbers
  ) {
    //Step 1: Call the exiting method
    Set<Id> setOfFinancialAccountIds = new Set<Id>();
    Set<Id> setOfFinIdsWhereChildCaseExist = new Set<Id>();
    List<FinancialAccountsResponse> listOfFinancialAccountResponse = new List<FinancialAccountsResponse>();
    List<FinServ__FinancialAccount__c> listOfFinAccountsFromFabric = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      accountNumbers
    );

    //Step 2:
    for (
      FinServ__FinancialAccount__c eachFinAccount : listOfFinAccountsFromFabric
    ) {
      if (eachFinAccount.Id != null) {
        setOfFinancialAccountIds.add(eachFinAccount.Id);
      }
    }

    for (Case eachCase : [
      SELECT Id, FinServ__FinancialAccount__c
      FROM Case
      WHERE
        FinServ__FinancialAccount__c IN :setOfFinancialAccountIds
        AND RecordTypeId = :GetHelpConstants.ACCOUNT_CLOSURE_RT_ID
    ]) {
      setOfFinIdsWhereChildCaseExist.add(eachCase.FinServ__FinancialAccount__c);
    }
    setOfFinancialAccountIds.removeAll(setOfFinIdsWhereChildCaseExist);

    Map<Id, FinServ__FinancialAccount__c> mapOfFinIdToFinAccount = new Map<Id, FinServ__FinancialAccount__c>(
      [
        SELECT
          Id,
          FinServ__FinancialAccountNumber__c,
          FinServ__ProductName__r.Name,
          FinServ__ProductName__c,
          FinServ__Balance__c,
          FinServ__Ownership__c,
          Marketing_Code__c,
          FinServ__Status__c,
          RecordType.DeveloperName
        FROM FinServ__FinancialAccount__c
        WHERE Id IN :setOfFinancialAccountIds
      ]
    );

    for (FinServ__FinancialAccount__c account : listOfFinAccountsFromFabric) {
      if (mapOfFinIdToFinAccount.containsKey(account.Id)) {
        FinServ__FinancialAccount__c dbAccount = mapOfFinIdToFinAccount.get(
          account.Id
        );
        listOfFinancialAccountResponse.add(
          new FinancialAccountsResponse(
            dbAccount.Id,
            dbAccount.FinServ__FinancialAccountNumber__c,
            dbAccount.FinServ__ProductName__r.Name,
            dbAccount.FinServ__ProductName__c, //this is lookup to product table, hence product Id
            dbAccount.FinServ__Balance__c,
            dbAccount.FinServ__Ownership__c,
            dbAccount.Marketing_Code__c,
            dbAccount.FinServ__Status__c,
            dbAccount.RecordType.DeveloperName
          )
        );
      }
    }
    return listOfFinancialAccountResponse;
  }
}
