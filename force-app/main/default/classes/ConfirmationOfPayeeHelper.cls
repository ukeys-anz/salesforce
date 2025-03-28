/**
 *
 * @author Aman Gupta
 * @since 2025
 * @description ConfirmationOfPayeeHelper class is used to create Confirmation of Payee records
 */
public with sharing class ConfirmationOfPayeeHelper {
  private static final ConfirmationOfPayeeRepository CONFIRMATION_OF_PAYEE_REPO = (ConfirmationOfPayeeRepository) Lib_InstanceProvider.forType(
    ConfirmationOfPayeeRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String ERROR_LOG_MESSAGE_GET_COP = 'Error while fetching COP details from API';
  private static final String ERROR_LOG_MESSAGE_MODIFY_COP = 'Error while updating COP details on API';

  /**
   * @description Creates a request model for financial accounts' CoP status.
   * @param financialAccounts List of financial accounts.
   * @return An instance of `AccountCoPStatusRequestModel` populated with account identifiers.
   */
  public AccountCoPStatusRequestModel getCOPStatusRequest(
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    AccountCoPStatusRequestModel accountCoPStatusRequestModel = new AccountCoPStatusRequestModel();
    accountCoPStatusRequestModel.accountList = new List<AccountCoPStatusRequestModel.AccountList>();

    for (FinServ__FinancialAccount__c account : financialAccounts) {
      AccountCoPStatusRequestModel.AccountList accountEntry = new AccountCoPStatusRequestModel.AccountList();
      accountEntry.accountIdentification =
        account.BSB__c + account.FinServ__FinancialAccountNumber__c;
      accountCoPStatusRequestModel.accountList.add(accountEntry);
    }

    return accountCoPStatusRequestModel;
  }

  /**
   * @description Filters out financial accounts that already have existing cases.
   * @param mapAccNumVsFinAccounts A map of financial account numbers to financial accounts.
   * @param existingCasesForFinancialAccounts A list of existing cases related to financial accounts.
   */
  public void filterFinancialAccountsWithExistingCases(
    Map<String, FinServ__FinancialAccount__c> mapAccNumVsFinAccounts,
    List<Case> existingCasesForFinancialAccounts
  ) {
    for (Case caseRecord : existingCasesForFinancialAccounts) {
      mapAccNumVsFinAccounts.remove(
        caseRecord.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      );
    }
  }

  /**
   * @description Extracts and maps requestor details from the response data.
   * @param response The response object containing financial account data.
   * @return `Map<String, Account>` A map of requestor IDs to their respective Account records.
   */
  public Map<String, Account> populateRequestedByMap(
    FinancialAccountModelGetResponseCoP response
  ) {
    Set<String> requestedByIds = new Set<String>();

    for (
      FinancialAccountModelGetResponseCoP.AccountList acc : response.accountList
    ) {
      if (acc.requestedBy == null) {
        continue;
      }
      for (
        FinancialAccountModelGetResponseCoP.RequestedBy requestor : acc.requestedBy
      ) {
        requestedByIds.add(requestor?.requestorId);
      }
    }
    List<Account> accountList = CONFIRMATION_OF_PAYEE_REPO.getAccountsByOcvIds(
      new List<String>(requestedByIds)
    );
    Map<String, Account> mapRequestedByNames = (Map<String, Account>) ListUtil.mapBy(
      accountList,
      Account.OCV_Id__c
    );

    return mapRequestedByNames;
  }

  /**
   * @description Retrieves and maps user details who modified financial accounts.
   * @param response The response object containing financial account data.
   * @return `Map<String, User>` A map of modifier IDs to their respective User records.
   */
  public Map<String, User> populateModifiedByMap(
    FinancialAccountModelGetResponseCoP response
  ) {
    Set<String> modifiedByIds = new Set<String>();

    for (
      FinancialAccountModelGetResponseCoP.AccountList acc : response.accountList
    ) {
      modifiedByIds.add(acc?.modifiedBy?.modifierId);
    }
    List<User> userList = CONFIRMATION_OF_PAYEE_REPO.getUsersByLANId(
      modifiedByIds
    );
    Map<String, User> modifiedByMap = (Map<String, User>) ListUtil.mapBy(
      userList,
      User.Lan_Id__c
    );

    return modifiedByMap;
  }

  /**
   * @description Filters valid financial accounts based on their status and issue type.
   * @param response The response object containing financial account data.
   * @param financialAccounts A map of financial account numbers to financial accounts.
   * @param issueType The type of issue used for filtering (optional).
   * @return A map of valid financial accounts based on issue type and status.
   */
  public Map<String, FinServ__FinancialAccount__c> filterValidAccounts(
    FinancialAccountModelGetResponseCoP response,
    Map<String, FinServ__FinancialAccount__c> financialAccounts,
    String issueType
  ) {
    Map<String, FinServ__FinancialAccount__c> validFinAccounts = new Map<String, FinServ__FinancialAccount__c>();

    for (
      FinancialAccountModelGetResponseCoP.AccountList acc : response.accountList
    ) {
      String accNumber = acc?.accountIdentification?.substring(6);
      if (!financialAccounts.containsKey(accNumber)) {
        continue;
      }

      //When this is called from FA Detail Page Comp or Case Group Opt In Scenario
      Boolean isStatusMismatch =
        issueType == null ||
        acc.status == null ||
        !issueType.toUpperCase().contains(acc?.status?.toUpperCase());

      //When this is called from Case Group Opt Out Scenario For Joint Accounts Only
      Boolean isMultiPartyOptOut =
        financialAccounts.get(accNumber).Ownership__c ==
        CaseGroupCaseConstants.MULTI_PARTY &&
        issueType == CaseGroupCaseConstants.COP_OPT_OUT;

      if (isStatusMismatch || isMultiPartyOptOut) {
        validFinAccounts.put(accNumber, financialAccounts.get(accNumber));
      }
    }
    return validFinAccounts;
  }

  /**
   * @description Maps requestor IDs to their corresponding names.
   * @param response The response object containing financial account data.
   * @param mapRequestedByNames A map of requestor IDs to Account records.
   * @return Map<String, String> A map of financial account numbers to requestor names.
   */
  public Map<String, String> getRequestorNames(
    FinancialAccountModelGetResponseCoP response,
    Map<String, Account> mapRequestedByNames
  ) {
    Map<String, String> requestorNamesMap = new Map<String, String>();

    for (
      FinancialAccountModelGetResponseCoP.AccountList acc : response.accountList
    ) {
      String accNumber = acc.accountIdentification.substring(6);
      List<String> requestedByNames = new List<String>();
      if (acc.requestedBy == null) {
        continue;
      }
      for (
        FinancialAccountModelGetResponseCoP.RequestedBy reqBy : acc.requestedBy
      ) {
        if (mapRequestedByNames.containsKey(reqBy.requestorId)) {
          requestedByNames.add(mapRequestedByNames.get(reqBy.requestorId).Name);
        }
      }
      requestorNamesMap.put(accNumber, String.join(requestedByNames, ', '));
    }

    return requestorNamesMap;
  }

  /**
   * @description Maps financial accounts to a structured model for case grouping.
   * @param response The response object containing financial account data.
   * @param financialAccounts A map of financial account numbers to financial accounts.
   * @param requestorNamesMap A map of financial account numbers to requestor names.
   * @param modifiedByUsers A map of modifier IDs to User records.
   * @return A list of CaseGroupFinancialAccountModel objects containing financial account details.
   */
  public List<CaseGroupFinancialAccountModel> mapFinancialAccountsToModels(
    FinancialAccountModelGetResponseCoP response,
    Map<String, FinServ__FinancialAccount__c> financialAccounts,
    Map<String, String> requestorNamesMap,
    Map<String, User> modifiedByUsers
  ) {
    List<CaseGroupFinancialAccountModel> caseGroupFinAccModel = new List<CaseGroupFinancialAccountModel>();

    for (
      FinancialAccountModelGetResponseCoP.AccountList acc : response.accountList
    ) {
      String accNumber = acc?.accountIdentification?.substring(6);
      if (!financialAccounts.containsKey(accNumber)) {
        continue;
      }

      CaseGroupFinancialAccountModel account = new CaseGroupFinancialAccountModel();
      FinServ__FinancialAccount__c finAccount = financialAccounts.get(
        accNumber
      );
      account.accountNumber = finAccount.FinServ__FinancialAccountNumber__c;

      if (acc.error != null) {
        account.isError = true;
        caseGroupFinAccModel.add(account);
        Logger.error(ERROR_LOG_MESSAGE_GET_COP, account.id);
        continue;
      }

      account.id = finAccount.Id;
      account.productName = finAccount.FinServ__ProductName__r.Name;
      account.finAccountType = CaseGroupCaseConstants.FIN_ACCOUNT_TYPE_FOR_UI.get(
        finAccount.Ownership__c
      );
      account.productId = finAccount.FinServ__ProductName__c;
      account.apiFinAccountType = CaseGroupCaseConstants.FIN_ACCOUNT_TYPE.get(
        finAccount.Ownership__c
      );
      account.accountStatusCOP = CaseGroupCaseConstants.CAPS_COP_STATUS.get(
        acc.status
      );
      account.updateAccountStatusCOP = CaseGroupCaseConstants.COP_STATUS.get(
        account.accountStatusCOP
      );
      account.requestedByName = requestorNamesMap.get(accNumber);
      account.modifiedByName = modifiedByUsers.containsKey(
          acc?.modifiedBy?.modifierId
        )
        ? modifiedByUsers.get(acc?.modifiedBy?.modifierId).Name
        : '';
      account.statusChangeDateTime = acc.statusUpdateDate;
      account.accountingSystem = acc.accountingSystem;
      caseGroupFinAccModel.add(account);
    }

    Logger.saveLog();
    return caseGroupFinAccModel;
  }

  /**
   * @description Constructs a list of CoP update requests from eligible cases.
   * @param eligibleCases List of case records eligible for CoP updates.
   * @return FinancialAccModelUpdateRequestCoP objects.
   */
  public FinancialAccModelUpdateRequestCoP getUpdateCOPRequest(
    List<Case> eligibleCases
  ) {
    FinancialAccModelUpdateRequestCoP updateRequestList = new FinancialAccModelUpdateRequestCoP();
    updateRequestList.accountList = new List<FinancialAccModelUpdateRequestCoP.AccountList>();
    for (Case caseObj : eligibleCases) {
      FinancialAccModelUpdateRequestCoP.AccountList model = new FinancialAccModelUpdateRequestCoP.AccountList();
      model.accountCoPStatus = caseObj.Parent.Type;
      model.accountIdentification =
        caseObj.FinServ__FinancialAccount__r.BSB__c +
        caseObj.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c;
      model.copStatusReason = caseObj.Opt_Out_Reason__c;
      model.accountingSystem = caseObj.SI_PSI_Source_Other__c;
      FinancialAccModelUpdateRequestCoP.RequestedBy requestor = new FinancialAccModelUpdateRequestCoP.RequestedBy();
      requestor.requestorIdType = 'OCVID';
      requestor.requestorId = caseObj.Account.OCV_Id__c;

      model.requestedBy = new List<FinancialAccModelUpdateRequestCoP.RequestedBy>{
        requestor
      };
      updateRequestList.accountList.add(model);
    }
    return updateRequestList;
  }

  /**
   * @description Extracts and maps requestor details from the update response data.
   * @param response The response object containing financial account update data.
   * @return A map of requestor IDs to their respective Account records.
   */
  public Map<String, Account> populateRequestedByMap(
    FinancialAccModelUpdateResponseCoP response
  ) {
    Set<String> requestedByIds = new Set<String>();

    for (
      FinancialAccModelUpdateResponseCoP.AccountList acc : response.accountList
    ) {
      if (acc.requestedBy == null) {
        continue;
      }
      for (
        FinancialAccModelUpdateResponseCoP.RequestedBy requestor : acc.requestedBy
      ) {
        requestedByIds.add(requestor.requestorId);
      }
    }

    List<Account> accountsByOcvId = CONFIRMATION_OF_PAYEE_REPO.getAccountsByOcvIds(
      new List<String>(requestedByIds)
    );

    Map<String, Account> mapRequestedByNames = (Map<String, Account>) ListUtil.mapBy(
      accountsByOcvId,
      Account.OCV_Id__c
    );

    return mapRequestedByNames;
  }

  /**
   * @description Retrieves and maps user details who modified financial accounts.
   * @param response The response object containing financial account update data.
   * @return A map of modifier IDs to their respective User records.
   */
  public Map<String, User> populateModifiedByMap(
    FinancialAccModelUpdateResponseCoP response
  ) {
    Set<String> modifiedByIds = new Set<String>();

    for (
      FinancialAccModelUpdateResponseCoP.AccountList acc : response.accountList
    ) {
      modifiedByIds.add(acc?.modifiedBy?.modifierId);
    }
    List<User> userList = CONFIRMATION_OF_PAYEE_REPO.getUsersByLANId(
      modifiedByIds
    );
    Map<String, User> modifiedByMap = (Map<String, User>) ListUtil.mapBy(
      userList,
      User.Lan_Id__c
    );

    return modifiedByMap;
  }

  /**
   * @description Populates a mapping of successful financial account numbers to a list of associated customers.
   * @param response The response object containing financial account update data.
   * @return A map of financial account numbers to a list of related customer IDs.
   */
  public Map<String, List<String>> populateSuccessFinancialAccNumberVsCustomerList(
    FinancialAccModelUpdateResponseCoP response
  ) {
    Map<String, List<String>> successFinancialAccNumberVsCustomerList = new Map<String, List<String>>();
    Set<String> successFinancialAccNumbers = new Set<String>();

    // Collect successful financial account numbers from the response
    for (
      FinancialAccModelUpdateResponseCoP.AccountList acc : response.accountList
    ) {
      if (acc.error == null) {
        // Extracting the last part of account identification (after 6 characters)
        successFinancialAccNumbers.add(acc.accountIdentification.substring(6));
      }
    }

    // Fetching financial account roles and mapping related accounts
    for (
      FinServ__FinancialAccountRole__c finAccRole : CONFIRMATION_OF_PAYEE_REPO.getFinAccountRolesByAccountNum(
        successFinancialAccNumbers
      )
    ) {
      String financialAccountNumber = finAccRole.FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c;
      String relatedAccount = finAccRole.FinServ__RelatedAccount__c;

      if (
        !successFinancialAccNumberVsCustomerList.containsKey(
          financialAccountNumber
        )
      ) {
        successFinancialAccNumberVsCustomerList.put(
          financialAccountNumber,
          new List<String>()
        );
      }
      successFinancialAccNumberVsCustomerList.get(financialAccountNumber)
        .add(relatedAccount);
    }
    return successFinancialAccNumberVsCustomerList;
  }

  /**
   * @description Maps requestor IDs to their corresponding names based on the update response data.
   * @param response The response object containing financial account update data.
   * @param mapRequestedByNames A map of requestor IDs to Account records.
   * @return A map of financial account numbers to requestor names.
   */
  public Map<String, String> getRequestorNames(
    FinancialAccModelUpdateResponseCoP response,
    Map<String, Account> mapRequestedByNames
  ) {
    Map<String, String> requestorNamesMap = new Map<String, String>();

    for (
      FinancialAccModelUpdateResponseCoP.AccountList acc : response.accountList
    ) {
      String accNumber = acc.accountIdentification.substring(6);
      List<String> requestedByNames = new List<String>();
      if (acc.requestedBy == null) {
        continue;
      }
      for (
        FinancialAccModelUpdateResponseCoP.RequestedBy reqBy : acc.requestedBy
      ) {
        if (mapRequestedByNames.containsKey(reqBy.requestorId)) {
          requestedByNames.add(mapRequestedByNames.get(reqBy.requestorId).Name);
        }
      }
      requestorNamesMap.put(accNumber, String.join(requestedByNames, ', '));
    }

    return requestorNamesMap;
  }

  /**
   * @description Retrieves a list of cases and their CoP status based on financial account mappings.
   * @param response The response object containing CoP update details.
   * @param financialAccNumAndCaseMap A mapping of financial account numbers to Case records.
   * @param requestorNamesMap A map of financial account numbers to requestor names.
   * @param modfiedByUsers A map of modifier IDs to User records.
   * @return CaseDetailsContainer A container holding successful and failed case updates.
   */
  public CaseDetailsContainer mapUpdateCOPStatusResponse(
    FinancialAccModelUpdateResponseCoP response,
    Map<String, Case> financialAccNumAndCaseMap,
    Map<String, String> requestorNamesMap,
    Map<String, User> modfiedByUsers
  ) {
    CaseDetailsContainer caseDetailsContainer = new CaseDetailsContainer();
    for (
      FinancialAccModelUpdateResponseCoP.AccountList account : response.accountList
    ) {
      //Getting Substring to remove the BSB prefix
      String accNumber = account.accountIdentification?.substring(6);
      if (!financialAccNumAndCaseMap.containsKey(accNumber)) {
        continue;
      }
      Case caseObj = financialAccNumAndCaseMap.get(accNumber);
      CaseDetailsContainer.CaseDetailsWithCoPStatus caseDetail = new CaseDetailsContainer.CaseDetailsWithCoPStatus();
      caseDetail.accountNumber = account.accountIdentification?.substring(6);
      caseDetail.accountingSystem = caseObj.SI_PSI_Source_Other__c;
      caseDetail.productName = caseObj.Product.Name;
      caseDetail.accountType = CaseGroupCaseConstants.FIN_ACCOUNT_TYPE_FOR_UI.get(
        caseObj.FinServ__FinancialAccount__r.Ownership__c
      );
      caseDetail.caseId = caseObj.Id;
      caseDetail.caseNumber = caseObj.CaseNumber;
      caseDetail.childCaseNumberUrl = '/' + caseObj.Id;
      caseDetail.requestedByName = requestorNamesMap.containsKey(accNumber)
        ? requestorNamesMap.get(accNumber)
        : '';
      caseDetail.modifiedByName = modfiedByUsers.containsKey(
          account?.modifiedBy?.modifierId
        )
        ? modfiedByUsers.get(account?.modifiedBy?.modifierId).Name
        : '';
      if (account.error == null) {
        caseDetail.caseCoPStatus = account?.accountCoPStatus;
        caseDetail.statusChangeDateTime = account?.copStatusUpdateDate;
        caseDetailsContainer.successList.add(caseDetail);
        continue;
      }
      caseDetailsContainer.failureList.add(caseDetail);
      Logger.error(ERROR_LOG_MESSAGE_MODIFY_COP, caseDetail.caseId);
    }
    Logger.saveLog();
    return caseDetailsContainer;
  }

  /**
   * @description Updates case records based on the success or failure of CoP processing.
   * Successful cases are marked as 'Closed' with a 'Success' sub-status,
   * while failed cases are updated with a 'Failed' sub-status.
   * @param containerWrapper A container holding case details for both successful and failed CoP status updates.
   */
  public void updateCaseRecords(CaseDetailsContainer containerWrapper) {
    List<Case> casesToUpdate = new List<Case>();
    for (
      CaseDetailsContainer.CaseDetailsWithCoPStatus caseDetails : containerWrapper.successList
    ) {
      casesToUpdate.add(
        new Case(
          Id = caseDetails.caseId,
          Status = CaseGroupCaseConstants.CLOSED_STATUS,
          Sub_Status__c = TFMConstants.EMPTY
        )
      );
    }
    DML_REPOSITORY.doUpdate(casesToUpdate);
  }

  /**
   * @description Posts a response message to Chatter for successfully processed financial account cases.
   * @param containerWrapper A container holding details of financial accounts that were successfully processed.
   * @param successFinancialAccNumberVsCustomerList A map of financial account number to a list of customer Ids.
   */
  public void postResponseMessageToChatter(
    CaseDetailsContainer containerWrapper,
    Map<String, List<String>> successFinancialAccNumberVsCustomerList
  ) {
    for (
      CaseDetailsContainer.CaseDetailsWithCoPStatus caseDetails : containerWrapper.successList
    ) {
      //Always post a chatter to Case
      ChatterUtils.makeAPost(
        caseDetails.caseId,
        getChatterMessageRichText(caseDetails),
        ChatterUtils.POST_TYPE_RICH_TEXT
      );

      //Only continue to all customers & Joint customers if account is Multi party
      if (caseDetails.accountType != CaseGroupCaseConstants.JOINT) {
        continue;
      }

      List<String> customerIds = successFinancialAccNumberVsCustomerList.get(
        caseDetails.accountNumber
      );

      for (String customerId : customerIds) {
        ChatterUtils.makeAPost(
          customerId,
          getChatterMessageRichText(caseDetails),
          ChatterUtils.POST_TYPE_RICH_TEXT
        );
      }
    }
  }

  /**
   * @description Generates a formatted Chatter message in rich text format based on the given case details.
   * @param caseDetails An object containing case details including CoP status, status change date, requestor name, and actioned by name.
   * @return String A rich-text formatted string containing the Confirmation of Payee details.
   */
  private String getChatterMessageRichText(
    CaseDetailsContainer.CaseDetailsWithCoPStatus caseDetails
  ) {
    DateTime dt = Datetime.valueOf(
      caseDetails?.statusChangeDateTime?.replace('T', ' ')?.replace('Z', '')
    );
    String dateString = dt.format('dd/MM/yyyy');
    String message =
      '<p><b>Confirmation of Payee - ' +
      caseDetails.caseCoPStatus +
      '</b> </p>' +
      '<p><b>Account Ending: </b>' +
      TextUtils.maskData(caseDetails.accountNumber) +
      '</p>' +
      '<p><b>Requested by: </b>' +
      caseDetails.requestedByName +
      '</p>' +
      '<p><b>Actioned By: </b>' +
      caseDetails.modifiedByName +
      '</p>' +
      '<p><b>Date of request: </b>' +
      dateString +
      '</p>';

    return message;
  }
}
