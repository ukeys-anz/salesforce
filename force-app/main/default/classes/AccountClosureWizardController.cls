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
    //Step 2: Process Cases (Create / Update)
    Set<Id> caseIds = AccountClosureWizardControllerHelper.processCases(
      caseInputs,
      listOfExistingDummyCases
    );
    //Step 3: Fetch and return updated/inserted cases
    List<Case> listOfCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfInsertedOrUpdatedCases(
      caseIds
    );
    AccountClosureWizardControllerHelper.addProductNamesToCases(
      caseInputs,
      listOfCases
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
    List<FinServ__FinancialAccount__c> listOfFinAccounts = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      accountNumbers
    );
    //This method handles handles common logic for both db and fabric service fin accounts (Steps 2-4)
    return AccountClosureWizardControllerHelper.processAccounts(
      listOfFinAccounts
    );
  }

  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   * @param ownerId the ocv id of the customer
   * @param recordTypeDeveloperNames contains account numbers to provide as parameters for account filtering
   * @return List<FinancialAccountsResponse>
   */
  @AuraEnabled
  public static List<FinancialAccountsResponse> getFilteredFinancialAccountsDb(
    Id ownerId,
    List<String> recordTypeDeveloperNames
  ) {
    //Step 1: Fetch financial accounts from database
    List<FinServ__FinancialAccount__c> listOfFinAccounts = FinancialAccountController.getFinancialAccountDB(
      ownerId,
      recordTypeDeveloperNames
    );
    //This method handles handles common logic for both db and fabric service fin accounts (Steps 2-4)
    return AccountClosureWizardControllerHelper.processAccounts(
      listOfFinAccounts
    );
  }
}
