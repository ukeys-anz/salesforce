/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Common Financial Account Role Action methods
 */

public with sharing class FinancialAccountRoleCommonActions {
  private static final String SET_EXTERNAL_ID_ERROR = 'Failed to set external id for Financial Account Role due to missing data. Financial Account Id: ';
  /**
   * @description setExternalId is called to set the external Id field on the newly created financial account role record
   * @param records The Financial Account Role records passed from Trigger.new()
   */
  public static void setExternalId(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Map<Id, Account> accountIdMap = getRelatedAccounts(records);
    Map<Id, FinServ__FinancialAccount__c> financialAccountIdMap = getRelatedFinancialAccounts(
      records
    );

    for (FinServ__FinancialAccountRole__c rec : records) {
      String accountExternalId = accountIdMap.get(
          rec.FinServ__RelatedAccount__c
        )
        .External_Id__c;
      String financialAccountKey = financialAccountIdMap.get(
          rec.FinServ__FinancialAccount__c
        )
        .Account_Key__c;
      String financialAccountRole = rec.FinServ__Role__c.remove(' ');
      Date primaryOwnerStartDate = financialAccountIdMap.get(
          rec.FinServ__FinancialAccount__c
        )
        .Primary_Owner_Start_Date__c;
      if (
        // Check if any data used to construct the external id is null
        String.isNotBlank(accountExternalId) &&
        String.isNotBlank(financialAccountKey) &&
        String.isNotBlank(rec.FinServ__Role__c) &&
        primaryOwnerStartDate != null
      ) {
        // Prep the data before constructing the external Id string
        // Process the date string

        String startDate = getFormattedDate(primaryOwnerStartDate);

        // Construct the external Id for Financial Account Role
        List<String> strings = new List<String>{
          accountExternalId,
          financialAccountKey,
          financialAccountRole,
          startDate
        };

        // Set the external Id on the financial account role
        rec.External_Id__c = String.join(strings, '_');

        // Set the start date on the role as the start date from the financial account (which is populated by OCV)
        rec.FinServ__StartDate__c = primaryOwnerStartDate;
      } else {
        String errorMessage =
          SET_EXTERNAL_ID_ERROR + rec.FinServ__FinancialAccount__c;
        // Throw an error to prevent the financial role from being created
        throw new FinancialAccountRoleException(errorMessage);
      }
    }
  }

  private static String getFormattedDate(Date dt) {
    Datetime output = Datetime.newInstanceGmt(dt, Time.newInstance(0, 0, 0, 0));
    // now output is the same as it was in `bar`
    return output.formatGmt('ddMMyyyy');
  }

  private static Map<Id, Account> getRelatedAccounts(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (FinServ__FinancialAccountRole__c rec : records) {
      // Get a set of account ids
      accountIds.add(rec.FinServ__RelatedAccount__c);
    }
    // Construct a map of related accounts and their Ids
    Map<Id, Account> accountIdMap = new Map<Id, Account>(
      [SELECT Id, External_Id__c FROM Account WHERE Id IN :accountIds]
    );
    return accountIdMap;
  }

  private static Map<Id, FinServ__FinancialAccount__c> getRelatedFinancialAccounts(
    List<FinServ__FinancialAccountRole__c> records
  ) {
    Set<Id> financialAccountIds = new Set<Id>();
    for (FinServ__FinancialAccountRole__c rec : records) {
      // Get a set of financial account ids
      financialAccountIds.add(rec.FinServ__FinancialAccount__c);
    }
    // Construct a map of financial accounts and their Ids
    Map<Id, FinServ__FinancialAccount__c> financialAccountIdMap = new Map<Id, FinServ__FinancialAccount__c>(
      [
        SELECT Id, Primary_Owner_Start_Date__c, Account_Key__c
        FROM FinServ__FinancialAccount__c
        WHERE Id IN :financialAccountIds
      ]
    );
    return financialAccountIdMap;
  }

  /**
    @description extend the Exception class to allow errors to be thrown if one of the fields used to construct the external Id is blank
    */
  private class FinancialAccountRoleException extends Exception {
  }
}
