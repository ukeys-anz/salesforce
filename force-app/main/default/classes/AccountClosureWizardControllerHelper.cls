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
   * @description filter financial accounts linked with case
   * @param listOfFinAccounts List of Financial Account
   * @return List<FinServ__FinancialAccount__c> list of filtered Financial Accounts
   */
  public static List<FinServ__FinancialAccount__c> filterFinancialAccountsLinkedWithCase(
    List<FinServ__FinancialAccount__c> listOfFinAccounts
  ) {
    Set<Id> accountIds = ListUtil.getIds(
      listOfFinAccounts,
      FinServ__FinancialAccount__c.Id
    );
    List<Case> childCases = ACCOUNT_CLOSURE_REPOSITORY.fetchChildCasesRelatedToFinAccounts(
      accountIds
    );
    Set<Id> setOfFinAccountIdsToExclude = ListUtil.getIds(
      childCases,
      Case.FinServ__FinancialAccount__c
    );
    accountIds.removeAll(setOfFinAccountIdsToExclude);
    List<FinServ__FinancialAccount__c> listOfFilteredFinAccounts = ACCOUNT_CLOSURE_REPOSITORY.fetchFinancialAccounts(
      accountIds
    );
    return listOfFilteredFinAccounts;
  }

  /**
   * @description create new Case records and update unused case records if found
   * @param inputs List of CaseInputWrapper from LWC
   * @param listOfExistingChildCases List of Cases
   * @return Set<Id>
   */
  public static Set<Id> createAccountClosureChildCases(
    List<CaseInputWrapper> inputs,
    List<Case> listOfExistingChildCases
  ) {
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    Set<Id> setOfCaseIds = new Set<Id>();

    for (CaseInputWrapper eachInput : inputs) {
      if (!listOfExistingChildCases.isEmpty()) {
        Case existingCase = listOfExistingChildCases.remove(0);
        mapCaseFields(existingCase, eachInput);
        casesToUpdate.add(existingCase);
      } else {
        Case newCase = new Case();
        mapCaseFields(newCase, eachInput);
        casesToInsert.add(newCase);
      }
    }

    DML_REPOSITORY.doUpdate(casesToUpdate);
    setOfCaseIds.addAll(ListUtil.getIds(casesToUpdate, Case.Id));

    DML_REPOSITORY.doInsert(casesToInsert);
    setOfCaseIds.addAll(ListUtil.getIds(casesToInsert, Case.Id));

    return setOfCaseIds;
  }

  /**
   * @description map case fields from CaseInputWrapper to Case
   * @param caseObj case object record to be inserted or updated
   * @param caseInput from LWC
   */
  private static void mapCaseFields(Case caseObj, CaseInputWrapper caseInput) {
    caseObj.Intended_Account_Name__c = caseInput.intendedAccountName;
    caseObj.Intended_Account_BSB__c = caseInput.intendedAccountBsb;
    caseObj.Intended_Account_Number__c = caseInput.intendedAccountNumber;
    caseObj.Closure_Reason__c = caseInput.closureReason;
    caseObj.Account_Type__c = caseInput.accountType;
    caseObj.AccountId = caseInput.accountId;
    caseObj.FinServ__FinancialAccount__c = caseInput.financialAccountId;
    caseObj.ProductId = caseInput.productId;
    caseObj.RecordTypeId = RTCase.accountClosure;
  }
}
