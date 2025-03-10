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
    List<UnifiedFinancialAccountModel.AccountList> financialAccountsList = FinancialAccountController.getFinancialAccountsFromFabric(
      ocvId,
      new List<String>()
    );

    List<Id> finAccountId = (List<Id>) ListUtil.getValues(
      financialAccountsList,
      'id',
      String.class
    );

    Set<Id> finAccountIds = new Set<Id>(finAccountId);

    List<Case> existingCasesForFinancialAccounts = ACCOUNT_CLOSURE_REPOSITORY.getCasesByFinancialAccountIds(
      finAccountIds
    );

    finAccountIds.removeAll(
      ListUtil.getIds(
        existingCasesForFinancialAccounts,
        Case.FinServ__FinancialAccount__c
      )
    );

    return ACCOUNT_CLOSURE_REPOSITORY.fetchFilteredFinancialAccountsDetails(
      finAccountIds
    );
  }

  /**
   * @description This method is used to create child cases for the Financial Accounts
   * @param parentCaseId Id of the parent case
   * @param childCaseInputs list of case data from wizard
   * @return List<Case> list of case inserted/updated case records
   */
  @AuraEnabled
  public static List<Case> createChildCasesForFinAccounts(
    Id parentCaseId,
    List<CaseInputWrapper> childCaseInputs
  ) {
    if (String.isBlank(parentCaseId) || childCaseInputs.isEmpty()) {
      return new List<Case>();
    }
    List<Case> casesToUpdate = new List<Case>();
    List<Case> casesToInsert = new List<Case>();
    List<Case> listOfExistingUnUsedCases = ACCOUNT_CLOSURE_REPOSITORY.getUnusedChildCasesByParentId(
      parentCaseId
    );

    processCaseInputs(
      childCaseInputs,
      listOfExistingUnUsedCases,
      casesToUpdate,
      casesToInsert
    );

    DML_REPOSITORY.doUpdate(casesToUpdate);
    DML_REPOSITORY.doInsert(casesToInsert);

    Set<Id> caseIds = new Set<Id>();
    caseIds.addAll(ListUtil.getIds(casesToUpdate, Case.Id));
    caseIds.addAll(ListUtil.getIds(casesToInsert, Case.Id));

    return ACCOUNT_CLOSURE_REPOSITORY.getInsertedOrUpdatedCaseDetails(caseIds);
  }

  /**
   * @description proccess case inputs and update or create cases
   * @param childCaseInputs case inputs from wizard
   * @param listOfExistingUnUsedCases case record to be updated
   * @param casesToUpdate list of case to be updated
   * @param casesToInsert list of case to be inserted
   */
  private static void processCaseInputs(
    List<CaseInputWrapper> childCaseInputs,
    List<Case> listOfExistingUnUsedCases,
    List<Case> casesToUpdate,
    List<Case> casesToInsert
  ) {
    for (CaseInputWrapper eachInput : childCaseInputs) {
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
