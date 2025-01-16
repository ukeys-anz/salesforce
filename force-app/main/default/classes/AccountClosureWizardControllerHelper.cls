/**
 * @author Nilesh Kalal
 * @since Wed Dec 18 2024
 * @description Helper for Account Closure Wizard Controller
 */
public with sharing class AccountClosureWizardControllerHelper {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Process dummy cases if found and map user input from lwc to case records
   * @param inputs List of CaseInput
   * @param listOfExistingDummyCases List of Cases
   * @return Set<Id>
   */
  public static Set<Id> processAndMapCasesFromInput(
    List<CaseInput> inputs,
    List<Case> listOfExistingDummyCases
  ) {
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    Set<Id> setOfCaseIds = new Set<Id>();

    for (Integer i = 0; i < inputs.size(); i++) {
      CaseInput input = inputs[i];
      if (i < listOfExistingDummyCases.size()) {
        Case existingCase = listOfExistingDummyCases[i];
        mapCaseFields(existingCase, input);
        casesToUpdate.add(existingCase);
      } else {
        Case newCase = new Case();
        mapCaseFields(newCase, input);
        casesToInsert.add(newCase);
      }
    }

    // Perform DML operations
    if (!casesToUpdate.isEmpty()) {
      DML_REPOSITORY.doUpdate(casesToUpdate);
      setOfCaseIds.addAll(ListUtil.getIds(casesToUpdate, Case.Id));
    }
    if (!casesToInsert.isEmpty()) {
      DML_REPOSITORY.doInsert(casesToInsert);
      setOfCaseIds.addAll(ListUtil.getIds(casesToInsert, Case.Id));
    }
    return setOfCaseIds;
  }

  /**
   * @description
   * @param caseObj case object record to be inserted or updated
   * @param caseInput from LWC
   */
  private static void mapCaseFields(Case caseObj, CaseInput caseInput) {
    caseObj.Status = caseInput.status;
    caseObj.Intended_Account_Name__c = caseInput.intendedAccountName;
    caseObj.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
    caseObj.Intended_Account_Number__c = caseInput.intendedAccountNumber;
    caseObj.Closure_Reason__c = caseInput.closureReason;
    caseObj.Account_Type__c = caseInput.accountType;
    caseObj.AccountId = caseInput.accountId;
    caseObj.FinServ__FinancialAccount__c = caseInput.financialAccountId;
    caseObj.ProductId = caseInput.productId; // lookup to product table
    caseObj.RecordTypeId = RTCase.accountClosure;
  }

  /**
   * @description Extracts the Account Ids from the Case records
   * @param acccountIds set of case Ids to query
   * @return Set<Id> list of case records
   */
  public static Set<Id> getAccountsWithChildCases(Set<Id> acccountIds) {
    List<Case> childCases = ACCOUNT_CLOSURE_REPOSITORY.fetchChildCases(
      acccountIds
    );
    Set<Id> setOfFinAccountIds = ListUtil.getIds(
      childCases,
      Case.FinServ__FinancialAccount__c
    );
    return setOfFinAccountIds;
  }

  /**
   * @description Extracts the Account Ids from the Case records
   * @param listOfFinAccounts list of financial account records
   * @return List<FinancialAccountsResponse> list of Financial Account response
   */

  public static List<FinancialAccountsResponse> prepareFinancialAccountsResponse(
    List<FinServ__FinancialAccount__c> listOfFinAccounts
  ) {
    List<FinancialAccountsResponse> listOfFinancialAccountResponse = new List<FinancialAccountsResponse>();
    for (FinServ__FinancialAccount__c eachAccount : listOfFinAccounts) {
      // Use the Builder pattern to create the FinancialAccountsResponse object
      FinancialAccountsResponse response = new FinancialAccountsResponse.Builder()
        .setId(eachAccount.Id)
        .setAccountNumber(eachAccount.FinServ__FinancialAccountNumber__c)
        .setProductName(eachAccount.FinServ__ProductName__r.Name)
        .setProductId(eachAccount.FinServ__ProductName__c) // Product Id (lookup field)
        .setBalance(eachAccount.FinServ__Balance__c)
        .setOwnership(eachAccount.FinServ__Ownership__c)
        .setStatus(eachAccount.FinServ__Status__c)
        .setMarketingCode(eachAccount.Marketing_Code__c)
        .setSigningAuthority(eachAccount.Number_Of_Signatures__c)
        .setRecodTypeName(eachAccount.RecordType.DeveloperName)
        .build();
      // Add the response to the list
      listOfFinancialAccountResponse.add(response);
    }
    return listOfFinancialAccountResponse;
  }

  /**
   * @description Includes product name into the case response
   * @param caseInputs List of case inputs from UI form
   * @param listOfCases List of cases created/updated
   */

  public static void addProductNamesToCases(
    List<caseInput> caseInputs,
    List<Case> listOfCases
  ) {
    if (caseInputs.isEmpty() || listOfCases.isEmpty()) {
      return;
    }

    Map<Id, String> financialAccountToProductNameMap = new Map<Id, String>();
    for (CaseInput caseInput : caseInputs) {
      if (caseInput.financialAccountId != null) {
        financialAccountToProductNameMap.put(
          caseInput.financialAccountId,
          caseInput.productName
        );
      }
    }

    for (Case caseRecord : listOfCases) {
      if (
        caseRecord.FinServ__FinancialAccount__c != null &&
        financialAccountToProductNameMap.containsKey(
          caseRecord.FinServ__FinancialAccount__c
        )
      ) {
        caseRecord.put(
          'Product__c',
          financialAccountToProductNameMap.get(
            caseRecord.FinServ__FinancialAccount__c
          )
        );
      }
    }
  }

  /**
   * @description process fin accounts in order to prepare response
   * @param listOfFinAccounts List of case inputs from UI form
   * @return List<FinancialAccountsResponse> list of Financial Account response
   */
  public static List<FinancialAccountsResponse> processAccounts(
    List<FinServ__FinancialAccount__c> listOfFinAccounts
  ) {
    // Common logic here (Steps 2-4)
    //Step 2: Identify the accounts with child cases
    Set<Id> accountIds = ListUtil.getIds(
      listOfFinAccounts,
      FinServ__FinancialAccount__c.Id
    );
    Set<Id> accountsWithCases = AccountClosureWizardControllerHelper.getAccountsWithChildCases(
      accountIds
    );
    //Step 3: Remove accounts that already have cases linked to them
    accountIds.removeAll(accountsWithCases);
    List<FinServ__FinancialAccount__c> listOfFilteredFinAccounts = ACCOUNT_CLOSURE_REPOSITORY.fetchFinancialAccounts(
      accountIds
    );
    //Step 4: Prepare response for UI
    return AccountClosureWizardControllerHelper.prepareFinancialAccountsResponse(
      listOfFilteredFinAccounts
    );
  }
}
