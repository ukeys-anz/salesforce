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
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   * @param ocvId the ocv id of the customer
   * @return List<FinancialAccountsResponse>
   */
  @AuraEnabled
  public static List<FinancialAccountsResponse> getFilteredFinancialAccounts(
    String ocvId
  ) {
    //Step 1: Fetch financial accounts from fabric service
    List<FinServ__FinancialAccount__c> listOfFinAccounts = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      new List<String>()
    );
    //This method handles handles logic to prepare response
    return AccountClosureWizardControllerHelper.processAccounts(
      listOfFinAccounts
    );
  }

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
    Set<Id> caseIds = AccountClosureWizardControllerHelper.processAndMapCasesFromInput(
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
}
