/**
 * @author Smruti Khobragade | Salesforce | 08-07-2025
 * @description Retail Broker related trigger actions class for Duplicate Contacts
 */

public with sharing class RetailBrokerDuplicateContactAction {
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = BrokerConstants.SYNC_STATUS_BROKER_ORG;
  @TestVisible
  public static final String SYNC_STATUS_DUPLICATE_EMAIL = BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL;
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = BrokerConstants.SYNC_STATUS_BLOCKED;
  @TestVisible
  public static final String SYNC_STATUS_DUPLICATE_OCVID = BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID;
  private static final RetailContactMergeRepository CONTACT_REPOSITORY = (RetailContactMergeRepository) Lib_InstanceProvider.forType(
    RetailContactMergeRepository.class
  );

  private static final Set<SObjectField> FIELDS_TO_VALIDATE_CHANGE = new Set<SObjectField>{
    Contact.Email,
    Contact.OCV_ID__c
  };

  /**
   * @description Check for duplicate contacts using Email and OCV_Id__C
   * @author  Smruti Khobragade | Salesforce | 08-07-2025
   * @param records contains new value
   * @param contactsOldMap  map of old version of contacts
   **/
  public static void checkDuplicateContacts(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<contact> validRecords = records;
    try {
      if (contactsOldMap != null) {
        validRecords = ListUtil.filter(records, contactsOldMap)
          .anyChanged(FIELDS_TO_VALIDATE_CHANGE)
          .notcontains(Contact.Sync_Status__c, SYNC_STATUS_BLOCKED)
          .toList();
      }
      if (validRecords.isEmpty()) {
        return;
      }
      Set<String> contactEmails = (Set<String>) ListUtil.getStrings(
        validRecords,
        Contact.Email
      );
      Set<String> contactOcvIDs = (Set<String>) ListUtil.getStrings(
        validRecords,
        Contact.OCV_ID__c
      );
      List<Contact> duplicateContacts = CONTACT_REPOSITORY.getDuplicateContacts(
        ListUtil.getIds(validRecords, contact.Id),
        contactEmails,
        contactOcvIDs
      );
      Set<String> emailDuplicates = ListUtil.getStrings(
        duplicateContacts,
        contact.Email
      );
      Set<String> ocvDuplicates = ListUtil.getStrings(
        duplicateContacts,
        contact.OCV_ID__c
      );

      updateContactsSyncStatus(validRecords, emailDuplicates, ocvDuplicates);
    } catch (Exception ex) {
      Logger.error(
          'Failed to fetch Contacts due to:' + ' ' + ex.getMessage(),
          ex
        )
        .save();
    }
  }
  /**
   * @description Re-calculate and update the Sync Status for each broker, based on Email, and OCV_Id__C
   * @author  Smruti Khobragade | Salesforce | 08-07-2026
   * @param brokers new or changed broker records
   * @param emailDuplicates existing records with same Email
   * @param ocvDuplicates existing records with same OCV Id
   **/
  @TestVisible
  private static void updateContactsSyncStatus(
    List<Contact> brokers,
    Set<String> emailDuplicates,
    Set<String> ocvDuplicates
  ) {
    Set<String> currentSyncStatus;
    Boolean hasValidEventVersion;
    Set<string> newDuplicateStatus;

    for (Contact broker : brokers) {
      currentSyncStatus = new Set<String>(
        broker.Sync_Status__c?.split(';') ?? new List<String>()
      );
      hasValidEventVersion = (broker.OCV_Event_Version__c ?? 0) >= 1;
      // reset duplicate statuses
      currentSyncStatus.remove(SYNC_STATUS_DUPLICATE_EMAIL);
      currentSyncStatus.remove(SYNC_STATUS_DUPLICATE_OCVID);
      // re-calculate duplicate statuses
      newDuplicateStatus = new Set<String>();
      if (
        String.isNotBlank(broker.Email) &&
        emailDuplicates.contains(broker.Email)
      ) {
        newDuplicateStatus.add(SYNC_STATUS_DUPLICATE_EMAIL);
      }
      if (
        String.isNotBlank(broker.OCV_ID__c) &&
        ocvDuplicates.contains(broker.OCV_ID__c)
      ) {
        newDuplicateStatus.add(SYNC_STATUS_DUPLICATE_OCVID);
      }

      // add or remove the "Broker Org" status, based on duplicates found.
      if (!newDuplicateStatus.isEmpty()) {
        currentSyncStatus.remove(SYNC_STATUS_BROKER_ORG);
        currentSyncStatus.addAll(newDuplicateStatus);
      } else if (hasValidEventVersion) {
        currentSyncStatus.add(SYNC_STATUS_BROKER_ORG);
        if (!broker.Is_Synced_To_Broker_Org__c) {
          broker.Is_Synced_To_Broker_Org__c = true;
        }
      }
      broker.Sync_Status__c = String.join(currentSyncStatus, ';');
    }
  }

  /**
   * @description This method is used to fetch the related contacts with new and old values of Email and OCV_Id__C and return a map containing list of contacts with old and new values for Email and OCV_Id__c
   * @author  Smruti Khobragade | Salesforce | 08-07-2025
   * @param records contains record Values
   * @param contactsOldMap contains old contact values from trigger context
   * @return Map<String, List<Contact>> map containing list of contacts with old and new values for Email and OCV_Id__c
   **/
  public static Map<String, List<Contact>> checkOldandNewValuesDuplicateContacts(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<contact> validRecords = ListUtil.filter(records, contactsOldMap)
      .anyChanged(FIELDS_TO_VALIDATE_CHANGE)
      .notcontains(Contact.Sync_Status__c, SYNC_STATUS_BLOCKED)
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
      .isNotNull(Contact.Sync_Status__c)
      .toList();

    validRecords.addAll(
      RetailBrokerContactActions.filterContactsWithOCVVersion(
        records,
        contactsOldMap
      )
    );

    if (validRecords.isEmpty()) {
      return new Map<String, List<Contact>>();
    }

    List<Contact> validOCVRecords = ListUtil.filter(validRecords)
      .contains(Contact.Sync_Status__c, SYNC_STATUS_DUPLICATE_OCVID)
      .toList();

    List<Contact> validEmailRecords = ListUtil.filter(validRecords)
      .contains(Contact.Sync_Status__c, SYNC_STATUS_DUPLICATE_EMAIL)
      .toList();

    Set<Id> ocvIds = new Set<Id>(ListUtil.getIds(validOCVRecords, Contact.Id));
    Set<Id> emailIds = new Set<Id>(
      ListUtil.getIds(validEmailRecords, Contact.Id)
    );

    List<Contact> oldContacts = new List<Contact>(contactsOldMap.values());
    List<contact> oldOCVValidRecords = ListUtil.filter(oldContacts)
      .equals(Contact.Id, ocvIds)
      .toList();

    List<contact> oldEmailValidRecords = ListUtil.filter(oldContacts)
      .equals(Contact.Id, emailIds)
      .toList();

    List<Contact> combinedValidEmailRecords = new List<Contact>(
      oldEmailValidRecords
    );
    combinedValidEmailRecords.addAll(validEmailRecords);

    List<Contact> combinedValidOcvRecords = new List<Contact>(
      oldOCVValidRecords
    );
    combinedValidOcvRecords.addAll(validOCVRecords);

    Set<String> contactEmails = new Set<String>(
      ListUtil.getStrings(combinedValidEmailRecords, Contact.Email)
    );

    Set<String> contactOcvIDs = new Set<String>(
      ListUtil.getStrings(combinedValidOcvRecords, Contact.OCV_ID__c)
    );

    List<Contact> duplicateContacts = CONTACT_REPOSITORY.getDuplicateContacts(
      ListUtil.getIds(validRecords, contact.Id),
      contactEmails,
      contactOcvIDs
    );

    Map<String, List<Contact>> contactList = getContactsWithOldNewValues(
      duplicateContacts,
      contactEmails,
      contactOcvIDs
    );

    return contactList;
  }

  /**
   * @description get the list of contacts for duplicate contacts using Email and OCV_Id__c
   * @author  Smruti Khobragade | Salesforce | 08-07-2025
   * @param duplicateContacts Map for duplicate contacts with old and new values for Email and OCV_Id__c
   * @param contactEmails contains email values
   * @param contactOcvIDs contains ocv values
   * @return Map<String, List<Contact>> map containing list of contacts with old and new values for Email and OCV_Id__c
   **/
  public static Map<String, List<Contact>> getContactsWithOldNewValues(
    List<Contact> duplicateContacts,
    Set<String> contactEmails,
    Set<String> contactOcvIDs
  ) {
    Map<String, List<Contact>> contactMap = new Map<String, List<Contact>>();
    List<Contact> contactList = ListUtil.filter(duplicateContacts)
      .notcontains(Contact.Sync_Status__c, SYNC_STATUS_BLOCKED)
      .toList();
    List<Contact> emailDuplicates = new List<Contact>();
    List<Contact> ocvIdDuplicates = new List<Contact>();

    for (Contact con : contactList) {
      if (con.Email != null && contactEmails.contains(con.Email)) {
        emailDuplicates.add(con);
      }

      if (con.OCV_ID__c != null && contactOcvIDs.contains(con.OCV_ID__c)) {
        ocvIdDuplicates.add(con);
      }
    }

    contactMap.put('duplicateEmailContacts', emailDuplicates);
    contactMap.put('duplicateOcvIdContacts', ocvIdDuplicates);

    return contactMap;
  }
}
