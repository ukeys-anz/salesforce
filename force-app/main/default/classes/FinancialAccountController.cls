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
  public static final String MISSING_FIN_ACCOUNT = 'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator';
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
    'Multi-party' => 'Joint',
    'Single' => 'Single'
  };

  /**
   * @description This method is an orchestration layer for retrieving financial accounts, grouped accounts , add metadata values and sort grouped records
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return Grouped Financial Accounts based on product code.
   */
  @AuraEnabled
  public static Map<String, Object> getFinancialAccountFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    try {
      List<UnifiedFinancialAccountModel.AccountList> fabricAccountList = getFinancialAccountsFromFabric(
        ocvId,
        accountNumbers
      );

      if (fabricAccountList.isEmpty()) {
        return new Map<String, Object>();
      }

      List<UnifiedFinancialAccountModel.AccountList> homeloanaccounts = filterOutNonHomeLoanAccounts(
        fabricAccountList
      );

      DataPartitionUtil.storeH1AccountDetailsCache(ocvId, homeloanaccounts);

      List<Map<String, Object>> processedAccounts = FinancialAccountControllerAction.processFinancialAccounts(
        fabricAccountList
      );

      return new Map<String, Object>{ 'groupedAccounts' => processedAccounts };
    } catch (DmlException dmlExp) {
      throw CommonUtil.logAuraException(FAILED_FIN_ACCOUNT_UPDATE);
    } catch (Exception e) {
      CommonUtil.logException(e);
      throw new AuraHandledException(MISSING_FIN_ACCOUNT);
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
  private static List<UnifiedFinancialAccountModel.AccountList> getFinancialAccountsFromFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    UnifiedFinancialAccountModel result = coachapi.getAccounts(
      ocvId,
      accountNumbers
    );
    if (result.accounts == null) {
      return new List<UnifiedFinancialAccountModel.AccountList>();
    }

    Set<String> financialAccountNumbers = new Set<String>();
    for (
      UnifiedFinancialAccountModel.AccountList finAccount : result.accounts
    ) {
      financialAccountNumbers.add(finAccount.account_number);
    }

    List<FinServ__FinancialAccount__c> financialAccountList = FINANCIAL_ACCOUNT_REPOSITORY.getFinAccountList(
      new List<String>(financialAccountNumbers)
    );
    Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
      financialAccountList,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
    );

    List<FinancialAccountUIConfiguration__mdt> financialAccountConfigRecords = FINANCIAL_ACCOUNT_REPOSITORY.fetchFinancialAccountUIConfigInfo();
    Map<String, FinancialAccountUIConfiguration__mdt> financialAccountConfigMap = (Map<String, FinancialAccountUIConfiguration__mdt>) ListUtil.mapBy(
      financialAccountConfigRecords,
      FinancialAccountUIConfiguration__mdt.DeveloperName
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
        finAccountFromDatabase,
        financialAccountConfigMap
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

    DML.doUpdate(financialAccountsToUpdate, new DmlConfig().withoutSharing());

    return processedFinancialAccounts;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to display it on UI
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @param financialAccountConfigMap map of productcode-ownership as key and financial account ui configurations
   * @return financial account to be displayed on UI
   */
  @TestVisible
  private static UnifiedFinancialAccountModel.AccountList getFinancialAccountInstance(
    UnifiedFinancialAccountModel.AccountList finAccount,
    FinServ__FinancialAccount__c finAccountFromDatabase,
    Map<String, FinancialAccountUIConfiguration__mdt> financialAccountConfigMap
  ) {
    finAccount.Id = finAccountFromDatabase?.Id;
    finAccount.finserv_product_name = finAccountFromDatabase
      ?.FinServ__ProductName__c;
    finAccount.finserv_product_display_name = finAccountFromDatabase
      ?.Product_Name_Display__c;
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
    String key =
      finAccount.product_details.marketing_code +
      '_' +
      FABRIC_OWNERSHIP_UI.get(finAccount.finserv_ownership);
    finAccount.finserv_sortorder = financialAccountConfigMap.containsKey(key)
      ? financialAccountConfigMap.get(key).Sort_Order__c
      : DEFAULT_SORT_ORDER;
    finAccount.finserv_showgoal = financialAccountConfigMap.containsKey(key)
      ? financialAccountConfigMap.get(key)?.Show_Goals__c
      : true;
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
    List<FinancialAccountUIConfiguration__mdt> financialAccountConfigRecords = FINANCIAL_ACCOUNT_REPOSITORY.fetchFinancialAccountUIConfigInfo();
    Map<String, FinancialAccountUIConfiguration__mdt> mapOfProductCodeWithFinUIConfig = (Map<String, FinancialAccountUIConfiguration__mdt>) ListUtil.mapBy(
      financialAccountConfigRecords,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );
    List<UnifiedFinancialAccountModel.AccountList> homeLoanAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    for (
      UnifiedFinancialAccountModel.AccountList acc : financialAccountFabric
    ) {
      if (
        mapOfProductCodeWithFinUIConfig.get(acc.product_details?.marketing_code)
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
  public static Map<String, Object> getFinancialAccountDB(
    String ocvId,
    Id ownerId
  ) {
    List<UnifiedFinancialAccountModel.AccountList> combinedFinancialAccountList = new List<UnifiedFinancialAccountModel.AccountList>();
    try {
      List<UnifiedFinancialAccountModel.AccountList> homeLoanAccountDetailsCache = DataPartitionUtil.getH1AccountDetailsCache(
        ocvId
      );
      List<UnifiedFinancialAccountModel.AccountList> financialAccountsFromDatabase = fetchAllFinancialAccountsDB(
        ownerId
      );

      if (
        homeLoanAccountDetailsCache != null &&
        !homeLoanAccountDetailsCache.isEmpty()
      ) {
        combinedFinancialAccountList.addAll(homeLoanAccountDetailsCache);
      }
      if (
        financialAccountsFromDatabase != null &&
        !financialAccountsFromDatabase.isEmpty()
      ) {
        combinedFinancialAccountList.addAll(financialAccountsFromDatabase);
      }

      if (
        combinedFinancialAccountList == null ||
        combinedFinancialAccountList.isEmpty()
      ) {
        return new Map<String, Object>();
      }

      List<Map<String, Object>> processedAccounts = FinancialAccountControllerAction.processFinancialAccounts(
        combinedFinancialAccountList
      );

      return new Map<String, Object>{ 'groupedAccounts' => processedAccounts };
    } catch (Exception objException) {
      CommonUtil.logException(objException);
      throw new AuraHandledException(MISSING_FIN_ACCOUNT);
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
    List<FinancialAccountUIConfiguration__mdt> listOfFinAccConfig = FINANCIAL_ACCOUNT_REPOSITORY.fetchFinancialAccountUIConfigInfo();

    Set<String> marketingCodes = ListUtil.getStrings(
      listOfFinAccConfig,
      FinancialAccountUIConfiguration__mdt.Product_Code__c
    );

    List<FinServ__FinancialAccountRole__c> allRelatedAccountsRoles = FINANCIAL_ACCOUNT_REPOSITORY.getAllAccountNumberPerOwner(
      ownerId,
      marketingCodes
    );

    Set<String> allRelatedAccountNumbers = ListUtil.getStrings(
      allRelatedAccountsRoles,
      FinServ__FinancialAccountRole__c.Account_Number__c
    );

    List<FinServ__FinancialAccount__c> financialAccount = FINANCIAL_ACCOUNT_REPOSITORY.getFinacialAccounts(
      ownerId,
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
