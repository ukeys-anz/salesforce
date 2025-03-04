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
    Map<String, Object> groupedFinAccounts = FinancialAccountController.getFinancialAccountFabric(
      ocvId,
      new List<String>()
    );

    Set<Id> finAccountIds = getFinancialAccountIdsFromFabricResponse(
      groupedFinAccounts
    );

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

  /**
   * @description Get the Id of Financial Account records received from Fabric api
   * @param groupedFinancialAccounts grouped financial accounts based on the marketing code eg: TRANSACT01,SAVING01
   * @return Id of the financial account
   */
  @TestVisible
  private static Set<Id> getFinancialAccountIdsFromFabricResponse(
    Map<String, object> groupedFinancialAccounts
  ) {
    List<Map<String, Object>> groupedFinancialAccountsList = (List<Map<String, Object>>) groupedFinancialAccounts.get(
      'groupedAccounts'
    );

    List<UnifiedFinancialAccountModel.AccountList> allFinAccounts = collectAllFinancialAccounts(
      groupedFinancialAccountsList
    );

    return addFinancialAccountIds(allFinAccounts);
  }

  private static List<UnifiedFinancialAccountModel.AccountList> collectAllFinancialAccounts(
    List<Map<String, Object>> groupedFinancialAccountsList
  ) {
    List<UnifiedFinancialAccountModel.AccountList> allFinAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    for (Map<String, Object> finAccountGroup : groupedFinancialAccountsList) {
      List<UnifiedFinancialAccountModel.AccountList> finAccountList = (List<UnifiedFinancialAccountModel.AccountList>) finAccountGroup.get(
        'accounts'
      );
      allFinAccounts.addAll(finAccountList);
    }

    return allFinAccounts;
  }

  private static Set<Id> addFinancialAccountIds(
    List<UnifiedFinancialAccountModel.AccountList> allFinAccounts
  ) {
    Set<Id> finaccountIds = new Set<Id>();
    for (
      UnifiedFinancialAccountModel.AccountList finAccountRecord : allFinAccounts
    ) {
      if (String.isNotBlank(finAccountRecord.id)) {
        finaccountIds.add(finAccountRecord.id);
      }
    }
    return finaccountIds;
  }
}
