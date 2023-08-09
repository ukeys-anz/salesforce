/**
 *
 * @author Vidhya Raghavan
 * @since 2022
 * @description HomeLoanController retrieves account details for the PersonAccount and H1 account details LWC
 */

public with sharing class HomeLoanController {
  /**
   * @description The Person Account Home Loan component uses this to fetch the records to display.
   * This makes the callout to mule to fetch home loan data
   * @param ocvId Ocv id
   * @return
   */
  @AuraEnabled
  public static HomeLoanModel getHomeLoanAccount(String ocvId) {
    HomeLoanAPIRepository hloanapi = new HomeLoanAPIRepository();
    HomeLoanModel result = hloanapi.getHomeLoanAccounts(ocvId);
    return result;
  }

  /**
   * @description return the id of the home loan financial account
   * @param customerId customer id
   * @return  `Id` home loan account id
   */
  @AuraEnabled
  public static Id getHomeLoanFinancialAccountId(Id customerId) {
    Id homeLoanRTId = Schema.SObjectType.FinServ__FinancialAccount__c.getRecordTypeInfosByDeveloperName()
      .get('BankingAccount')
      .getRecordTypeId();
    if (
      FinServ__FinancialAccount__c.sObjectType.getDescribe().isQueryable() ==
      false
    ) {
      throw new AuraHandledException(
        'No permissions to view home loan account.'
      );
    }
    FinServ__FinancialAccount__c homeLoanFinancialAccount = [
      SELECT Id
      FROM FinServ__FinancialAccount__c
      WHERE
        FinServ__PrimaryOwner__c = :customerId
        AND RecordTypeId = :homeLoanRTId
        AND Marketing_Code__c IN :GetHelpConstants.HOME_LOAN_MARKETING_CODES
      LIMIT 1
    ];
    return homeLoanFinancialAccount.Id;
  }
}
