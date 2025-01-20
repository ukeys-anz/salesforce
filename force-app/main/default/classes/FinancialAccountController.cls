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

  //Map of fabric statuses and user friendly names to map them to
  private static final Map<String, String> FABRIC_STATUSES = new Map<String, String>{
    //Status Mapping of v1beta1
    'ACCOUNT_STATUS_UNSPECIFIED' => 'Unspecified', // there is no info about what status the account is in
    'ACCOUNT_STATUS_OPEN' => 'Open', // the account is open
    'ACCOUNT_STATUS_ACTIVE' => 'Active', // the account is active
    'ACCOUNT_STATUS_SUSPENDED' => 'Suspended', // the account is suspended
    'ACCOUNT_STATUS_DORMANT' => 'Dormant', // the account is dormant
    'ACCOUNT_STATUS_CLOSED' => 'Closed', // the account is closed
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
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFinancialAccountFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    try {
      return getFinancialAccountsFromFabric(ocvId, accountNumbers);
    } catch (DmlException dmlExp) {
      throw new AuraHandledException(
        'Failed to update accounts. Please refresh and try again. If issue persists please contact your System Administrator'
      );
    } catch (Exception e) {
      throw new AuraHandledException(
        'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator'
      );
    }
  }

  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   *
   * @param ocvId the ocv id of the customer
   * @param accountNumbers contains account numbers to provide as parameters for account filtering
   * @return List<FinServ__FinancialAccount__c>
   */
  private static List<FinServ__FinancialAccount__c> getFinancialAccountsFromFabric(
    String ocvId,
    List<String> accountNumbers
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    List<FinServ__FinancialAccount__c> financialAccountsUpdate = new List<FinServ__FinancialAccount__c>();
    Set<String> financialAccountNumbers = new Set<String>();
    CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
    FinancialAccountModel result = coachapi.getAccounts(ocvId, accountNumbers);

    if (result.account_list == null) {
      return financialAccounts;
    }

    for (FinancialAccountModel.AccountList finAccount : result.account_list) {
      financialAccountNumbers.add(finAccount.account_number);
    }
    List<FinServ__FinancialAccount__c> financialAccountList = FINANCIAL_ACCOUNT_REPOSITORY.getFinAccountList(
      new List<String>(financialAccountNumbers)
    );

    Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = (Map<String, FinServ__FinancialAccount__c>) ListUtil.mapBy(
      financialAccountList,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c
    );

    for (FinancialAccountModel.AccountList finAccount : result.account_list) {
      FinServ__FinancialAccount__c finAccountFromDatabase = finAccNumberToFinancialAccountMap.get(
        finAccount.account_number
      );
      FinServ__FinancialAccount__c finAccountRecord = getFinancialAccountInstance(
        finAccount,
        finAccountFromDatabase
      );
      financialAccounts.add(finAccountRecord);

      if (finAccountFromDatabase != null) {
        FinServ__FinancialAccount__c finAccountRecordToUpdate = getFinancialAccountInstanceToUpdate(
          finAccount,
          finAccountFromDatabase
        );
        financialAccountsUpdate.add(finAccountRecordToUpdate);
      }
    }

    DML.doUpdate(financialAccountsUpdate, new DmlConfig().systemMode());

    return financialAccounts;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to display it on UI
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @return FinServ__FinancialAccount__c
   */
  private static FinServ__FinancialAccount__c getFinancialAccountInstance(
    FinancialAccountModel.AccountList finAccount,
    FinServ__FinancialAccount__c finAccountFromDatabase
  ) {
    FinServ__FinancialAccount__c finAccountRecord = new FinServ__FinancialAccount__c();
    finAccountRecord.Id = finAccountFromDatabase?.Id;
    finAccountRecord.Name = finAccount.name;
    finAccountRecord.FinServ__FinancialAccountNumber__c = finAccount.account_number;
    finAccountRecord.FinServ__Balance__c = finAccount.balance.value;
    finAccountRecord.FinServ__CurrentPostedBalance__c = finAccount.current_balance.value;
    finAccountRecord.BSB__c = finAccount.bsb;
    finAccountRecord.FinServ__OpenDate__c = finAccount.opened_at == null
      ? null
      : Date.valueOf(finAccount.opened_at);
    finAccountRecord.FinServ__CloseDate__c = finAccount.closed_at == null
      ? null
      : Date.valueOf(finAccount.closed_at);
    finAccountRecord.FinServ__Status__c = FABRIC_STATUSES.get(
      finAccount.status
    );
    finAccountRecord.Marketing_Code__c = finAccount.marketing_product.code;
    finAccountRecord.RecordType = getAccountRecordType(
      finAccount.marketing_product.code
    );
    finAccountRecord.FinServ__Ownership__c = finAccountFromDatabase == null
      ? FABRIC_OWNERSHIP.get(finAccount.ownership?.type)
      : finAccountFromDatabase.Ownership__c;
    finAccountRecord.FinServ__ProductName__c = finAccountFromDatabase.FinServ__ProductName__c;
    return finAccountRecord;
  }

  /**
   * @description
   * Creates a instance of Financial Account Record to be updated
   * @param finAccount Financial Account from Fabric
   * @param finAccountFromDatabase Financial Account from Salesforce Database
   * @return FinServ__FinancialAccount__c
   */
  private static FinServ__FinancialAccount__c getFinancialAccountInstanceToUpdate(
    FinancialAccountModel.AccountList finAccount,
    FinServ__FinancialAccount__c finAccountFromDatabase
  ) {
    FinServ__FinancialAccount__c record = new FinServ__FinancialAccount__c();
    record.Id = finAccountFromDatabase.Id;
    record.Name = finAccount.name;
    record.FinServ__Balance__c = finAccount.balance.value;
    record.FinServ__CurrentPostedBalance__c = finAccount.current_balance.value;
    record.FinServ__CloseDate__c = finAccount.closed_at == null
      ? null
      : Date.valueOf(finAccount.closed_at);
    record.FinServ__OpenDate__c = finAccount.opened_at == null
      ? null
      : Date.valueOf(finAccount.opened_at);
    return record;
  }

  /**
   * @description The Financial Account component uses this as a fallback to fetch the records to display.
   * If the getFinancialAccountFabric fails, the LWC will use this as a fallback to fetch the existing
   * records in Salesforce and return them
   *
   * @param ownerId the id of the owner of the financial account
   * @param recordTypeDeveloperNames the account type to retrieve
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFinancialAccountDB(
    Id ownerId,
    List<String> recordTypeDeveloperNames
  ) {
    List<FinServ__FinancialAccount__c> financialAccount = new List<FinServ__FinancialAccount__c>();
    try {
      PermissionUtils.canQuery('FinServ__FinancialAccount__c');
      PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');
      if (String.isNotBlank(ownerId) && !recordTypeDeveloperNames.isEmpty()) {
        //for joint account we cannot query only on Primary owner as it will return FA where primary owner is passed account id from UI.
        //Thus querying on Active FARs to determine what all account numbers this customer has then showing all of them on UI
        List<String> allRelatedAccountNumbers = FinancialAccountUtil.getAllAccountNumberFromFAR(
          ownerId
        );
        financialAccount = FINANCIAL_ACCOUNT_REPOSITORY.getFinacialAccounts(
          ownerId,
          allRelatedAccountNumbers,
          recordTypeDeveloperNames
        );
      }
    } catch (Exception objException) {
      Logger.error(objException.getMessage(), objException);
      Logger.saveLog();
    }
    return financialAccount;
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

  /**
   * @description The Financial Account component uses this method to differentiate between the type of account.
   * This method takes in marketing code as input and returns the label of the corresponding record type
   * The reason this method is required, is to avoid having to query database when fabric response is received,
   * else a query to pull FinServ__RecordTypeName__c would be required
   * @param code the marketing code input
   * @return Account record type
   */
  public static RecordType getAccountRecordType(String code) {
    switch on code {
      when 'TRANSACT01' {
        return new RecordType(
          DeveloperName = GetHelpConstants.CHECKING_ACCOUNT_RT_APINAME
        );
      }
      when 'SAVING01', 'SAVING02' {
        return new RecordType(
          DeveloperName = GetHelpConstants.SAVINGS_ACCOUNT_RT_APINAME
        );
      }
      when else {
        return new RecordType(
          DeveloperName = GetHelpConstants.BANK_ACCOUNT_RT_APINAME
        );
      }
    }
  }
}
