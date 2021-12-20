/**
 *
 * @author Peter Charalambous
 * @since 2020
 * @description FinancialAccountController retrieves account details for the EverydayAccount LWC and the FinancialGoals LWC
 */
public with sharing class FinancialAccountController {
  /**
   * @description The Financial Account component uses this to fetch the records to display.
   * This makes the callout to fabric to fetch data
   *
   * @param ocvId the ocv id of the customer
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFinancialAccountFabric(
    String ocvId
  ) {
    List<FinServ__FinancialAccount__c> financialAccounts = new List<FinServ__FinancialAccount__c>();
    lib_systemLog log = new lib_systemLog(
      FinancialAccountController.class.getName(),
      'getFinancialAccount'
    );
    try {
      CoachBankingAPIRepository coachapi = new CoachBankingAPIRepository();
      FinancialAccountModel result = coachapi.getAccounts(ocvId);

      for (FinancialAccountModel.AccountList finAccount : result.account_list) {
        financialAccounts.add(
          new FinServ__FinancialAccount__c(
            Name = finAccount.name,
            FinServ__FinancialAccountNumber__c = finAccount.account_number,
            FinServ__Balance__c = finAccount.balance.value,
            FinServ__CurrentPostedBalance__c = finAccount.current_balance.value,
            BSB__c = finAccount.bsb,
            FinServ__OpenDate__c = (Date) finAccount.opened_at,
            FinServ__FinancialAccountType__c = finAccount.marketing_product.code ==
              'TRANSACT01'
              ? 'Checking'
              : 'Savings'
          )
        );
      }
      List<Database.UpsertResult> results = Database.upsert(
        financialAccounts,
        FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c,
        false
      );

      //log errors to application log
      Boolean hasError = log.addDatabaseUpsertResult(
        'FinServ__FinancialAccount__c',
        results,
        financialAccounts
      );
      log.insertLogAsync();

      if (hasError) {
        throw new AuraHandledException(
          'Failed to update accounts. Please refresh and try again. If issue persists please contact your System Administrator'
        );
      }

      return financialAccounts;
    } catch (Exception e) {
      log.addMessage(
        e.getTypeName(),
        e.getMessage(),
        Lib_SystemLog.Severity.ERROR
      );
      log.insertLogAsync();

      throw new AuraHandledException(
        'Failed to retrieve latest account information. Please refresh and try again. If issue persists please contact your System Administrator'
      );
    }
  }

  /**
   * @description The Financial Account component uses this as a fallback to fetch the records to display.
   * If the getFinancialAccountFabric fails, the LWC will use this as a fallback to fetch the existing
   * records in Salesforce and return them
   *
   * @param ownerId the id of the owner of the financial account
   * @param type the account type to retrieve
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> getFinancialAccountDB(
    Id ownerId,
    List<String> type
  ) {
    List<FinServ__FinancialAccount__c> financialAccount;
    if (
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable() &&
      String.isNotBlank(ownerId) &&
      !type.isEmpty()
    ) {
      financialAccount = [
        SELECT
          Id,
          Name,
          FinServ__Balance__c,
          FinServ__Status__c,
          FinServ__FinancialAccountNumber__c,
          LastModifiedDate,
          FinServ__FinancialAccountType__c
        FROM FinServ__FinancialAccount__c
        WHERE
          FinServ__PrimaryOwner__c = :ownerId
          AND FinServ__FinancialAccountType__c IN :type
        ORDER BY FinServ__OpenDate__c DESC, FinServ__Status__c ASC
      ];
    }
    if (financialAccount.isEmpty()) {
      return null;
    }

    return financialAccount;
  }
}
