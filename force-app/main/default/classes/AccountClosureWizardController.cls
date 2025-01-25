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
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFilteredFinancialAccounts(
    String ocvId
  ) {
    List<FinServ__FinancialAccount__c> listOfFinAccounts = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      new List<String>()
    );
    return AccountClosureWizardControllerHelper.filterFinancialAccountsLinkedWithCase(
      listOfFinAccounts
    );
  }

  /**
   * @description This method is used to create child cases for the Financial Accounts
   * @param parentCaseId Id of the parent case
   * @param caseInputs list of case data from wizard
   * @return List<Case> list of case inserted/updated case records
   */
  @AuraEnabled
  public static List<Case> createChildCasesForFinAccounts(
    Id parentCaseId,
    List<CaseInputWrapper> caseInputs
  ) {
    if (String.isBlank(parentCaseId) || caseInputs.isEmpty()) {
      return new List<Case>();
    }
    List<Case> listOfExistingUnUsedCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfExistingUnUsedCases(
      parentCaseId
    );
    Set<Id> caseIds = AccountClosureWizardControllerHelper.createAccountClosureChildCases(
      caseInputs,
      listOfExistingUnUsedCases
    );
    List<Case> listOfCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfInsertedOrUpdatedCases(
      caseIds
    );

    return listOfCases;
  }
}
