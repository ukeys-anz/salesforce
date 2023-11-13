/**
 * @author Sreekanth Dadipineni
 * @since 09/2022
 * @description CCRMContactPointEmailActions related to handling ContactPointEmailActions object.
 * @runTests CCRMContactPointEmailActionsTest
 */
public with sharing class CCRMContactPointEmailActions {
  private static final String EMAIL_EXISTS_ERROR = 'An email record is already available for this customer. Please edit the email below.';
  private static final String INVALID_EMAIL_ERROR = 'Please enter Email in correct format.';
  private static final String EMAIL_LINKED_ERROR = 'Please select the correct type based on the Customer';
  private static final Profile CURRENT_USER_PROFILE = MLCRMCommonUtils.getProfileById(
    UserInfo.getProfileId()
  );
  private static final Boolean IS_CCRM_USER = (CURRENT_USER_PROFILE?.Name ==
  Label.CCRM_Profile_Name);

  /**
   * @description Copy ParentId to Customer_Name__c field.
   * @name copyParentIdToCustomerName
   * @param records from the trigger
   */
  public static void copyParentIdToCustomerName(
    List<ContactPointEmail> records
  ) {
    for (ContactPointEmail record : records) {
      if (record.ParentId != null && record.Customer_Name__c == null) {
        record.Customer_Name__c = record.ParentId;
      }
    }
  }

  /**
   * @description Unlink parent prospect account when ActiveToDate value is set
   * @name unlinkProspectParentOnDeactivation
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in beforUpdate.
   */
  public static void unlinkProspectParentOnDeactivation(
    List<ContactPointEmail> records,
    Map<Id, ContactPointEmail> oldMap
  ) {
    for (ContactPointEmail cpe : records) {
      if (oldMap.get(cpe.id).ActiveToDate == null && cpe.ActiveToDate != null) {
        cpe.ParentId = null;
      }
    }
  }

  /**
   * @description getExistingOrProspectCPE to get the CPE related to Existing or Prospect Account
   * @param records List of CPE Records
   * @return ContactPointEmailWrapper return List of Existing or Prospect CPE
   */
  public static ContactPointEmailWrapper getExistingOrProspectCPE(
    List<ContactPointEmail> records
  ) {
    ContactPointEmailWrapper cpeWrapper = new ContactPointEmailWrapper();

    Set<Id> accIdsSet = new Set<Id>();
    for (ContactPointEmail record : records) {
      if (record.Customer_Name__c != null) {
        accIdsSet.add(record.Customer_Name__c);
      }
    }

    List<Account> accList = CCRMAccountActions.fetchAccounts(accIdsSet);

    CCRMAccountActions.AccountWrapper existingOrProspectAccounts = new CCRMAccountActions.AccountWrapper();
    existingOrProspectAccounts = CCRMAccountActions.getExistingOrProspectAccounts(
      accList
    );

    for (ContactPointEmail record : records) {
      if (
        existingOrProspectAccounts.prospectAccounts.containsKey(
          record.Customer_Name__c
        )
      ) {
        cpeWrapper.prospectCPE.add(record);
      } else if (
        existingOrProspectAccounts.existingAccounts.containsKey(
          record.Customer_Name__c
        )
      ) {
        cpeWrapper.existingCPE.add(record);
      }
    }

    return cpeWrapper;
  }

  /**
   * @description make sure bankers should only be able to add a new email if there is no existing email available for that Prospect
   * @param records the list of records to check
   */
  public static void checkExistingEmailOnProspectOrExistingCust(
    List<ContactPointEmail> records
  ) {
    Map<Id, AggregateResult> mapAccountIdToEmailCount = new Map<Id, AggregateResult>();
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointEmail record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    mapAccountIdToEmailCount = new Map<Id, AggregateResult>(
      [
        SELECT Customer_Name__c Id, COUNT(Id) Cnt
        FROM ContactPointEmail
        WHERE
          Customer_Name__c IN :accountIds
          AND ActiveToDate = NULL
          AND (Customer_Name__r.Is_Prospect__c = TRUE
          OR (Customer_Name__r.RecordType.DeveloperName IN (
            :CCRMConstants.ACC_RT,
            :MLCRMConstants.PERSONACCOUNT_RT
          )
          AND Customer_Name__r.FinServ__Status__c IN (
            :CCRMConstants.ACTIVE_STATUS,
            :CCRMConstants.INACTIVE_STATUS
          )
          AND Customer_Name__r.Source_System_Name__c = :CCRMConstants.SOURCE_SYSTEM_NAME
          AND Customer_Name__r.ANZx_Customer__c = FALSE))
        WITH SECURITY_ENFORCED
        GROUP BY Customer_Name__c
      ]
    );

    for (ContactPointEmail record : records) {
      if (mapAccountIdToEmailCount.containsKey(record.Customer_Name__c)) {
        record.addError(EMAIL_EXISTS_ERROR);
      }
    }
  }

  /**
   * @description validate prospect's emails. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of email record to validate
   */
  public static void validateExistingOrProspectEmails(
    List<ContactPointEmail> records
  ) {
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (ContactPointEmail record : records) {
      if (
        !String.isBlank(record.EmailAddress) &&
        !Pattern.matches(Label.Regex_Email, record.EmailAddress)
      ) {
        record.addError(
          Schema.SObjectType.ContactPointEmail.fields.EmailAddress.Name,
          INVALID_EMAIL_ERROR
        );
      }
    }
  }

  /**
   * @description Validate If the Organisation Email record is created against Business_Account and Individual Email Record is created against PersonAccount or not.
   * @param records the list of email record to validate
   */
  public static void validateOrgIndividualEmailsLinking(
    List<ContactPointEmail> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Account> accMap;
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (ContactPointEmail record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    if (!accountIds.isEmpty()) {
      accMap = getAccountMap(accountIds);

      for (ContactPointEmail record : records) {
        // if ContactPointEmail record type is Organisation and account record type is NOT Business_Account
        // OR if ContactPointEmail record type is Individual and account record type is NOT PersonAccount
        // then throw error
        if (
          !((record.RecordTypeId == CCRMConstants.CPE_ORG_RT_ID &&
          accMap.get(record.Customer_Name__c).RecordTypeId ==
          CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID) ||
          (record.RecordTypeId == CCRMConstants.CPE_IND_RT_ID &&
          accMap.get(record.Customer_Name__c).RecordTypeId ==
          CCRMConstants.ACCOUNT_PERSON_RT_ID))
        ) {
          record.addError(EMAIL_LINKED_ERROR);
        }
      }
    }
  }

  /**
   * @description get map of Account
   * @param accountIds the list of accountIds
   * @return Map<Id, Account> map of Account
   */
  public static Map<Id, Account> getAccountMap(Set<Id> accountIds) {
    return new Map<Id, Account>(
      [
        SELECT Id, RecordType.DeveloperName, RecordTypeId
        FROM Account
        WHERE Id IN :accountIds
      ]
    );
  }

  /**
   * @author Naman Garg
   * @since  09/2023
   * @group CCRM (Commercial CRM)
   * @description ContactPointEmailWrapper wrapper class to hold Existing and Prospect CPE
   * @name ContactWrapper
   */
  public class ContactPointEmailWrapper {
    public List<ContactPointEmail> prospectCPE = new List<ContactPointEmail>();
    public List<ContactPointEmail> existingCPE = new List<ContactPointEmail>();
  }
}
