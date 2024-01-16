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
   * @param accountNumbers param to filter by account numbers
   * @param recordId only provided for financial account, person account will pass empty string
   * @return
   */
  @AuraEnabled
  public static HomeLoanModel getHomeLoanAccount(
    String ocvId,
    List<String> accountNumbers,
    String recordId
  ) {
    HomeLoanAPIRepository hloanapi = new HomeLoanAPIRepository();
    HomeLoanModel result = hloanapi.getHomeLoanAccounts(ocvId, accountNumbers);

    //Not using permission utils as we dont want to error out if not queryable
    //and only need to query if on financial account record page
    if (
      String.isNotBlank(recordId) &&
      (Feature__c.sObjectType.getDescribe().isQueryable() &&
      FA_Feature_Relationship__c.SObjectType.getDescribe().isQueryable())
    ) {
      //Fetch the linked offset feature
      FA_Feature_Relationship__c featureId = [
        SELECT Feature__c
        FROM FA_Feature_Relationship__c
        WHERE
          Financial_Account__c = :recordId
          AND Relationship_Status__c = 'Active'
      ];

      //Retrieve the linked offset account
      FA_Feature_Relationship__c fafRelationship = [
        SELECT
          Id,
          Financial_Account__c,
          Financial_Account__r.FinServ__FinancialAccountNumber__c
        FROM FA_Feature_Relationship__c
        WHERE
          Feature__c = :featureId.Feature__c
          AND Financial_Account_Product__c = 'ANZ Plus'
          AND Relationship_Status__c = 'Active'
      ];

      //Populate the offset details for the account
      for (HomeLoanModel.HomeLoanAccount acc : result.accounts) {
        HomeLoanModel.OffsetDetails offsetDetails = new HomeLoanModel.OffsetDetails();
        offsetDetails.accountNumber = fafRelationship.Financial_Account__r.FinServ__FinancialAccountNumber__c;
        offsetDetails.recordId = fafRelationship.Financial_Account__c;
        acc.loan_details.offsetAccount = offsetDetails;
      }
    }
    return result;
  }

  /**
   * @description return list of linked home loan financial accounts
   * @param customerId customer id
   * @return  `List<FinServ__FinancialAccountRole__c>` list of linked financial accounts
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccountRole__c> getHomeLoanFinancialAccountId(
    Id customerId
  ) {
    PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');

    List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
      SELECT
        Id,
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :customerId
        AND FinServ__FinancialAccount__r.RecordTypeId = :GetHelpConstants.BANK_ACCOUNT_RT_ID
        AND FinServ__FinancialAccount__r.Marketing_Code__c IN :GetHelpConstants.HOME_LOAN_MARKETING_CODES
        AND FinServ__Active__c = TRUE
    ];
    return financialAccountRoles;
  }

  /**
   * @description return the id(s) of the financial account owners
   * @param financialAccountId financial account record id
   * @return  `Id` home loan account id
   */
  @AuraEnabled
  public static List<FinServ__FinancialAccountRole__c> getAccountOwnerIds(
    Id financialAccountId
  ) {
    //Check if can query account
    PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');

    List<FinServ__FinancialAccountRole__c> financialAccountRoles = [
      SELECT Id, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__c = :financialAccountId
        AND FinServ__Active__c = TRUE
    ];

    return financialAccountRoles;
  }
}
