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

  //Map of fabric statuses and user friendly names to map them to
  private static final Map<String, String> FABRIC_STATUSES = new Map<String, String>{
    //State Mapping for v1
    'ACCOUNT_STATE_UNSPECIFIED' => 'Unspecified', // there is no info about what status the account is in
    'ACCOUNT_STATE_OPEN' => 'Open', // the account is open
    'ACCOUNT_STATE_ACTIVE' => 'Active', // the account is active
    'ACCOUNT_STATE_SUSPENDED' => 'Suspended', // the account is suspended
    'ACCOUNT_STATE_DORMANT' => 'Dormant', // the account is dormant
    'ACCOUNT_STATE_CLOSED' => 'Closed' // the account is closed
  };

  //Map of fabric ownership and user friendly names to map them to
  private static final Map<String, String> FABRIC_OWNERSHIP = new Map<String, String>{
    'OWNERSHIP_TYPE_MULTIPARTY' => 'Multi-party', // its a joint account
    'OWNERSHIP_TYPE_SINGLEPARTY' => 'Single' // its an individual account
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

      if (fabricAccountList == null || fabricAccountList.isEmpty()) {
        return new Map<String, Object>();
      }

      DataPartitionUtil.storeH1AccountDetailsCache(
        ocvId,
        filterOutNonHomeLoanAccounts(fabricAccountList)
      );
      Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = FinancialAccountControllerAction.groupByProductCode(
        fabricAccountList
      );
      return FinancialAccountControllerAction.processFinAccountUIConfiAndBuildResponse(
        groupedAccounts
      );
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
    List<UnifiedFinancialAccountModel.AccountList> processedFinancialAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    List<FinServ__FinancialAccount__c> financialAccountsToUpdate = new List<FinServ__FinancialAccount__c>();
    Set<String> financialAccountNumbers = new Set<String>();

    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    UnifiedFinancialAccountModel result = coachapi.getAccounts(
      ocvId,
      accountNumbers
    );
    if (result.accounts == null) {
      return new List<UnifiedFinancialAccountModel.AccountList>();
    }

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

    DML.doUpdate(financialAccountsToUpdate, new DmlConfig().withoutSharing());

    return processedFinancialAccounts;
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
    finAccount.Id = finAccountFromDatabase?.Id;
    finAccount.finserv_product_name = finAccountFromDatabase != null
      ? (finAccountFromDatabase.FinServ__ProductName__c != null
          ? finAccountFromDatabase.FinServ__ProductName__c
          : null)
      : null;
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
    Map<String, FinancialAccountUIConfiguration__mdt> mapOfProductCodeWithFinUIConfig = FINANCIAL_ACCOUNT_REPOSITORY.mapProductCodeToFinAccounDetails();
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

      Map<String, List<UnifiedFinancialAccountModel.AccountList>> groupedAccounts = FinancialAccountControllerAction.groupByProductCode(
        combinedFinancialAccountList
      );
      return FinancialAccountControllerAction.processFinAccountUIConfiAndBuildResponse(
        groupedAccounts
      );
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
    //for joint account we cannot query only on Primary owner as it will return FA where primary owner is passed account id from UI.
    //Thus querying on Active FARs to determine what all account numbers this customer has then showing all of them on UI
    List<String> allRelatedAccountNumbers = FINANCIAL_ACCOUNT_REPOSITORY.getAllAccountNumberFromFAR(
      ownerId
    );

    List<FinServ__FinancialAccount__c> financialAccount = FINANCIAL_ACCOUNT_REPOSITORY.getFinacialAccounts(
      ownerId,
      allRelatedAccountNumbers
    );

    if (financialAccount == null || financialAccount.isEmpty()) {
      return new List<UnifiedFinancialAccountModel.AccountList>();
    }

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