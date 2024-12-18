/**
 * @author Nilesh Kalal
 * @since Fri Dec 6 2024
 * @description Controller for Account Closure Wizard
 */

public with sharing class AccountClosureWizardController {
  private static final AccountClosureRepository ACCOUNT_CLOSURE_REPOSITORY = (AccountClosureRepository) Lib_InstanceProvider.forType(
    AccountClosureRepository.class
  );

  /**
   * @description
   * @param parentCaseId list of case data from wizard
   * @param caseInputs list of case data from wizard
   * @return List<Case>
   */
  @AuraEnabled
  public static List<Case> createCasesForAccounts(
    Id parentCaseId,
    List<CaseInput> caseInputs
  ) {
    if (String.isBlank(parentCaseId) || caseInputs.isEmpty()) {
      return new List<Case>();
    }
    //Step 1: Fetch existing dummy cases
    List<Case> listOfExistingDummyCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfExistingDummyCases(
      parentCaseId
    );

    //Step 2: Process cases (udpate existing, create new)
    Map<String, List<Case>> processedCases = AccountClosureWizardControllerHelper.processCases(
      caseInputs,
      listOfExistingDummyCases
    );

    //Step 3: Fetch and return updated/inserted cases
    Set<Id> caseIds = AccountClosureWizardControllerHelper.extractCaseIds(
      processedCases
    );

    List<Case> listOfCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfInsertedOrUpdatedCases(
      caseIds
    );

    return listOfCases;
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
    //Step 1: Fetch financial accounts from fabric service
    List<FinServ__FinancialAccount__c> listOfFabricAccounts = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      accountNumbers
    );

    //Step 2: Identify the accounts with child cases
    Set<Id> accountIds = ListUtil.getIds(
      listOfFabricAccounts,
      FinServ__FinancialAccount__c.Id
    );

    Set<Id> accountsWithCases = AccountClosureWizardControllerHelper.getAccountsWithChildCases(
      accountIds
    );

    //Step 3: Remove accounts that already have cases
    accountIds.removeAll(accountsWithCases);

    //Step 4: Fetch account details
    Map<Id, FinServ__FinancialAccount__c> financialAccountMap = ACCOUNT_CLOSURE_REPOSITORY.fetchFinancialAccounts(
      accountIds
    );

    //Step 5: Prepare Response
    return AccountClosureWizardControllerHelper.prepareFinancialAccountsResponse(
      listOfFabricAccounts,
      financialAccountMap
    );
  }
}
