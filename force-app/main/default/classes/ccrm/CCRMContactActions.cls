/**
 * @author Tan Phan
 * @since  09/2022
 * @description CCRMContactActions is the class to handle all the CCRM (Commercial CRM) Actions related to Contact object
 * @runTests CCRMContactActionsTest
 */
public with sharing class CCRMContactActions {
  private static final String MAX_CONTACT_PER_ORG_ERROR = 'Unable to add more than 10 Contacts per Organisation.';
  private static final String INVALID_MOBILE_ERROR = 'Please enter Mobile Number in +61412345678 format.';
  private static final String INVALID_PHONE_ERROR = 'Please enter Work Phone Number in +61212345678 format.';
  private static final String INVALID_EMAIL_ERROR = 'Please enter Email in correct format.';
  private static final String CONTACT_METHOD_ERROR = 'At least one type of contact method must be provided.';
  private static final String CONTACT_LINKED_ERROR = 'Please select the correct type based on the Customer.';
  private static final Profile CURRENT_USER_PROFILE = MLCRMCommonUtils.getProfileById(
    UserInfo.getProfileId()
  );
  private static final Boolean IS_CCRM_USER = (CURRENT_USER_PROFILE?.Name ==
  Label.CCRM_Profile_Name);

  /**
   * @description getExistingOrProspectContact to get the CPE related to Existing or Prospect Contact
   * @param records List of Contact Records
   * @return ContactWrapper return List of Existing or Prospect Contact
   */
  public static ContactWrapper getExistingOrProspectContacts(
    List<Contact> records
  ) {
    ContactWrapper conWrap = new ContactWrapper();
    Set<Id> accIdsSet = new Set<Id>();
    for (Contact record : records) {
      if (
        record.RecordTypeId == CCRMConstants.CONTACT_BUSINESS_RT_ID &&
        record.AccountId != null
      ) {
        accIdsSet.add(record.AccountId);
      }
    }

    List<Account> accList = CCRMAccountActions.fetchAccounts(accIdsSet);

    CCRMAccountActions.AccountWrapper accWrap = new CCRMAccountActions.AccountWrapper();
    accWrap = CCRMAccountActions.getExistingOrProspectAccounts(accList);

    for (Contact record : records) {
      if (accWrap.prosAcc.containsKey(record.AccountId)) {
        conWrap.prosContact.add(record);
      } else if (accWrap.activeAcc.containsKey(record.AccountId)) {
        conWrap.activeContact.add(record);
      }
    }
    return conWrap;
  }

  /**
   * @description validate prospect's contact phones. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param records the list of contacts validate
   */
  public static void validateExistingOrProspectContacts(List<Contact> records) {
    if (CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (Contact record : records) {
      if (
        !String.isBlank(record.Phone) &&
        !Pattern.matches(Label.Regex_Phone, record.Phone)
      ) {
        record.addError(
          Schema.SObjectType.Contact.fields.Phone.Name,
          INVALID_PHONE_ERROR
        );
      }
      if (
        !String.isBlank(record.MobilePhone) &&
        !Pattern.matches(Label.Regex_Mobile, record.MobilePhone)
      ) {
        record.addError(
          Schema.SObjectType.Contact.fields.MobilePhone.Name,
          INVALID_MOBILE_ERROR
        );
      }
      if (
        !String.isBlank(record.Email) &&
        !Pattern.matches(Label.Regex_Email, record.Email)
      ) {
        record.addError(
          Schema.SObjectType.Contact.fields.Email.Name,
          INVALID_EMAIL_ERROR
        );
      }
      if (
        String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)
      ) {
        record.addError(CONTACT_METHOD_ERROR);
      }
      if (
        String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)
      ) {
        record.addError(CONTACT_METHOD_ERROR);
      }
      if (
        String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)
      ) {
        record.addError(CONTACT_METHOD_ERROR);
      }
    }
  }

  /**
   * @description make sure bankers can only add up to 10 Commercial Contact records per organisation record
   * @name checkMaxContactsPerOrganisation
   * @param records The records to check
   */
  public static void checkMaxContactsPerOrganisation(List<Contact> records) {
    Set<Id> accountIds = new Set<Id>();
    Map<Id, AggregateResult> mapAccountIdToContactCount;
    for (Contact record : records) {
      if (record.AccountId != null) {
        accountIds.add(record.AccountId);
      }
    }

    mapAccountIdToContactCount = new Map<Id, AggregateResult>(
      [
        SELECT AccountId Id, COUNT(Id) Cnt
        FROM Contact
        WHERE
          AccountId IN :accountIds
          AND (Account.Is_Prospect__c = TRUE
          OR (Account.RecordType.DeveloperName = 'Business_Account'
          AND Account.FinServ__Status__c IN ('Active', 'Inactive')
          AND Account.Source_System_Name__c = 'CAP-CIS'
          AND Account.ANZx_Customer__c = FALSE))
        WITH SECURITY_ENFORCED
        GROUP BY AccountId
      ]
    );

    for (Contact record : records) {
      if (
        mapAccountIdToContactCount.containsKey(record.AccountId) &&
        Integer.valueOf(
          mapAccountIdToContactCount.get(record.AccountId).get('Cnt')
        ) >= 10
      ) {
        record.addError(MAX_CONTACT_PER_ORG_ERROR);
      }
    }
  }

  /**
   * @description Hide commercial contacts by setting Active To Date and Record Type = Hidden on contact
   * when Phone and Mobile and Fax deleted from commercial contact
   * @param records List of new contacts records
   * @param oldRecordsMap Map of contacts old records
   */
  public static void hideCommercialContacts(
    List<Contact> records,
    Map<Id, Contact> oldRecordsMap
  ) {
    List<Contact> recordsToUpdate = new List<Contact>();
    for (Contact record : records) {
      Contact contactOldRec = oldRecordsMap != null
        ? oldRecordsMap.get(record.id)
        : new Contact();
      if (
        record.RecordTypeId == CCRMConstants.CONTACT_BUSINESS_RT_ID &&
        ((!String.isBlank(contactOldRec.Phone) ||
        !String.isBlank(contactOldRec.MobilePhone) ||
        !String.isBlank(contactOldRec.Fax)) &&
        (String.isBlank(record.Phone) &&
        String.isBlank(record.MobilePhone) &&
        String.isBlank(record.Fax)))
      ) {
        record.Active_To__c = System.today();
        recordsToUpdate.add(record);
      }
    }
    hideContacts(recordsToUpdate);
  }

  /**
   * @description Helper method to hide commercial contact by updating record type to "Hidden" after back up record type to Previous_Record_Type__c
   * @param records List of contacts records
   */
  public static void hideContacts(List<Contact> records) {
    for (Contact record : records) {
      record.Previous_Record_Type__c = Schema.SObjectType.Contact
        .getRecordTypeInfosById()
        .get(record.RecordTypeId)
        .getName();
      record.RecordTypeId = CCRMConstants.CONTACT_HIDDEN_RT_ID;
    }
  }

  /**
   * @description Validate If the Organisation/Individual Contact Record is created against Organisation/Individual Customer or not.
   * @param records the list of contact record to validate
   */
  public static void validateOrgIndividualContactsLinking(
    List<Contact> records
  ) {
    Set<Id> accountIds = new Set<Id>();
    Map<Id, Account> accMap;
    if (!IS_CCRM_USER || CCRMConstants.SKIP_CUSTOM_VALIDATION_RULES) {
      return;
    }
    for (Contact record : records) {
      if (record.AccountId != null) {
        accountIds.add(record.AccountId);
      }
    }

    if (!accountIds.isEmpty()) {
      accMap = CCRMContactPointEmailActions.getAccountMap(accountIds);

      for (Contact record : records) {
        if (
          !(record.RecordTypeId == CCRMConstants.CONTACT_BUSINESS_RT_ID &&
          accMap.get(record.AccountId).RecordTypeId ==
          CCRMConstants.ACCOUNT_ORGANISATION_BUSINESS_RT_ID)
        ) {
          record.addError(CONTACT_LINKED_ERROR);
        }
      }
    }
  }

  /**
   * @author Naman Garg
   * @since  09/2023
   * @group CCRM (Commercial CRM)
   * @description ContactWrapper wrapper class to hold Existing and Prospect Contact
   * @name ContactWrapper
   */
  public class ContactWrapper {
    public List<Contact> prosContact = new List<Contact>();
    public List<Contact> activeContact = new List<Contact>();
  }
}
