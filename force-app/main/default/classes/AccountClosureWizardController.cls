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

    Set<Id> accountIds = ListUtil.getIds(
      listOfFinAccounts,
      FinServ__FinancialAccount__c.Id
    );

    accountIds.removeAll(
      ListUtil.getIds(
        ACCOUNT_CLOSURE_REPOSITORY.fetchChildCasesRelatedToFinAccounts(
          accountIds
        ),
        Case.FinServ__FinancialAccount__c
      )
    );

    return ACCOUNT_CLOSURE_REPOSITORY.fetchFinancialAccounts(accountIds);
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
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    List<Case> listOfExistingUnUsedCases = ACCOUNT_CLOSURE_REPOSITORY.queryListOfExistingUnUsedCases(
      parentCaseId
    );

    processCaseInputsAndUpdateOrCreate(
      caseInputs,
      listOfExistingUnUsedCases,
      casesToUpdate,
      casesToInsert
    );

    DML_REPOSITORY.doUpdate(casesToUpdate);
    DML_REPOSITORY.doInsert(casesToInsert);

    Set<Id> caseIds = new Set<Id>();
    caseIds.addAll(ListUtil.getIds(casesToUpdate, Case.Id));
    caseIds.addAll(ListUtil.getIds(casesToInsert, Case.Id));

    return ACCOUNT_CLOSURE_REPOSITORY.queryListOfInsertedOrUpdatedCases(
      caseIds
    );
  }

  /**
   * @description proccess case inputs and update or create cases
   * @param caseInputs case inputs from wizard
   * @param listOfExistingUnUsedCases case record to be updated
   * @param casesToUpdate list of case to be updated
   * @param casesToInsert list of case to be inserted
   */
  private static void processCaseInputsAndUpdateOrCreate(
    List<CaseInputWrapper> caseInputs,
    List<Case> listOfExistingUnUsedCases,
    List<Case> casesToUpdate,
    List<Case> casesToInsert
  ) {
    for (CaseInputWrapper eachInput : caseInputs) {
      if (!listOfExistingUnUsedCases.isEmpty()) {
        Case existingCase = listOfExistingUnUsedCases.remove(0);
        mapCaseFields(existingCase, eachInput);
        casesToUpdate.add(existingCase);
      } else {
        Case newCase = new Case();
        mapCaseFields(newCase, eachInput);
        casesToInsert.add(newCase);
      }
    }
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
