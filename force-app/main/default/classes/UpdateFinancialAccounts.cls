/**
 * @author Peter Charalambous
 * @since 2020
 * @description UpdateFinancialAccounts takes the accounts data returned from API
 * and updates our SF records with the latest data
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public without sharing class UpdateFinancialAccounts {
  /**
   * @description The AccountsAndGoalsRefresh component uses this to update the
   * accounts records based on the data returned from the API.
   *
   * @param ownerId the id of the owner of the financial account
   * @param accountNumbers the account numbers from the API
   * @param financialAccounts the account data from the API
   * @return List<FinServ__FinancialAccount__c>
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccount__c> updateAccounts(
    Id ownerId,
    String[] accountNumbers,
    List<FinServ__FinancialAccount__c> financialAccounts
  ) {
    List<Database.UpsertResult> results = Database.upsert(
      financialAccounts,
      FinServ__FinancialAccount__c.FinServ__FinancialAccountNumber__c,
      false
    );

    //log errors to application log
    lib_systemLog log = new lib_systemLog(
      'UpdateFinancialAccounts',
      'updateAccounts'
    );
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
  }
}
