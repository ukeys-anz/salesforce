/**
 *
 * @author Jasmine Nguyen
 * @since 02/2021
 * @description Common Financial Account Role Action methods
 */

public with sharing class FinancialAccountRoleCommonActions {
  private static final String SET_EXTERNAL_ID_ERROR = 'Failed to set external Id for Financial Account Role due to missing value in the following field(s): ';
  private static final Map<String, String> FIELD_ERROR_MESSAGE_MAP = new Map<String, String>{
    'accountExternalId' => 'External Id',
    'financialAccountKey' => 'Account Key',
    'startDate' => 'Primary Owner Start Date/Start Date'
  };
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
      // If the role is 'Primary Owner' use Primary_Owner_Start_Date__c on the financial account,
      // otherwise use FinServ__StartDate__c on the financial account role record
      Date startDate = rec.FinServ__Role__c == 'Primary Owner'
        ? financialAccountIdMap.get(rec.FinServ__FinancialAccount__c)
            .Primary_Owner_Start_Date__c
        : rec.FinServ__StartDate__c;
      String startDateString = getFormattedDate(startDate);

      // Check if any field is missing
      List<String> errors = checkMissingFields(
        accountExternalId,
        financialAccountKey,
        startDateString
      );

      if (errors.size() == 0) {
        rec.External_Id__c =
          accountExternalId +
          '_' +
          financialAccountKey +
          '_' +
          financialAccountRole +
          '_' +
          startDateString;
      } else {
        String errorMessage =
          SET_EXTERNAL_ID_ERROR +
          String.join(errors, '; ') +
          '.';
        Logger.error(errorMessage).setRecord(rec.Id);
        rec.addError(errorMessage);
      }
    }
    Logger.saveLog();
  }

  private static String getFormattedDate(Date dt) {
    if (dt != null) {
      Datetime output = Datetime.newInstanceGmt(
        dt,
        Time.newInstance(0, 0, 0, 0)
      );
      // now output is the same as it was in `bar`
      return output.formatGmt('ddMMyyyy');
    }
    return null;
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

  private static List<String> checkMissingFields(
    String accountExternalId,
    String financialAccountKey,
    String startDate
  ) {
    List<String> errors = new List<String>();
    if (String.isBlank(accountExternalId)) {
      errors.add(FIELD_ERROR_MESSAGE_MAP.get('accountExternalId'));
    }
    if (String.isBlank(financialAccountKey)) {
      errors.add(FIELD_ERROR_MESSAGE_MAP.get('financialAccountKey'));
    }
    if (String.isBlank(startDate)) {
      errors.add(FIELD_ERROR_MESSAGE_MAP.get('startDate'));
    }

    return errors;
  }

  /**
    @description extend the Exception class to allow errors to be thrown if one of the fields used to construct the external Id is blank
    */
  private class FinancialAccountRoleException extends Exception {
  }
}
