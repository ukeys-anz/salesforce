/**
 * @author Shivam Swaraj
 * @since Mon July 24 2024
 * @description Provides SOQL and DML helpers for HomeLoanController, FinancialAccountController
 */
public with sharing class FinancialAccountRepository {
  /**
   * @description return the id(s) of the financial account owners
   * @param financialAccountId financial account record id
   * @return list of FAR which are Primary or Additional role type
   */
  public List<FinServ__FinancialAccountRole__c> getAccountOwnerDetails(
    Id financialAccountId
  ) {
    return [
      SELECT Id, FinServ__RelatedAccount__c, FinServ__RelatedAccount__r.Name
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__FinancialAccount__c = :financialAccountId
        AND FinServ__Active__c = TRUE
        AND FinServ__Role__c IN :FinancialAccountConstant.FINSERV_ROLE_TYPES
      WITH USER_MODE
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
      WITH USER_MODE
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
    if (finAccountNumbers.isEmpty()) {
      return new List<FinServ__FinancialAccount__c>();
    }
    return [
      SELECT
        Id,
        FinServ__FinancialAccountNumber__c,
        Ownership__c,
        Linked_Product_Code__c,
        FinServ__ProductName__c,
        Product_Name_Display__c
      FROM FinServ__FinancialAccount__c
      WHERE FinServ__FinancialAccountNumber__c IN :finAccountNumbers
      WITH USER_MODE
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
    if (financialAccountIdSet.isEmpty()) {
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
      WITH USER_MODE
    ];
  }

  /**
   * @description gets all the finanacial account which needds to be displayed on UI
   * @param allRelatedAccountNumbers all the rekated financial account numbers
   * @return list of FinServ__FinancialAccount__c
   */
  public List<FinServ__FinancialAccount__c> getFinancialAccounts(
    List<String> allRelatedAccountNumbers
  ) {
    if (allRelatedAccountNumbers.isEmpty()) {
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
        FinServ__ProductName__c,
        Linked_Product_Code__c,
        Product_Name_Display__c
      FROM FinServ__FinancialAccount__c
      WHERE
        FinServ__FinancialAccountNumber__c IN :allRelatedAccountNumbers
        AND FinServ__Status__c != 'Closed'
      WITH USER_MODE
      ORDER BY FinServ__Status__c DESC, FinServ__OpenDate__c DESC
    ];
  }

  /**
   * @description Aggregates the total balance for all checking and saving account for eligible marketing codes
   * @param accountNumbers list of account numbers received from FAR query for the given OCVId
   * @param marketingCodes eligible marketing codes to be included in balance total
   * @return SUM of the balance for the eligible marketing codes
   */
  public AggregateResult getTotalBalance(
    Set<String> accountNumbers,
    Set<String> marketingCodes
  ) {
    if (accountNumbers.isEmpty() || marketingCodes.isEmpty()) {
      return null;
    }

    return [
      SELECT SUM(FinServ__Balance__c) totalBalance
      FROM FinServ__FinancialAccount__c
      WHERE
        FinServ__Balance__c != NULL
        AND FinServ__FinancialAccountNumber__c = :accountNumbers
        AND Marketing_Code__c IN :marketingCodes
        AND FinServ__Status__c IN ('Active', 'Open')
      WITH USER_MODE
    ];
  }

  /**
   * @description builds a list of financial account roles for the customer sent from the UI
   * Account_Number__c (formula field) = FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
   * @param customerRecordPrimaryOwnerId customer id receive from the UI
   * @param productCodes product codes
   * @return List<String> list of the financial account roles
   */
  public List<FinServ__FinancialAccountRole__c> getAllAccountNumberPerOwner(
    Id customerRecordPrimaryOwnerId,
    Set<String> productCodes
  ) {
    if (customerRecordPrimaryOwnerId == null || productCodes.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    return [
      SELECT Account_Number__c, Product_Name_Display__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :customerRecordPrimaryOwnerId
        AND FinServ__Active__c = TRUE
        AND FinServ__FinancialAccount__r.Linked_Product_Code__c IN :productCodes
        AND FinServ__Role__c IN :FinancialAccountConstant.FINSERV_ROLE_TYPES
      WITH USER_MODE
    ];
  }

  /**
   * @description builds a list of financial account roles for the customer sent from the UI
   * Account_Number__c (formula field) = FinServ__FinancialAccount__r.FinServ__FinancialAccountNumber__c
   * @param customerRecordPrimaryOwnerId customer id receive from the UI
   * @param marketingCodes ANZX marketing codes
   * @return List<FinServ__FinancialAccountRole__c> list of the financial account roles
   */
  public List<FinServ__FinancialAccountRole__c> getAllSavingsAccountNumberPerOwner(
    Id customerRecordPrimaryOwnerId,
    Set<String> marketingCodes
  ) {
    if (customerRecordPrimaryOwnerId == null || marketingCodes.isEmpty()) {
      return new List<FinServ__FinancialAccountRole__c>();
    }

    return [
      SELECT Account_Number__c, Product_Name_Display__c
      FROM FinServ__FinancialAccountRole__c
      WHERE
        FinServ__RelatedAccount__c = :customerRecordPrimaryOwnerId
        AND FinServ__Active__c = TRUE
        AND FinServ__FinancialAccount__r.Marketing_Code__c IN :marketingCodes
        AND FinServ__FinancialAccount__r.RecordTypeId = :RTFinancialAccount.savingAccount
        AND FinServ__Role__c IN :FinancialAccountConstant.FINSERV_ROLE_TYPES
      WITH USER_MODE
    ];
  }

  /**
   * @description get FinServ__FinancialAccount__c records with their primary owner
   * @param recordIds ids of the financial accounts to be retrieved
   * @return Map<Id, FinServ__FinancialAccount__c>  map of ids vs FinServ__FinancialAccount__c records
   */
  public Map<Id, FinServ__FinancialAccount__c> getFinancialAccountsWithPrimaryOwner(
    Set<Id> recordIds
  ) {
    if (recordIds.isEmpty()) {
      return new Map<Id, FinServ__FinancialAccount__c>();
    }
    return new Map<Id, FinServ__FinancialAccount__c>(
      [
        SELECT Id, Finserv__PrimaryOwner__c
        FROM FinServ__FinancialAccount__c
        WHERE Id IN :recordIds
        WITH USER_MODE
      ]
    );
  }
}
