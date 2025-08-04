/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialAccountController retrieves account details for the financialAccount LWC and the FinancialGoals LWC
 */
public with sharing class FinancialAccountController {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );

  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  public static final String FAILED_TO_RETRIEVE = 'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator';
  public static final String FAILED_FIN_ACCOUNT_UPDATE = 'Failed to update accounts. Please refresh and try again. If issue persists please contact your System Administrator';
  private static final Integer DEFAULT_SORT_ORDER = 999;

  //Map of fabric statuses and user friendly names to map them to
  private static final Map<String, String> FABRIC_STATUSES = new Map<String, String>{
    //State Mapping for v1
    'ACCOUNT_STATE_UNSPECIFIED' => 'Unspecified',
    'ACCOUNT_STATE_OPEN' => 'Open',
    'ACCOUNT_STATE_ACTIVE' => 'Active',
    'ACCOUNT_STATE_SUSPENDED' => 'Suspended',
    'ACCOUNT_STATE_DORMANT' => 'Dormant',
    'ACCOUNT_STATE_CLOSED' => 'Closed'
  };

  //Map of fabric ownership and user friendly names to map them to
  private static final Map<String, String> FABRIC_OWNERSHIP = new Map<String, String>{
    'OWNERSHIP_TYPE_MULTIPARTY' => 'Multi-party',
    'OWNERSHIP_TYPE_SINGLEPARTY' => 'Single'
  };

  //Map of fabric ownership and user friendly names for UI
  private static final Map<String, String> FABRIC_OWNERSHIP_UI = new Map<String, String>{
    'OWNERSHIP_TYPE_MULTIPARTY' => 'Joint',
    'OWNERSHIP_TYPE_SINGLEPARTY' => 'Single'
  };

  /**
   * @description This method is an orchestration layer for retrieving financial accounts, grouped accounts , add metadata values and sort grouped records
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return Grouped Financial Accounts based on product code.
   */
  @AuraEnabled
  public static List<UnifiedFinancialAccountModel> getFinancialAccountFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    try {
      List<UnifiedFinancialAccountModel.AccountList> fabricAccountList = getFinancialAccountsFromFabric(
        ocvId,
        accountNumbers
      );

      if (fabricAccountList.isEmpty()) {
        return new List<UnifiedFinancialAccountModel>();
      }

      List<UnifiedFinancialAccountModel.AccountList> homeloanaccounts = filterOutNonHomeLoanAccounts(
        fabricAccountList
      );

      DataPartitionUtil.storeLoanAccountDetailsCache(ocvId, homeloanaccounts);

      List<UnifiedFinancialAccountModel> processedAccounts = FinancialAccountControllerAction.processFinancialAccounts(
        fabricAccountList
      );

      return processedAccounts;
    } catch (DmlException dmlExp) {
      throw new AuraHandledException(FAILED_FIN_ACCOUNT_UPDATE);
    } catch (Exception e) {
      throw new AuraHandledException(FAILED_TO_RETRIEVE);
    }
  }

  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return list of financial accounts received from fabric
   */
  public static List<UnifiedFinancialAccountModel.AccountList> getFinancialAccountsFromFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    FinancialAccountAPIRepository financiAccountApi = new FinancialAccountAPIRepository();
    UnifiedFinancialAccountModel result = financiAccountApi.getAccounts(
      ocvId,
      accountNumbers
    );

    if (result.accounts == null) {
      return new List<UnifiedFinancialAccountModel.AccountList>();
    }

    List<String> financialAccountNumbers = (List<String>) ListUtil.getValues(
      result.accounts,
      'account_number',
      String.class
    );

    List<FinServ__FinancialAccount__c> financialAccountList = FINANCIAL_ACCOUNT_REPOSITORY.getFinAccountList(
      financialAccountNumbers
    );

    Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
      financialAccountList,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
    );

    List<UnifiedFinancialAccountModel.AccountList> processedFinancialAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    List<FinServ__FinancialAccount__c> financialAccountsToUpdate = new List<FinServ__FinancialAccount__c>();

    for (
      UnifiedFinancialAccountModel.AccountList finAccount : result.accounts
    ) {
      FinServ__FinancialAccount__c finAccountFromDatabase = finAccNumberToFinancialAccountMap.get(
        finAccount.account_number
      );
      UnifiedFinancialAccountModel.AccountList finAccountRecord = getFinancialAccountInstance(
        finAccount,
        finAccountFromDatabase
      );
      processedFinancialAccounts.add(finAccountRecord);

      if (finAccountFromDatabase != null) {
        FinServ__FinancialAccount__c finAccountRecordToUpdate = getFinancialAccountInstanceToUpdate(
          finAccount,
          finAccountFromDatabase
        );
        financialAccountsToUpdate.add(finAccountRecordToUpdate);
      }
    }

    financialAccountsToUpdate.addAll(
      updateDigitallyConnectedAccountFlag(ocvId, financialAccountNumbers)
    );
    DML.doUpdate(financialAccountsToUpdate, new DmlConfig().withoutSharing());

    return processedFinancialAccounts;
  }

  /**
   * @description Set digitally active flag to false if the fin account is not present in the list of fin accounts
   * received from the API
   * @param ocvId the ocv id of the customer
   * @param financialAccountNumbers fin account number
   * @return List<FinServ__FinancialAccount__c> list of financial accounts
   */
  @TestVisible
  private static List<FinServ__FinancialAccount__c> updateDigitallyConnectedAccountFlag(
    String ocvId,
    List<String> financialAccountNumbers
  ) {
    List<FinServ__FinancialAccount__c> digitallyConnectedFinAccountList = FINANCIAL_ACCOUNT_REPOSITORY.getDigitallyConnectedFinAccounts(
      ocvId,
      financialAccountNumbers
    );
    ListUtil.setField(
      digitallyConnectedFinAccountList,
      FinServ__FinancialAccount__c.Is_Digitally_Active__c,
      false
    );
    return digitallyConnectedFinAccountList;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to display it on UI
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @return financial account to be displayed on UI
   */
  @TestVisible
  private static UnifiedFinancialAccountModel.AccountList getFinancialAccountInstance(
    UnifiedFinancialAccountModel.AccountList finAccount,
    FinServ__FinancialAccount__c finAccountFromDatabase
  ) {
    String productCodeKey = TextUtils.removeNonAlphanumericChar(
      finAccountFromDatabase?.Linked_Product_Code__c ??
        finAccount.product_details?.marketing_code ??
        finAccount.product_details.sub_product_code
    );
    if (String.isNotBlank(finAccount.ownership?.type)) {
      productCodeKey +=
        '_' + FABRIC_OWNERSHIP_UI.get(finAccount.ownership?.type);
    }

    FinancialAccountUIConfiguration__mdt finAccConfig = QueryFinancialAccountUIConfig.configByDeveloperName.get(
      productCodeKey
    );
    finAccount.Id = finAccountFromDatabase?.Id;
    finAccount.finserv_product_name = finAccountFromDatabase
      ?.FinServ__ProductName__c;
    finAccount.finserv_product_display_name = finAccountFromDatabase
      ?.Product_Name_Display__c ?? finAccount.product_details?.name;
    finAccount.finserv_opendate = finAccount.open_date == null
      ? null
      : Date.valueOf(finAccount.open_date.value);
    finAccount.finserv_closedate = finAccount.close_date == null
      ? null
      : Date.valueOf(finAccount.close_date.value);
    finAccount.finserv_status = FABRIC_STATUSES.get(finAccount.state);
    finAccount.finserv_ownership = finAccountFromDatabase == null
      ? FABRIC_OWNERSHIP.get(finAccount.ownership?.type)
      : finAccountFromDatabase.Ownership__c;

    finAccount.finserv_sortorder = finAccConfig?.Sort_Order__c ??
      DEFAULT_SORT_ORDER;
    finAccount.finserv_account_type = finAccConfig?.Account_Type__c ??
      'Non Savings';
    finAccount.finserv_showgoal = finAccConfig?.Show_Goals__c ?? false;
    finAccount.linkedProductCode = finAccountFromDatabase
      ?.Linked_Product_Code__c ?? finAccount.product_details?.marketing_code ??
      finAccount.product_details?.sub_product_code;

    return finAccount;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to be updated
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @return financial accounts with values to be updated in the database
   */
  @TestVisible
  private static FinServ__FinancialAccount__c getFinancialAccountInstanceToUpdate(
    UnifiedFinancialAccountModel.AccountList finAccount,
    FinServ__FinancialAccount__c finAccountFromDatabase
  ) {
    FinServ__FinancialAccount__c record = new FinServ__FinancialAccount__c();
    record.Id = finAccountFromDatabase.Id;
    record.Name = finAccount.account_name;
    record.Is_Digitally_Active__c = true;
    record.FinServ__Balance__c = finAccount.balances.balance.value;
    record.FinServ__CurrentPostedBalance__c = finAccount.balances.current_balance.value;
    record.FinServ__CloseDate__c = finAccount.close_date == null
      ? null
      : Date.valueOf(finAccount.close_date.value);
    record.FinServ__OpenDate__c = finAccount.open_date == null
      ? null
      : Date.valueOf(finAccount.open_date.value);
    return record;
  }

  /**
   * @description Filters and returns only Home Loan accounts based on the product code
   * @param financialAccountFabric List of all accounts to be filtered.
   * @return A list of Home Loan accounts.
   */
  @TestVisible
  private static List<UnifiedFinancialAccountModel.AccountList> filterOutNonHomeLoanAccounts(
    List<UnifiedFinancialAccountModel.AccountList> financialAccountFabric
  ) {
    List<UnifiedFinancialAccountModel.AccountList> homeLoanAccounts = new List<UnifiedFinancialAccountModel.AccountList>();

    for (
      UnifiedFinancialAccountModel.AccountList acc : financialAccountFabric
    ) {
      if (
        QueryFinancialAccountUIConfig.configByProductCode.get(
            acc.product_details?.marketing_code
          )
          ?.Account_Type__c == 'Loan'
      ) {
        homeLoanAccounts.add(acc);
      }
    }
    return homeLoanAccounts;
  }

  /**
   * @description This method is an orchestration layer for retrieving financial accounts from database and then group accounts , add metadata values and sort grouped records
   * Also, fetching the homeloan accounts from the Cache
   * @param ocvId The ocv id of the customer
   * @param ownerId The record id of the customer / primary owner of the financial accounts
   * @return Grouped Financial Accounts based on product code.
   */
  @AuraEnabled
  public static List<UnifiedFinancialAccountModel> getFinancialAccountDB(
    String ocvId,
    Id ownerId
  ) {
    try {
      List<UnifiedFinancialAccountModel.AccountList> financialAccountsFromDatabase = fetchAllFinancialAccountsDB(
        ownerId
      );

      if (financialAccountsFromDatabase.isEmpty()) {
        return new List<UnifiedFinancialAccountModel>();
      }

      List<UnifiedFinancialAccountModel> groupedAccounts = new List<UnifiedFinancialAccountModel>();
      for (
        UnifiedFinancialAccountModel model : FinancialAccountControllerAction.processFinancialAccounts(
          financialAccountsFromDatabase
        )
      ) {
        if (!model.isHomeLoan) {
          groupedAccounts.add(model);
        }
      }
      return groupedAccounts;
    } catch (Exception objException) {
      CommonUtil.logException(objException);
      throw new AuraHandledException(FAILED_TO_RETRIEVE);
    }
  }

  /**
   * @description This method fetch data of financial accounts from database and then group accounts , add metadata values and sort grouped records
   * @param ownerId The record id of the customer / primary owner of the financial accounts
   * @return Grouped Financial Accounts based on product code.
   */
  @TestVisible
  private static List<UnifiedFinancialAccountModel.AccountList> fetchAllFinancialAccountsDB(
    Id ownerId
  ) {
    List<FinServ__FinancialAccountRole__c> allRelatedAccountsRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllAccountNumberPerOwner(
      ownerId,
      QueryFinancialAccountUIConfig.configByProductCode.keySet()
    );

    Set<String> allRelatedAccountNumbers = ListUtil.getStrings(
      allRelatedAccountsRoles,
      FinServ__FinancialAccountRole__c.Account_Number__c
    );

    List<FinServ__FinancialAccount__c> financialAccount = FINANCIAL_ACCOUNT_REPOSITORY.getFinancialAccounts(
      new List<String>(allRelatedAccountNumbers)
    );

    return UnifiedFinancialAccountModelConverter.convertToUnifiedFinancialAccountModel(
      financialAccount
    );
  }

  /**
   * @description
   * This method is useful for fetching the account OCV Id based on the Account record Id
   * @param accountRecordId accountRecordId from lwc
   * @return Id ocvId
   */
  @AuraEnabled(cacheable=true)
  public static String fetchOCVIdFromAccount(Id accountRecordId) {
    List<Account> listOfAccounts = new AccountQueryHelper()
      .findAccountsByAccountId(accountRecordId);
    if (listOfAccounts.isEmpty()) {
      return null;
    }
    return listOfAccounts.get(0).OCV_ID__c;
  }
}
