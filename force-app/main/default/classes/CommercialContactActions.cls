/**
 * @author Naman Garg
 * @since Oct 2024
 * @description  CommercialContactActions is the orchestrator class for CommercialContactTriggerHandler.
 */

public with sharing class CommercialContactActions {
  private static final String INVALID_PHONE_ERROR = 'Please enter Work Phone Number in +61212345678 format.';
  private static final String INVALID_MOBILE_ERROR = 'Please enter Mobile Number in +61412345678 format.';
  private static final String INVALID_EMAIL_ERROR = 'Please enter Email in correct format.';
  private static final String CONTACT_METHOD_ERROR = 'At least one type of contact method must be provided.';
  private static final Integer MAX_CONTACTS = 10;
  private static final String MAX_CONTACTS_PER_ORG_ERROR = 'Unable to add more than 10 Contacts per Organisation.';

  private static final CommercialAccountRepository ACCOUNT_REPOSITORY = (CommercialAccountRepository) Lib_InstanceProvider.forType(
    CommercialAccountRepository.class
  );
  private static final CommercialContactRepository CONTACT_REPOSITORY = (CommercialContactRepository) Lib_InstanceProvider.forType(
    CommercialContactRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description This is used to populate the last name field on contact during creation/updation
   * @param contactList the list of contacts
   * @param oldContactMap contains old value of contact
   */
  public static void populateLastName(
    List<Contact> contactList,
    Map<Id, Contact> oldContactMap
  ) {
    List<Contact> filterConList = ListUtil.filter(contactList, oldContactMap)
      .changed(Contact.Name__c)
      .toList();

    for (Contact conRec : filterConList) {
      conRec.LastName = conRec.Name__c;
    }
  }

  /**
   * @description This is used to populate the custom name field on contact during creation/updation
   * @param contactList the list of contacts
   * @param oldContactMap contains old value of contact
   */
  public static void populateName(
    List<Contact> contactList,
    Map<Id, Contact> oldContactMap
  ) {
    List<Contact> filterConList = ListUtil.filter(contactList, oldContactMap)
      .changed(Contact.LastName)
      .toList();

    for (Contact conRec : filterConList) {
      conRec.Name__c = conRec.LastName;
    }
  }

  /**
   * @description validate prospect's contact phones. This is done instead of Custom Validation Rule since these values will be reverted before Custom Validation kick in.
   * @param contactList the list of contacts validate
   */
  public static void validateExistingOrProspectContacts(
    List<Contact> contactList
  ) {
    if (CONTACT_REPOSITORY.isSkipValidation()) {
      return;
    }
    for (Contact conRec : contactList) {
      if (
        String.isNotBlank(conRec.Phone) &&
        !Pattern.matches(Label.Regex_Phone, conRec.Phone)
      ) {
        conRec.Phone.addError(INVALID_PHONE_ERROR);
      }
      if (
        String.isNotBlank(conRec.MobilePhone) &&
        !Pattern.matches(Label.Regex_Mobile, conRec.MobilePhone)
      ) {
        conRec.MobilePhone.addError(INVALID_MOBILE_ERROR);
      }
      if (
        String.isNotBlank(conRec.Email) &&
        !Pattern.matches(Label.Regex_Email, conRec.Email)
      ) {
        conRec.Email.addError(INVALID_EMAIL_ERROR);
      }
      if (
        String.isBlank(conRec.Phone) &&
        String.isBlank(conRec.MobilePhone) &&
        String.isBlank(conRec.Fax)
      ) {
        conRec.addError(CONTACT_METHOD_ERROR);
      }
    }
  }

  /**
   * @description make sure bankers can only add up to 10 Commercial Contact records per organisation record
   * @name checkMaxContactsPerOrganisation
   * @param contactList The records to check
   */
  public static void checkMaxContactsPerOrganisation(
    List<Contact> contactList
  ) {
    List<Contact> filterContactList = ListUtil.filter(contactList)
      .isNotNull(Contact.AccountId)
      .toList();
    Set<Id> accountIdsSet = ListUtil.getIds(
      filterContactList,
      Contact.AccountId
    );

    Map<Id, Account> accountAndRelatedContactMap = CONTACT_REPOSITORY.getAccountAndRelatedContactMap(
      accountIdsSet
    );

    for (Contact contactRec : filterContactList) {
      if (!accountAndRelatedContactMap.containsKey(contactRec.AccountId)) {
        return;
      }
      if (
        (accountAndRelatedContactMap.get(contactRec.AccountId)
          .contacts.size()) >= MAX_CONTACTS
      ) {
        contactRec.addError(MAX_CONTACTS_PER_ORG_ERROR);
      }
    }
  }

  /**
   * @description Delete commercial contacts when fax, mobile and phone are blank
   * when Phone and Mobile and Fax deleted from commercial contact
   * @param contactList List of new contacts records
   */
  public static void deleteCommercialContactsWithoutContactDetails(
    List<Contact> contactList
  ) {
    Set<Id> conIdsToDelete = new Set<Id>();
    for (Contact conRec : contactList) {
      if (
        String.isBlank(conRec.Phone) &&
        String.isBlank(conRec.MobilePhone) &&
        String.isBlank(conRec.Fax)
      ) {
        conIdsToDelete.add(conRec.Id);
      }
    }
    deleteCommercialContactAsync(conIdsToDelete);
  }

  /**
   * @description Delete commercial contacts async
   * @param contactIds Set of Contact Ids to be deleted
   */
  @future
  private static void deleteCommercialContactAsync(Set<Id> contactIds) {
    List<Contact> contactRecordsList = CONTACT_REPOSITORY.getContacts(
      contactIds
    );
    DML_REPOSITORY.doDelete(contactRecordsList, new DMLConfig().allowPartial());
  }
}
