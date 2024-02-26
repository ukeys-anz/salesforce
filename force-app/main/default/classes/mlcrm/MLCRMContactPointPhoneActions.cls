/**
 * @author Ankit Garg
 * @since 07/2023
 * @description CC-4737 MLCRMContactPointPhoneActions is class to handle all the MLCRM Contact Point Phone Actions
 * @runTests MLCRMContactPointPhoneActionsTest
 */
public with sharing class MLCRMContactPointPhoneActions {
  private static final String INVALID_MOBILE_ERROR = 'Please enter Mobile Number in +61412345678/+61512345678 format.';
  private static final String INVALID_PHONE_ERROR = 'Please enter Phone Number in +61212345678 format.';

  /**
   * @description CC-4737 Copy ParentId to Customer_Name__c field.
   * @name copyParentIdToCustomerName
   * @param records from the trigger
   */
  public static void copyParentIdToCustomerName(
    List<ContactPointPhone> records
  ) {
    for (ContactPointPhone record : records) {
      if (record.ParentId != null && record.Customer_Name__c == null) {
        record.Customer_Name__c = record.ParentId;
      }
    }
  }

  /**
   * @description make sure Banker should only be able to add a new Phone if there is no existing Phone available for selected Phone type for the Individual Account
   * @param records the list of records to check
   */
  public static void checkExistingPhoneOnIndividualRecords(
    List<ContactPointPhone> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    for (ContactPointPhone record : records) {
      if (record.Customer_Name__c != null) {
        accountIds.add(record.Customer_Name__c);
      }
    }

    Map<Id, Set<String>> mapAccountIdToPhoneTypes = new Map<Id, Set<String>>();
    for (ContactPointPhone record : [
      SELECT Id, Customer_Name__c, UsageType
      FROM ContactPointPhone
      WHERE
        Customer_Name__c IN :accountIds
        AND ActiveToDate = NULL
        AND Customer_Name__r.isPersonAccount = TRUE
        AND (Customer_Name__r.FinServ__Status__c = :CCRMConstants.PROSPECT
        OR Customer_Name__r.FinServ__Status__c = :CCRMConstants.ACTIVE_STATUS
        OR Customer_Name__r.FinServ__Status__c = :CCRMConstants.INACTIVE_STATUS)
        AND Customer_Name__r.Source_System_Name__c = :CCRMConstants.SOURCE_SYSTEM_NAME
        AND Customer_Name__r.ANZx_Customer__c = FALSE
      WITH SECURITY_ENFORCED
    ]) {
      if (mapAccountIdToPhoneTypes.containsKey(record.Customer_Name__c)) {
        mapAccountIdToPhoneTypes.get(record.Customer_Name__c)
          .add(record.UsageType);
      } else {
        mapAccountIdToPhoneTypes.put(
          record.Customer_Name__c,
          new Set<String>{ record.UsageType }
        );
      }
    }

    for (ContactPointPhone record : records) {
      List<String> usageType = new List<String>{ record.UsageType };
      if (
        mapAccountIdToPhoneTypes.containsKey(record.Customer_Name__c) &&
        mapAccountIdToPhoneTypes.get(record.Customer_Name__c)
          ?.contains(record.UsageType) == true
      ) {
        record.addError(
          String.format(Label.MLCRM_ExistingContactPointPhoneError, usageType)
        );
      }
    }
  }

  /**
   * @description validate Phone. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of Phone record to validate
   */
  public static void validatePhones(List<ContactPointPhone> records) {
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    String sField = Schema.SObjectType.ContactPointPhone.fields.TelephoneNumber.Name;
    for (ContactPointPhone record : records) {
      if (
        !String.isBlank(record.TelephoneNumber) &&
        !String.isBlank(record.UsageType) &&
        record.UsageType.equalsIgnoreCase(MLCRMConstants.PHONETYPE_MOBILE) &&
        !Pattern.matches(Label.Regex_Mobile, record.TelephoneNumber) &&
        !Pattern.matches(Label.Regex_ML_Mobile, record.TelephoneNumber)
      ) {
        record.addError(sField, INVALID_MOBILE_ERROR);
      } else if (
        !String.isBlank(record.TelephoneNumber) &&
        !String.isBlank(record.UsageType) &&
        !record.UsageType.equalsIgnoreCase(MLCRMConstants.PHONETYPE_MOBILE) &&
        !Pattern.matches(Label.Regex_Phone, record.TelephoneNumber)
      ) {
        record.addError(sField, INVALID_PHONE_ERROR);
      }
    }
  }

  /**
   * @description Unlink parent prospect account when ActiveToDate value is set
   * @name unlinkProspectParentOnDeactivation
   * @param records from the trigger
   * @param oldMap This Map<Id, SObject> contains the map which holds the previous values which can be used to check what value has changed in beforeUpdate.
   */
  public static void unlinkProspectParentOnDeactivation(
    List<ContactPointPhone> records,
    Map<Id, ContactPointPhone> oldMap
  ) {
    for (ContactPointPhone cpPhone : records) {
      if (
        oldMap.get(cpPhone.id).ActiveToDate == null &&
        cpPhone.ActiveToDate != null
      ) {
        cpPhone.ParentId = null;
      }
    }
  }

  /**
   * @description getExistingOrProspectCPP to get the CPP related to Existing or Prospect Account
   * @param records List of CPP Records
   * @return ContactPointPhoneWrapper return List of Existing or Prospect CPP
   */
  public static ContactPointPhoneWrapper getExistingOrProspectCPP(
    List<ContactPointPhone> records
  ) {
    ContactPointPhoneWrapper cppWrapper = new ContactPointPhoneWrapper();

    Set<Id> accIdsSet = new Set<Id>();
    for (ContactPointPhone record : records) {
      if (record.Customer_Name__c != null) {
        accIdsSet.add(record.Customer_Name__c);
      }
    }

    List<Account> accList = CCRMAccountActions.fetchAccounts(accIdsSet);

    CCRMAccountActions.AccountWrapper existingOrProspectAccounts = new CCRMAccountActions.AccountWrapper(accList);

    for (ContactPointPhone record : records) {
      if (
        existingOrProspectAccounts.prospectAccounts.containsKey(
          record.Customer_Name__c
        )
      ) {
        cppWrapper.prospectCPP.add(record);
      } else if (
        existingOrProspectAccounts.existingAccounts.containsKey(
          record.Customer_Name__c
        )
      ) {
        cppWrapper.existingCPP.add(record);
      }
    }
    return cppWrapper;
  }

  /**
   * @author Ankit Garg
   * @since  09/2023
   * @group MLCRM (Mobile Lending CRM)
   * @description ContactPointPhoneWrapper wrapper class to hold Existing and Prospect CPP
   * @name ContactPointPhoneWrapper
   */
  public class ContactPointPhoneWrapper {
    public List<ContactPointPhone> prospectCPP = new List<ContactPointPhone>();
    public List<ContactPointPhone> existingCPP = new List<ContactPointPhone>();
  }
}
