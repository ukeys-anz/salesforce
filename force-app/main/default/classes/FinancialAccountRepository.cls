/**
 * @author Shivam Swaraj
 * @since Mon July 24 2024
 * @description Provides SOQL and DML helpers for HomeLoanController, FinancialAccountController
 */
public with sharing class FinancialAccountRepository {
  //Financial Account Role Types To Include for showing owner names on financial account record page
  private static final Set<String> FINSERV_ROLE_TYPES = new Set<String>{
    'Additional Owner',
    'Primary Owner'
  };
  /**
   * @description return the id(s) of the financial account owners
   * @param financialAccountId financial account record id
   * @return list of FAR which are Primary or Additional role type
   */
  public List<FinServ__FinancialAccountRole__c> getAccountOwnerDetails(
    Id financialAccountId
  ) {
    //Check if can query financial account role
    PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');

    return [
      SELECT Id, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__c = :financialAccountId
        AND FinServ__Active__c = TRUE
        AND FinServ__Role__c IN :FINSERV_ROLE_TYPES
    ];
  }

  /**
   * @description fetch financial accounts based on the ocvid
   * @param ocvId String containing the ocvId of the customer
   * @return List<FinServ__FinancialAccount__c> List of FinancialAccounts based on ocvid
   */
  public List<FinServ__FinancialAccount__c> fetchFinancialAccountsByStatus(
    String ocvId
  ) {
    if (
      SObjectType.FinServ__FinancialAccount__c.isQueryable() == false &&
      String.isBlank(ocvId)
    ) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        FinServ__FinancialAccountNumber__c,
        Ownership__c,
        FinServ__Status__c
      FROM FinServ__FinancialAccount__c
      WHERE
        Id IN (
          SELECT FinServ__FinancialAccount__c
          FROM FinServ__FinancialAccountRole__c
          WHERE
            FinServ__RelatedAccount__r.OCV_ID__c = :ocvId
            AND FinServ__Active__c = TRUE
        )
    ];
  }

  /**
   * @param finAccountNumbers the List of offset account numbers
   * @return `List<FinServ__FinancialAccount__c>` List of financial accounts records
   * @description Fetch all the Financial account records for given finAccountNumbers and return the List
   */
  public List<FinServ__FinancialAccount__c> getFinAccountList(
    List<String> finAccountNumbers
  ) {
    if (
      finAccountNumbers.isEmpty() ||
      PermissionUtils.canQuery('FinServ__FinancialAccount__c') == false
    ) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        Id,
        FinServ__FinancialAccountNumber__c,
        Ownership__c,
        FinServ__ProductName__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :finAccountNumbers
    ];
  }

  /**
   * @description return list of linked home loan financial accounts
   * @param customerId customer id
   * @return  `List<FinServ__FinancialAccountRole__c>` list of linked financial accounts
   */
  public List<FinServ__FinancialAccountRole__c> getHomeLoanAccountByCustomerId(
    Id customerId
  ) {
    PermissionUtils.canQuery('FinServ__FinancialAccountRole__c');

    return [
      SELECT
        Id,
        FinServ__FinancialAccount__c,
        FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :customerId
        AND FinServ__FinancialAccount__r.RecordTypeId = :RTFinancialAccount.bankAccount
        AND FinServ__FinancialAccount__r.Marketing_Code__c IN :GetHelpConstants.HOME_LOAN_MARKETING_CODES
        AND FinServ__Active__c = TRUE
    ];
  }

  /**
   * @description To get the Customer_Action__c records based on Financial Account Ids
   * @param financialAccountIdSet Set of Financial Account Ids
   * @return List of Pending Customer Action records
   */
  public List<Customer_Action__c> getPendingCustomerActionForFinancialAccounts(
    Set<Id> financialAccountIdSet
  ) {
    if (
      Customer_Action__c.SObjectType.getDescribe().isQueryable() == false ||
      financialAccountIdSet.isEmpty()
    ) {
      return new List<Customer_Action__c>();
    }

    return [
      SELECT Id, Status__c, Financial_Account__c
      FROM Customer_Action__c
      WHERE
        RecordTypeId = :QueryRT.of(Customer_Action__c.SObjectType)
          .getId('Pending_Financial_Account_Updates')
        AND Financial_Account__c IN :financialAccountIdSet
        AND Status__c = :FinancialAccountActions.CUSTOMER_ACTION_STATUS_PENDING
    ];
  }

  /**
   * @description gets all the finanacial account which needds to be displayed on UI
   * @param ownerId owner of fin account
   * @param allRelatedAccountNumbers all the rekated financial account numbers
   * @param recordTypeDeveloperNames record type developer names
   * @return list of FinServ__FinancialAccount__c
   */
  public List<FinServ__FinancialAccount__c> getFinacialAccounts(
    Id ownerId,
    List<String> allRelatedAccountNumbers,
    List<String> recordTypeDeveloperNames
  ) {
    if (
      FinServ__FinancialAccount__c.SObjectType.getDescribe().isQueryable() ==
      false
    ) {
      return new List<FinServ__FinancialAccount__c>();
    }

    return [
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
        OCV_ID__c,
        FinServ__ProductName__c
      FROM FinServ__FinancialAccount__c
      WHERE
        (FinServ__PrimaryOwner__c = :ownerId
        OR FinServ__FinancialAccountNumber__c IN :allRelatedAccountNumbers)
        AND RecordType.DeveloperName IN :recordTypeDeveloperNames
        AND FinServ__Status__c != 'Closed'
      ORDER BY FinServ__Status__c DESC, FinServ__OpenDate__c DESC
    ];
  }
}
