/**
 *
 * @author Kopal Goswami
 * @since 2025
 * @description UnifiedFinancialAccountAction processes the fabric response.
 */
public with sharing class UnifiedFinancialAccountAction {
  private static final FinancialAccountRepository FINANCIAL_ACCOUNT_REPOSITORY = (FinancialAccountRepository) Lib_InstanceProvider.forType(
    FinancialAccountRepository.class
  );
  private static final DmlRepository DML = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final Map<String, String> FABRIC_STATUSES = new Map<String, String>{
    //Map of fabric statuses and user friendly names
    'ACCOUNT_STATE_UNSPECIFIED' => 'Unspecified', // there is no info about what status the account is in
    'ACCOUNT_STATE_OPEN' => 'Open', // the account is open
    'ACCOUNT_STATE_ACTIVE' => 'Active', // the account is active
    'ACCOUNT_STATE_SUSPENDED' => 'Suspended', // the account is suspended
    'ACCOUNT_STATE_DORMANT' => 'Dormant', // the account is dormant
    'ACCOUNT_STATE_CLOSED' => 'Closed' // the account is closed
  };

  //Map of fabric ownership and user friendly names
  private static final Map<String, String> FABRIC_OWNERSHIP = new Map<String, String>{
    'OWNERSHIP_TYPE_MULTIPARTY' => 'Multi-party', // its a joint account
    'OWNERSHIP_TYPE_SINGLEPARTY' => 'Single' // its an individual account
  };

  /**
   * @description This method assign values to variables of the fabric response based on salesforce data
   * Also, Updates financial accounts present in the database
   * @param financialAccounts Financial Accounts from Fabric
   * @return List of financial accounts with updated variable to be utilised in LWC
   */
  public static List<UnifiedFinancialAccountModel.AccountList> enrichWithSalesforceData(
    List<UnifiedFinancialAccountModel.AccountList> financialAccounts
  ) {
    if (financialAccounts == null || financialAccounts.isEmpty()) {
      return new List<UnifiedFinancialAccountModel.AccountList>();
    }

    List<UnifiedFinancialAccountModel.AccountList> processedFinancialAccounts = new List<UnifiedFinancialAccountModel.AccountList>();
    List<FinServ__FinancialAccount__c> financialAccountsToUpdate = new List<FinServ__FinancialAccount__c>();
    Set<String> financialAccountNumbers = new Set<String>();

    for (
      UnifiedFinancialAccountModel.AccountList finAccount : financialAccounts
    ) {
      financialAccountNumbers.add(finAccount.account_number);
    }

    List<FinServ__FinancialAccount__c> existingFinancialAccounts = FINANCIAL_ACCOUNT_REPOSITORY.getFinAccountList(
      new List<String>(financialAccountNumbers)
    );

    Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
      existingFinancialAccounts,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
    );

    for (
      UnifiedFinancialAccountModel.AccountList finAccount : financialAccounts
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

    DML.doUpdate(financialAccountsToUpdate, new DmlConfig().systemMode());

    return processedFinancialAccounts;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to display it on UI
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @return financial account to be displayed on UI
   */
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
   * @description This method fetch data of financial accounts from database and then group accounts , add metadata values and sort grouped records
   * @param ownerId The record id of the customer / primary owner of the financial accounts
   * @param recordTypeDeveloperNames the record type names for which financial accounts are retrieved from database
   * @return Grouped Financial Accounts based on product code.
   */
  public static List<UnifiedFinancialAccountModel.AccountList> getFinancialAccountDB(
    Id ownerId,
    List<String> recordTypeDeveloperNames
  ) {
    List<UnifiedFinancialAccountModel.AccountList> unifiedFinancialAccounts = new List<UnifiedFinancialAccountModel.AccountList>();

    try {
      //for joint account we cannot query only on Primary owner as it will return FA where primary owner is passed account id from UI.
      //Thus querying on Active FARs to determine what all account numbers this customer has then showing all of them on UI
      List<String> allRelatedAccountNumbers = FinancialAccountUtil.getAllAccountNumberFromFAR(
        ownerId
      );
      List<FinServ__FinancialAccount__c> financialAccount = FINANCIAL_ACCOUNT_REPOSITORY.getFinacialAccounts(
        ownerId,
        allRelatedAccountNumbers,
        recordTypeDeveloperNames
      );

      if (financialAccount != null && !financialAccount.isEmpty()) {
        unifiedFinancialAccounts = FinancialAccountWrapper.generateAccountJson(
          financialAccount
        );
      }
    } catch (Exception objException) {
      CommonUtil.logException(objException);
    }
    return unifiedFinancialAccounts;
  }
}
