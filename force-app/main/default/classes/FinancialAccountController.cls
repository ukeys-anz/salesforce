/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialAccountController retrieves account details for the financialAccount LWC and the FinancialGoals LWC
 */
public with sharing class FinancialAccountController {
  //Map of fabric statuses and user friendly names to map them to
  private static final Map<String, String> FABRIC_STATUSES = new Map<String, String>{
    'ACCOUNT_STATUS_UNSPECIFIED' => 'Unspecified', // there is no info about what status the account is in
    'ACCOUNT_STATUS_OPEN' => 'Open', // the account is open
    'ACCOUNT_STATUS_ACTIVE' => 'Active', // the account is active
    'ACCOUNT_STATUS_SUSPENDED' => 'Suspended', // the account is suspended
    'ACCOUNT_STATUS_DORMANT' => 'Dormant', // the account is dormant
    'ACCOUNT_STATUS_CLOSED' => 'Closed' // the account is closed
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
      Map<String, Id> finAccNumberToIdMap = getFinAccNumberToIdMap(
        financialAccountNumbers
      );

      for (FinancialAccountModel.AccountList finAccount : result.account_list) {
        //Format opened date from string to date
        Date openedDate = finAccount.opened_at == null
          ? null
          : Date.valueOf(finAccount.opened_at);

        financialAccounts.add(
          new FinServ__FinancialAccount__c(
            Id = finAccNumberToIdMap.get(finAccount.account_number),
            Name = finAccount.name,
            FinServ__FinancialAccountNumber__c = finAccount.account_number,
            FinServ__Balance__c = finAccount.balance.value,
            FinServ__CurrentPostedBalance__c = finAccount.current_balance.value,
            BSB__c = finAccount.bsb,
            FinServ__OpenDate__c = openedDate,
            FinServ__Status__c = FABRIC_STATUSES.get(finAccount.status),
            RecordType = getAccountRecordType(finAccount.marketing_product.code)
          )
        );

        if (finAccNumberToIdMap.keySet().contains(finAccount.account_number)) {
          financialAccountsUpdate.add(
            new FinServ__FinancialAccount__c(
              Id = finAccNumberToIdMap.get(finAccount.account_number),
              Name = finAccount.name,
              FinServ__Balance__c = finAccount.balance.value,
              FinServ__CurrentPostedBalance__c = finAccount.current_balance.value,
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
      Logger.error(e.getMessage(), e);
      Logger.saveLog();

      throw new AuraHandledException(
        'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator'
      );
    }
  }

  /**
   * @description builds a map of finaccnumber to sf id
   * fabric only knows the finaccnumber, so we need to fetch the id to do an update
   *
   * @param financialAccountNumbers the financial account identifiers
   * @return Map<String, Id> map of the fin acc number to the salesforce id
   */
  private static Map<String, Id> getFinAccNumberToIdMap(
    Set<String> financialAccountNumbers
  ) {
    Map<String, Id> finAccNumberToIdMap = new Map<String, Id>();
    for (FinServ__FinancialAccount__c fa : [
      SELECT Id, FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :financialAccountNumbers
    ]) {
      finAccNumberToIdMap.put(fa.FinServ__FinancialAccountNumber__c, fa.Id);
    }
    return finAccNumberToIdMap;
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
    List<FinServ__FinancialAccount__c> financialAccount;
    if (
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable() &&
      String.isNotBlank(ownerId) &&
      !recordTypeDeveloperNames.isEmpty()
    ) {
      financialAccount = [
        SELECT
          Id,
          Name,
          FinServ__Balance__c,
          FinServ__Status__c,
          FinServ__FinancialAccountNumber__c,
          RecordType.DeveloperName,
          LastModifiedDate
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND RecordType.DeveloperName IN :recordTypeDeveloperNames
        ORDER BY FinServ__OpenDate__c DESC, FinServ__Status__c ASC
      ];
    }
    if (financialAccount.isEmpty()) {
      return null;
    }

    return financialAccount;
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
      when 'SAVING01' {
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
