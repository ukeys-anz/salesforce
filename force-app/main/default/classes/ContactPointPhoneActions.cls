/**
 * @author Ankit Garg
 * @since 07/2023
 * @description ContactPointPhoneActions is class to handle all the  ContactPointPhone Actions in Trigger
 * @runTests ContactPointPhoneActionsTest
 */
public with sharing class ContactPointPhoneActions {
  private static final String INVALID_MOBILE_ERROR = 'Please enter Mobile Number in +61412345678/+61512345678 format.';
  private static final String INVALID_PHONE_ERROR = 'Please enter Phone Number in +61212345678 format.';
  private static final String USAGE_TYPE_SECURITY_MOBILE = 'Security Mobile';
  public static final String PHONETYPE_MOBILE = 'Mobile Telephone';
  private static final String ACTIVE_STATUS = 'Active';
  private static final String INACTIVE_STATUS = 'Inactive';
  private static final ContactPointObjectActionsRepository PHONE_REPOSITORY = (ContactPointObjectActionsRepository) Lib_InstanceProvider.forType(
    ContactPointObjectActionsRepository.class
  );
  private static final String NOT_ALLOWED_USAGE_TYPE_ERROR = 'You are not authorized to insert the ANZx mobile phone';
  private static final String USAGE_TYPE_CHANGE_ERROR = 'You do not have the necessary privileges to update the usage type';
  private static final String CONTACT_ADMIN_ERROR = 'You do not have the level of access necessary to perform the operation you requested. Please contact the owner of the record or your administrator if access is necessary.';
  private static final String USAGE_TYPE_PRIMARY_BUSINESS_TELEPHONE = 'Primary Business Telephone';
  private static final String USAGE_TYPE_PRIMARY_HOME_TELEPHONE = 'Primary Home Telephone';
  private static final String PROFILE_ML_USER = 'ANZ ML Standard User';
  private static final String USAGE_TYPE_MOBILE_TELEPHONE = 'Mobile Telephone';
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description CC-4737 Copy ParentId to Customer_Name__c field.
   * @name copyParentIdToCustomerName
   * @param records from the trigger
   */
  public static void copyParentIdToCustomerName(
    List<ContactPointPhone> records
  ) {
    for (ContactPointPhone record : records) {
      if (record.ParentId == null || record.Customer_Name__c != null) {
        continue;
      }
      record.Customer_Name__c = record.ParentId;
    }
  }

  /**
   * @description make sure Banker should only be able to add a new Phone if there is no existing Phone available for selected Phone type for the Individual Account
   * @param records the list of records to check
   */
  public static void checkExistingPhoneOnIndividualRecords(
    List<ContactPointPhone> records
  ) {
    Set<Id> accountIds = ListUtil.getIds(
      records,
      ContactPointPhone.Customer_Name__c
    );
    Map<Id, Set<String>> mapAccountIdToPhoneTypes = new Map<Id, Set<String>>();
    for (
      ContactPointPhone record : PHONE_REPOSITORY.getContactPointPhones(
        accountIds
      )
    ) {
      if (!mapAccountIdToPhoneTypes.containsKey(record.Customer_Name__c)) {
        mapAccountIdToPhoneTypes.put(
          record.Customer_Name__c,
          new Set<String>{ record.UsageType }
        );
        continue;
      }
      mapAccountIdToPhoneTypes.get(record.Customer_Name__c)
        .add(record.UsageType);
    }
    for (ContactPointPhone record : records) {
      List<String> usageType = new List<String>{ record.UsageType };
      if (
        !mapAccountIdToPhoneTypes.containsKey(record.Customer_Name__c) ||
        !mapAccountIdToPhoneTypes.get(record.Customer_Name__c)
          ?.contains(record.UsageType)
      ) {
        continue;
      }
      record.addError(
        String.format(Label.ExistingContactPointPhoneError, usageType)
      );
    }
  }

  /**
   * @description validate Phone. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of Phone record to validate
   */
  public static void validatePhones(List<ContactPointPhone> records) {
    if (PHONE_REPOSITORY.isCustomValidationsSkipped()) {
      return;
    }
    String sField = Schema.SObjectType.ContactPointPhone.fields.TelephoneNumber.Name;
    for (ContactPointPhone record : records) {
      if (
        String.isBlank(record.TelephoneNumber) ||
        String.isBlank(record.UsageType)
      ) {
        continue;
      }
      if (
        record.UsageType.equalsIgnoreCase(PHONETYPE_MOBILE) &&
        !Pattern.matches(Label.Regex_Mobile, record.TelephoneNumber) &&
        !Pattern.matches(Label.Regex_ML_Mobile, record.TelephoneNumber)
      ) {
        record.addError(sField, INVALID_MOBILE_ERROR);
      } else if (
        !record.UsageType.equalsIgnoreCase(PHONETYPE_MOBILE) &&
        !Pattern.matches(Label.Regex_Phone, record.TelephoneNumber)
      ) {
        record.addError(sField, INVALID_PHONE_ERROR);
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
    Set<Id> accIdsSet = ListUtil.getIds(
      records,
      ContactPointPhone.Customer_Name__c
    );
    List<Account> accList = PHONE_REPOSITORY.fetchAccounts(accIdsSet);
    AccountWrapper existingOrProspectAccounts = new AccountWrapper(accList);
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
   * @description validate if insert is allowed based on usage type
   * @param records the list of Phone record to validate
   */
  public static void validateUsageType(List<ContactPointPhone> records) {
    if (
      PHONE_REPOSITORY.isCustomValidationsSkipped() ||
      !PHONE_REPOSITORY.isCurrentLoggedInMLUser()
    ) {
      return;
    }
    List<SObject> securityPhoneRecords = ListUtil.filter(records)
      .equals(ContactPointPhone.UsageType, USAGE_TYPE_SECURITY_MOBILE)
      .toList();
    CommonUtil.raiseSobjectError(
      securityPhoneRecords,
      NOT_ALLOWED_USAGE_TYPE_ERROR
    );
  }

  /**
   * @description prevent edit if usage type is changed or anzx mobile is changed by ML user
   * @param records the list of Phone record to validate
   * @param oldMap old record map
   */
  public static void preventEdit(
    List<ContactPointPhone> records,
    Map<Id, ContactPointPhone> oldMap
  ) {
    if (
      PHONE_REPOSITORY.isCustomValidationsSkipped() ||
      !PHONE_REPOSITORY.isCurrentLoggedInMLUser()
    ) {
      return;
    }

    List<SObject> securityMobileRecords = ListUtil.filter(records)
      .equals(ContactPointPhone.UsageType, USAGE_TYPE_SECURITY_MOBILE)
      .toList();
    CommonUtil.raiseSobjectError(securityMobileRecords, CONTACT_ADMIN_ERROR);
    List<SObject> recordWithUsageTypeChange = ListUtil.filter(records, oldMap)
      .changed(ContactPointPhone.UsageType)
      .toList();
    CommonUtil.raiseSobjectError(
      recordWithUsageTypeChange,
      USAGE_TYPE_CHANGE_ERROR
    );
  }

  /**
   * @description to delete expired ContactPointPhone records
   * @name deleteExpiredRecords
   * @param records the list of Phone records from trigger
   * @param oldMap oldMap records
   */
  public static void deleteExpiredRecords(
    List<ContactPointPhone> records,
    Map<Id, ContactPointPhone> oldMap
  ) {
    if (!Schema.sObjectType.ContactPointPhone.isDeletable()) {
      return;
    }
    List<ContactPointPhone> phonesToDelete = new List<ContactPointPhone>();
    List<ContactPointPhone> updatedATDPhones = ListUtil.filter(records, oldMap)
      .changed(ContactPointPhone.ActiveToDate)
      .toList();
    for (ContactPointPhone phone : updatedATDPhones) {
      if (phone.ActiveToDate == null || phone.ActiveToDate > System.today()) {
        continue;
      }
      phonesToDelete.add(new ContactPointPhone(Id = phone.Id));
    }
    DML_REPOSITORY.doDelete(phonesToDelete, new DmlConfig().allowPartial());
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

  /**
   * @description AccountWrapper wrapper class to hold Existing and Prospect Account
   * @name AccountWrapper
   */
  private class AccountWrapper {
    private Map<Id, Account> prospectAccounts = new Map<Id, Account>();
    private Map<Id, Account> existingAccounts = new Map<Id, Account>();
    Set<ID> recordTypeIDSet = new Set<ID>{
      RTAccount.businessAccount,
      RTAccount.personAccount
    };

    /**
     * @description AccountWrapper constructor to check if the Account is an active/inactive or Prospect account
     * @param records List of Account
     */
    public AccountWrapper(List<Account> records) {
      List<Account> filteredProspectCustomers = ListUtil.filter(records)
        .equals(Account.Is_Prospect__c, true)
        .toList();
      prospectAccounts = (Map<Id, Account>) ListUtil.mapBy(
        filteredProspectCustomers,
        Account.Id
      );
      List<Account> filteredExistingCustomers = ListUtil.filter(records)
        .equals(Account.RecordTypeId, recordTypeIDSet)
        .equals(
          Account.FinServ__Status__c,
          new Set<String>{ ACTIVE_STATUS, INACTIVE_STATUS }
        )
        .equals(Account.Source_System_Name__c, Label.CCRM_Source_System_Name)
        .equals(Account.ANZx_Customer__c, false)
        .toList();
      existingAccounts = (Map<Id, Account>) ListUtil.mapBy(
        filteredExistingCustomers,
        Account.Id
      );
    }
  }
}
