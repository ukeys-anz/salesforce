/**
 * @author Naman Garg
 * @since 09/2024
 * @description This class provide SOQL and DML helper for class related to CommercialContactActions.
 */

public with sharing class CommercialContactRepository {
  private static final String ACTIVE_STATUS = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';
  private static final String SOURCE_SYSTEM_NAME = 'CAP-CIS';
  /**
   * @description It will fetch the current user's Profile Id
   * @return Id - Profile Id of current user
   */
  public Id getUserProfileId() {
    return UserInfo.getProfileId();
  }

  /**
   * @description To be used for apex validations that are meant to replace Custom Validation rules
   * (eg. to run validation at specific points in code whereas Custom Validations are usually run after before triggers).
   * Those apex validations should be treated the same as Custom Validations
   * (can be disabled via "Disable_VRs__c" instead of having to disable all triggers, and can be skipped by user with "CCRM_Skip_Validation" custom permission)
   * @return True if for the current user it will skip validation else false
   */
  public Boolean isSkipValidation() {
    return FeatureManagement.checkPermission('CCRM_Skip_Validation') ||
      Salesforce_Library_Settings__c.getInstance(UserInfo.getUserId())
        .Disable_VRs__c;
  }

  /**
   * @description To be used fetch number of Contact records linked to Account
   * @param accountIdsSet set of Account Ids
   * @return Map<Id, Account> Account Map
   */
  public Map<Id, Account> getAccountAndRelatedContactMap(
    Set<Id> accountIdsSet
  ) {
    Set<String> statusSet = new Set<String>{ ACTIVE_STATUS, INACTIVE_STATUS };
    if (accountIdsSet.isEmpty()) {
      return new Map<Id, Account>();
    }
    return new Map<Id, Account>(
      [
        SELECT Id, (SELECT Id, AccountId FROM Contacts)
        FROM Account
        WHERE
          Id IN :accountIdsSet
          AND (Is_Prospect__c = TRUE
          OR (RecordType.DeveloperName = :RTAccount.businessAccount
          AND FinServ__Status__c IN :statusSet
          AND Source_System_Name__c = :SOURCE_SYSTEM_NAME
          AND ANZx_Customer__c = FALSE))
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description To be used fetch Contact records
   * @param contactIds set of Contact Ids
   * @return List<Contact> Contact list
   */
  public List<Contact> getContacts(Set<Id> contactIds) {
    if (contactIds.isEmpty()) {
      return new List<Contact>();
    }
    return [
      SELECT Id
      FROM Contact
      WHERE Id IN :contactIds
      WITH USER_MODE
    ];
  }
}
