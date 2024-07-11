/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialAccountController retrieves account details for the financialAccount LWC and the FinancialGoals LWC
 */
public with sharing class FinancialAccountController {
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
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    List<FinServ__FinancialAccount__c> financialAccountsUpdate = new List<FinServ__FinancialAccount__c>();
    try {
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      FinancialAccountModel result = coachapi.getAccounts(
        ocvId,
        accountNumbers
      );

      //Check if we have any accounts returned
      if (result.account_list == null) {
        return financialAccounts;
      }

      Set<String> financialAccountNumbers = new Set<String>();
      for (FinancialAccountModel.AccountList finAccount : result.account_list) {
        financialAccountNumbers.add(finAccount.account_number);
      }

      //Added this to create Financial Account and FInancial Account Number Map to be used for fetching Id,OCVID and Ownership- by Shivam
      Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = getFinAccNumberToFinancialAccountMap(
        financialAccountNumbers
      );

      for (FinancialAccountModel.AccountList finAccount : result.account_list) {
        //Format opened date from string to date
        Date openedDate = finAccount.opened_at == null
          ? null
          : Date.valueOf(finAccount.opened_at);

        //Format closed date from string to date
        Date closedDate = finAccount.closed_at == null
          ? null
          : Date.valueOf(finAccount.closed_at);

        //Added ownership field in order to show on UI if financial account not found in database
        String ownership;
        if (finAccount.ownership != null) {
          ownership = FABRIC_OWNERSHIP.get(finAccount.ownership.type);
        }

        //Fetch Financial Account from Database
        FinServ__FinancialAccount__c finAccountFromDatabase = finAccNumberToFinancialAccountMap.get(
          finAccount.account_number
        );

        financialAccounts.add(
          new FinServ__FinancialAccount__c(
            Id = finAccountFromDatabase == null
              ? null
              : finAccountFromDatabase.Id,
            Name = finAccount.name,
            FinServ__FinancialAccountNumber__c = finAccount.account_number,
            FinServ__Balance__c = finAccount.balance.value,
            FinServ__CurrentPostedBalance__c = finAccount.current_balance.value,
            BSB__c = finAccount.bsb,
            FinServ__OpenDate__c = openedDate,
            FinServ__CloseDate__c = closedDate,
            FinServ__Status__c = FABRIC_STATUSES.get(finAccount.status),
            Marketing_Code__c = finAccount.marketing_product.code,
            RecordType = getAccountRecordType(
              finAccount.marketing_product.code
            ),
            FinServ__Ownership__c = finAccountFromDatabase == null
              ? ownership
              : finAccountFromDatabase.Ownership__c
          )
        );

        if (
          finAccNumberToFinancialAccountMap.containsKey(
            finAccount.account_number
          )
        ) {
          financialAccountsUpdate.add(
            new FinServ__FinancialAccount__c(
              Id = finAccNumberToFinancialAccountMap.get(
                  finAccount.account_number
                )
                .Id,
              Name = finAccount.name,
              FinServ__Balance__c = finAccount.balance.value,
              FinServ__CurrentPostedBalance__c = finAccount.current_balance.value,
              FinServ__CloseDate__c = closedDate,
              FinServ__OpenDate__c = openedDate
            )
          );
        }
      }

      SystemModeActions actions = new SystemModeActions(
        'FinancialAccountController',
        'getFinancialAccountFabric'
      );
      Boolean hasError = actions.updateRecords(
        financialAccountsUpdate,
        'FinServ__FinancialAccount__c'
      );

      if (hasError) {
        throw new AuraHandledException(
          'Failed to update accounts. Please refresh and try again. If issue persists please contact your System Administrator'
        );
      }

      return financialAccounts;
    } catch (Exception e) {
      if (e.getTypeName() != 'PermissionException') {
        Logger.error(e.getMessage(), e);
        Logger.saveLog();
      }
      throw new AuraHandledException(
        'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator'
      );
    }
  }

  /**
   * @description builds a map of finaccnumber to FinServ__FinancialAccount__c
   * @param financialAccountNumbers the financial account identifiers
   * @return Map<String, FinServ__FinancialAccount__c> map of the fin acc number to the FinServ__FinancialAccount__c
   */
  private static Map<String, FinServ__FinancialAccount__c> getFinAccNumberToFinancialAccountMap(
    Set<String> financialAccountNumbers
  ) {
    Map<String, FinServ__FinancialAccount__c> finAccNumberToFinancialAccountMap = new Map<String, FinServ__FinancialAccount__c>();
    for (FinServ__FinancialAccount__c finAccount : [
      SELECT Id, FinServ__FinancialAccountNumber__c, Ownership__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :financialAccountNumbers
    ]) {
      finAccNumberToFinancialAccountMap.put(
        finAccount.FinServ__FinancialAccountNumber__c,
        finAccount
      );
    }
    return finAccNumberToFinancialAccountMap;
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
        financialAccount = [
          SELECT
            Id,
            Name,
            FinServ__Balance__c,
            FinServ__CurrentPostedBalance__c,
            FinServ__CloseDate__c,
            FinServ__FinancialAccountNumber__c,
            FinServ__Status__c,
            FinServ__OpenDate__c,
            Marketing_Code__c,
            RecordType.DeveloperName,
            LastModifiedDate,
            Ownership__c,
            OCV_ID__c
          FROM FinServ__FinancialAccount__c
          WHERE
            (FinServ__PrimaryOwner__c = :ownerId
            OR FinServ__FinancialAccountNumber__c IN :allRelatedAccountNumbers)
            AND RecordType.DeveloperName IN :recordTypeDeveloperNames
            AND FinServ__Status__c != 'Closed'
          ORDER BY FinServ__Status__c DESC, FinServ__OpenDate__c DESC
        ];
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
