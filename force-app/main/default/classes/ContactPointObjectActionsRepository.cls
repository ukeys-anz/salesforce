/**
 * @author Ashwin Mohan
 * @since 10/2024
 * @description Repository class to query ContactPoint Objects
 */
public with sharing class ContactPointObjectActionsRepository {
  private static final String PROSPECT = 'Prospect';
  private static final String ACTIVE_STATUS = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';
  private static final String SOURCE_SYSTEM_NAME = 'CAP-CIS';
  private static final String PERSONACCOUNT_RT = 'PersonAccount';
  private static final String ACC_RT = 'Business_Account';
  private static final Set<String> CLASSIC_PHONES = new Set<String>{
    'Primary Business Telephone',
    'Primary Home Telephone',
    'Mobile Telephone'
  };

  /**
   * @description Check whether the logged in user is ML User
   * @return Boolean True if a user is ML User false otherwise
   */
  public Boolean isCurrentLoggedInMLUser() {
    return (UserInfo.getProfileId() == QueryProfile.anzMLStandardUser.Id);
  }

  /**
   * @description to get phone records for given set of account Ids
   * @name getContactPointPhones
   * @param parentIds set of account Ids
   * @return  List<ContactPointPhone> list of phone records
   */
  public List<ContactPointPhone> getContactPointPhones(Set<Id> parentIds) {
    if (parentIds.isEmpty()) {
      return new List<ContactPointPhone>();
    }
    return [
      SELECT Id, Customer_Name__c, UsageType
      FROM ContactPointPhone
      WHERE
        Customer_Name__c IN :parentIds
        AND ActiveToDate = NULL
        AND Customer_Name__r.isPersonAccount = TRUE
        AND (Customer_Name__r.FinServ__Status__c = :PROSPECT
        OR Customer_Name__r.FinServ__Status__c = :ACTIVE_STATUS
        OR Customer_Name__r.FinServ__Status__c = :INACTIVE_STATUS)
        AND Customer_Name__r.Source_System_Name__c = :SOURCE_SYSTEM_NAME
        AND Customer_Name__r.ANZx_Customer__c = FALSE
      WITH USER_MODE
    ];
  }

  /**
   * @description fetchAccounts fetch List of accounts
   * @param accIds Ids of Account
   * @return List<Account> return List of Accounts
   */
  public List<Account> fetchAccounts(Set<Id> accIds) {
    if (accIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT
        Id,
        Is_Prospect__c,
        isPersonAccount,
        RecordTypeId,
        FinServ__Status__c,
        Source_System_Name__c,
        ANZx_Customer__c
      FROM Account
      WHERE Id IN :accIds
      WITH USER_MODE
    ];
  }

  /**
   * @description isCustomValidationsSkipped check Custom Validations Skipped
   * @return Boolean
   */
  public Boolean isCustomValidationsSkipped() {
    return (FeatureManagement.checkPermission('CCRM_Skip_Validation') ||
    Salesforce_Library_Settings__c.getInstance(UserInfo.getUserId())
      .Disable_VRs__c);
  }

  /**
   * @description return existing email records using customerIds
   * @param accountIds List of Customer Ids
   * @return set ContactPointEmail
   */
  public List<ContactPointEmail> getExistingEmailRecords(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<ContactPointEmail>();
    }
    return [
      SELECT Id, Customer_Name__c, UsageType
      FROM ContactPointEmail
      WHERE
        Customer_Name__c IN :accountIds
        AND ActiveToDate = NULL
        AND (Customer_Name__r.Is_Prospect__c = TRUE
        OR (Customer_Name__r.RecordType.DeveloperName IN (
          :ACC_RT,
          :PERSONACCOUNT_RT
        )
        AND Customer_Name__r.FinServ__Status__c IN (
          :ACTIVE_STATUS,
          :INACTIVE_STATUS
        )
        AND Customer_Name__r.Source_System_Name__c = :SOURCE_SYSTEM_NAME
        AND Customer_Name__r.ANZx_Customer__c = FALSE))
      WITH USER_MODE
    ];
  }

  /**
   * @description to get Customer Id of phone record
   * @name getCustomerFromPhone
   * @param recordId recordId of CPP object
   * @return ContactPointPhone
   */
  public ContactPointPhone getCustomerFromPhone(Id recordId) {
    if (recordId == null) {
      return new ContactPointPhone();
    }
    return [
      SELECT ParentId
      FROM ContactPointPhone
      WHERE Id = :recordId
      WITH USER_MODE
    ];
  }

  /**
   * @description return classic ContactPointPhone records of an Account
   * @name getPhoneRecords
   * @param parentId recordId of Account
   * @return List<ContactPointPhone>
   */
  public List<ContactPointPhone> getPhoneRecords(Id parentId) {
    if (parentId == null) {
      return new List<ContactPointPhone>();
    }
    return [
      SELECT Id
      FROM ContactPointPhone
      WHERE
        UsageType IN :CLASSIC_PHONES
        AND ParentId = :parentId
        AND ActiveToDate = NULL
      WITH USER_MODE
    ];
  }
}
