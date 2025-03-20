/**
 * @author Aman Gupta
 * @since 03/2025
 * @description  ConfirmationOfPayeeController is the controller class for Confirmation of Payee Issue Type Actions.
 */
public with sharing class ConfirmationOfPayeeController implements CaseGroupWizard {
  private static final ConfirmationOfPayeeRepository CONFIRMATION_OF_PAYEE_REPO = (ConfirmationOfPayeeRepository) Lib_InstanceProvider.forType(
    ConfirmationOfPayeeRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final ConfirmationOfPayeeHelper COP_HELPER = new ConfirmationOfPayeeHelper();
  /**
   * @description Fetches financial account data and filters existing cases before calling the CoP service.
   * @param params A map containing request parameters, including 'ocvId' and 'parentCaseId'.
   * @return A list of financial account models with their respective CoP statuses.
   */
  public List<CaseGroupFinancialAccountModel> getData(
    Map<String, String> params
  ) {
    List<FinServ__FinancialAccount__c> listOfFinAccounts = CONFIRMATION_OF_PAYEE_REPO.fetchFinancialAccountsByOCVId(
      params.get('ocvId')
    );

    Map<String, FinServ__FinancialAccount__c> mapOfFinAccNumToFinAccounts = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
      listOfFinAccounts,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
    );

    List<Case> existingCasesForFinancialAccounts = CONFIRMATION_OF_PAYEE_REPO.getCasesByFinancialAccountIds(
      mapOfFinAccNumToFinAccounts.keySet(),
      params.get('parentCaseId')
    );

    COP_HELPER.filterFinancialAccountsWithExistingCases(
      mapOfFinAccNumToFinAccounts,
      existingCasesForFinancialAccounts
    );

    AccountCoPStatusRequestModel request = COP_HELPER.getCOPStatusRequest(
      mapOfFinAccNumToFinAccounts.values()
    );

    FetchFinAccCOPStatusAPIRepository apiRepo = new FetchFinAccCOPStatusAPIRepository();
    FinancialAccountModelGetResponseCoP response = apiRepo.getAccountCoPdetails(
      request,
      params.get('ocvId')
    );

    Map<String, Account> requestedByNames = COP_HELPER.populateRequestedByMap(
      response
    );
    Map<String, User> modfiedByUsers = COP_HELPER.populateModifiedByMap(
      response
    );

    Map<String, String> requestorNamesMap = COP_HELPER.getRequestorNames(
      response,
      requestedByNames
    );

    Map<String, FinServ__FinancialAccount__c> filteredAccounts = COP_HELPER.filterValidAccounts(
      response,
      mapOfFinAccNumToFinAccounts,
      params.get('issueType')
    );

    List<CaseGroupFinancialAccountModel> accountModel = COP_HELPER.mapFinancialAccountsToModels(
      response,
      filteredAccounts,
      requestorNamesMap,
      modfiedByUsers
    );

    return accountModel;
  }

  /**
   * @description Initiates a Modify CoP request by updating CoP statuses for eligible cases.
   * @param ocvId The OCV ID associated with the parent case for which mofication of COP Status is initiated.
   * @param eligibleCases The list of cases eligible for CoP status update.
   * @return A container with updated CoP status details for the cases.
   */
  @AuraEnabled
  public static CaseDetailsContainer initiateModifyConfirmationOfPayee(
    String ocvId,
    List<Case> eligibleCases
  ) {
    FinancialAccModelUpdateRequestCoP updateCOPStatusRequest = COP_HELPER.getUpdateCOPRequest(
      eligibleCases
    );
    Map<String, Case> financialAccNumAndCaseMap = (Map<String, Case>) ListUtil.mapBy(
      eligibleCases,
      Case.Customer_Account_Number__c
    );
    UpdateFinAccCOPStatusAPIRepository apiRepo = new UpdateFinAccCOPStatusAPIRepository();
    FinancialAccModelUpdateResponseCoP response = apiRepo.updateAccountCoPdetails(
      updateCOPStatusRequest,
      ocvId
    );

    Map<String, Account> requestedByNames = COP_HELPER.populateRequestedByMap(
      response
    );

    Map<String, User> modfiedByUsers = COP_HELPER.populateModifiedByMap(
      response
    );

    Map<String, String> requestorNamesMap = COP_HELPER.getRequestorNames(
      response,
      requestedByNames
    );

    Map<String, List<String>> successFinancialAccNumberVsCustomerList = COP_HELPER.populateSuccessFinancialAccNumberVsCustomerList(
      response
    );

    CaseDetailsContainer caseDetailsContainer = COP_HELPER.mapUpdateCOPStatusResponse(
      response,
      financialAccNumAndCaseMap,
      requestorNamesMap,
      modfiedByUsers
    );

    COP_HELPER.updateCaseRecords(caseDetailsContainer);
    COP_HELPER.postResponseMessageToChatter(
      caseDetailsContainer,
      successFinancialAccNumberVsCustomerList
    );
    return caseDetailsContainer;
  }

  /**
   * @description Fetch Eligible Cases for Moficiation in COP Status
   * @param parentCaseId Input Date from LWC
   * @return List<Case> eligible case list
   */
  @AuraEnabled
  public static List<Case> fetchChildCasesCoP(Id parentCaseId) {
    return CONFIRMATION_OF_PAYEE_REPO.getCasesByParentId(parentCaseId);
  }

  /**
   * @description Fetch COP Information
   * @param financialAccountId Id of Financial Account
   * @return CaseGroupFinancialAccountModel financial account information related to COP
   */
  @AuraEnabled(cacheable=true)
  public static List<CaseGroupFinancialAccountModel> fetchCOPInformation(
    Id financialAccountId
  ) {
    FinServ__FinancialAccount__c finAccount = CONFIRMATION_OF_PAYEE_REPO.getFinancialAccountById(
      financialAccountId
    );

    AccountCoPStatusRequestModel request = COP_HELPER.getCOPStatusRequest(
      new List<FinServ__FinancialAccount__c>{ finAccount }
    );

    FetchFinAccCOPStatusAPIRepository apiRepo = new FetchFinAccCOPStatusAPIRepository();
    FinancialAccountModelGetResponseCoP response = apiRepo.getAccountCoPdetails(
      request,
      finAccount.FinServ__PrimaryOwner__r.OCV_ID__c
    );

    Map<String, Account> requestedByNames = COP_HELPER.populateRequestedByMap(
      response
    );

    Map<String, User> modfiedByUsers = COP_HELPER.populateModifiedByMap(
      response
    );

    Map<String, String> requestorNamesMap = COP_HELPER.getRequestorNames(
      response,
      requestedByNames
    );

    Map<String, FinServ__FinancialAccount__c> filteredAccounts = COP_HELPER.filterValidAccounts(
      response,
      new Map<String, FinServ__FinancialAccount__c>{
        finAccount.FinServ__FinancialAccountNumber__c => finAccount
      },
      null
    );

    List<CaseGroupFinancialAccountModel> accountModel = COP_HELPER.mapFinancialAccountsToModels(
      response,
      filteredAccounts,
      requestorNamesMap,
      modfiedByUsers
    );

    return accountModel;
  }
}
