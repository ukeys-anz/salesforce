/**
 * @author Zhiren Jason Guan
 * @since  13/02/2024
 * @description Retail Broker related trigger actions class
 * @runTests  RetailBrokerContactActionsTest
 */

public with sharing class RetailBrokerContactActions {
  @TestVisible
  private static final String SYNC_STATUS_BROKER_ORG = 'Broker Org';
  @TestVisible
  private static final String RETAIL_BROKER_ACCREDITATION_TYPE = 'Retail';
  @TestVisible
  private static final String SYNC_STATUS_BLOCKED = 'Blocked';
  @TestVisible
  public static final String SYNC_STATUS_DUPLICATE_EMAIL = 'Duplicate - Email';
  @TestVisible
  public static final String SYNC_STATUS_DUPLICATE_OCVID = 'Duplicate - OCV Id';

  private static final BrokerSettingsRepository BROKER_SETTINGS_REPOSITORY = (BrokerSettingsRepository) Lib_InstanceProvider.forType(
    BrokerSettingsRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final RetailContactMergeRepository CONTACT_REPOSITORY = (RetailContactMergeRepository) Lib_InstanceProvider.forType(
    RetailContactMergeRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  /**
   * @description Generate and dispatch Broker Relation related GCP cloud events
   * @param records map of new contacts from trigger context
   * @param oldMap map of old contacts from trigger context
   * @return List of success published events
   */
  public static List<SObject> publishBrokerRelationEvents(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    List<SObject> publishedEvents = new List<SObject>();
    try {
      if (BROKER_SETTINGS_REPOSITORY.get().BypassBrokerRelationEvent__c) {
        return publishedEvents;
      }
      //Get list of contact records, where OCV Version is > 0 and sync status has Broker Org value in it, and broker is moved under a broker set for the first time
      Set<Id> contactsForAddEvent = ListUtil.getIds(
        ListUtil.filter(records, oldMap)
          .oldEquals(Contact.Broker_Set__c, null)
          .notEquals(Contact.OCV_Event_Version__c, 0)
          .isNotNull(Contact.OCV_Event_Version__c)
          .isNotNull(Contact.Broker_Set__c)
          .contains(Contact.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
          .contains(
            Contact.Broker_Accreditation_Type__c,
            RETAIL_BROKER_ACCREDITATION_TYPE
          )
          .toList(),
        Contact.Id
      );
      //Get list of contact records, where OCV Version is > 0 and sync status has Broker Org value in it, and Broker is transferred to a different broker set
      Set<Id> contactsForDeleteEvent = ListUtil.getIds(
        ListUtil.filter(records, oldMap)
          .oldNotEquals(Contact.Broker_Set__c, null)
          .notEquals(Contact.OCV_Event_Version__c, 0)
          .isNotNull(Contact.OCV_Event_Version__c)
          .isNotNull(Contact.Broker_Set__c)
          .contains(Contact.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
          .contains(
            Contact.Broker_Accreditation_Type__c,
            RETAIL_BROKER_ACCREDITATION_TYPE
          )
          .changed(Contact.Broker_Set__c)
          .toList(),
        Contact.Id
      );

      Set<Id> contactsForBrokerRelationEvent = new Set<Id>();
      contactsForBrokerRelationEvent.addAll(contactsForAddEvent);
      contactsForBrokerRelationEvent.addAll(contactsForDeleteEvent);

      publishedEvents = RetailBrokerRelationEventActions.publishBrokerRelationEventFromContact(
        contactsForBrokerRelationEvent,
        oldMap
      );
      return publishedEvents;
    } catch (Exception e) {
      Logger.error(
          'Encountered error when publishing Broker Relation event. RBM info in Broker Org was not updated.',
          e
        )
        .save();
      return publishedEvents;
    } finally {
      return publishedEvents;
    }
  }

  /**
   * @description Generate and publish Broker contact GCP cloud events
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap  map of old version of contacts
   */
  public static void publishBrokerEvents(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    if (BROKER_SETTINGS_REPOSITORY.get().BypassBrokerEvent__c) {
      return;
    }
    Map<Id, String> brokerIdToEventTypeMap = getBrokerIdToEventTypeMap(
      records,
      contactsOldMap
    );

    RetailBrokerEventActions.publishEventForBrokers(
      brokerIdToEventTypeMap,
      contactsOldMap
    );
  }

  /**
   * @description Generate and publish Broker contact GCP cloud events
   * @param contactsNew list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return Map<Id, String> filtered map of ids and contacts elgible for publishing
   */
  private static Map<Id, String> getBrokerIdToEventTypeMap(
    List<Contact> contactsNew,
    Map<Id, Contact> contactsOldMap
  ) {
    Boolean bypassBrokerEventPermission = USER_INFO.checkCustomPermission(
      'BypassBrokerEvent'
    );
    Map<Id, String> brokerIdToEventTypeMap = new Map<Id, String>();
    for (Contact contactNew : contactsNew) {
      Contact contactOld = contactsOldMap.get(contactNew.Id);
      String action = getAction(contactNew);
      if (
        bypassBrokerEventPermission &&
        isBrokerSetOrOffGroupChanged(contactNew, contactOld)
      ) {
        continue;
      }
      if (
        String.isNotBlank(action) &&
        isRecordAnEligibleBrokerContact(contactNew, contactOld)
      ) {
        brokerIdToEventTypeMap.put(contactNew.Id, action);
      }
    }
    return brokerIdToEventTypeMap;
  }

  /**
   * @description check whether broker set or office group was updated
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return boolean based on the broker set or office group change
   */
  public static Boolean isBrokerSetOrOffGroupChanged(
    Contact contactNew,
    Contact contactOld
  ) {
    return contactNew.Broker_Set__c != contactOld.Broker_Set__c ||
      contactNew.Office_Group__c != contactOld.Office_Group__c;
  }

  /**
   * @description Process contact record updates for OCV sync
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return List of records updated
   */
  public static List<Contact> processOCVSync(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<Contact> filteredOldRecords = ListUtil.filter(contactsOldMap.values())
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
      .toList();

    Set<Id> contactListIds = ListUtil.getIds(filteredOldRecords, Contact.Id);
    List<Contact> filteredNewRecords = ListUtil.filter(records)
      .equals(Contact.Id, contactListIds)
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_BROKER_ORG)
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_BLOCKED)
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_DUPLICATE_EMAIL)
      .notContains(Contact.Sync_Status__c, SYNC_STATUS_DUPLICATE_OCVID)
      .toList();
    List<Contact> filterContactsWithOCVVersion = filterContactsWithOCVVersion(
      filteredNewRecords,
      contactsOldMap
    );
    List<Contact> processedContacts = new List<Contact>();

    for (Contact contactNew : filterContactsWithOCVVersion) {
      contactNew.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
        contactNew.Sync_Status__c,
        SYNC_STATUS_BROKER_ORG
      );
      contactNew.Is_Synced_To_Broker_Org__c = true;
      processedContacts.add(contactNew);
    }

    return processedContacts;
  }

  /**
   * @description get the action type based on contact's OCV Event Version
   * @param contactNew new version of Contact record
   * @return String action type, if it's an add or an update
   */
  @TestVisible
  private static String getAction(Contact contactNew) {
    if (
      contactNew.OCV_Event_Version__c > 0 &&
      contactNew.Sync_Status__c != null &&
      contactNew.Sync_Status__c.contains(SYNC_STATUS_BROKER_ORG) &&
      (contactNew.Survivor_Party_Id__c == null ||
      contactNew.Survivor_Party_Id__c == contactNew.External_Id__c)
    ) {
      return RetailBrokerEventActions.BROKER_EVENT_ADD;
    }
    return '';
  }

  /**
   * @description Indicate if record is a valid Broker contact to be published
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isRecordAnEligibleBrokerContact(
    Contact contactNew,
    contact contactOld
  ) {
    if (String.isNotBlank(contactNew.CommercialTPMISAO__c)) {
      return true;
    }
    if (contactNew.CommercialTPMISAO__c != contactOld.CommercialTPMISAO__c) {
      return true;
    }
    if (String.isNotBlank(contactNew.AssetFinanceTPMISAO__c)) {
      return true;
    }
    if (
      contactNew.AssetFinanceTPMISAO__c != contactOld.AssetFinanceTPMISAO__c
    ) {
      return true;
    }
    if (
      (String.isNotBlank(contactNew.RetailTPMISAO__c) ||
      contactNew.RetailTPMISAO__c != contactOld.RetailTPMISAO__c) &&
      contactNew.Is_Beta_Broker__c
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description Indicate if contact's OCV Event Version is added for the first time
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return List of records updated
   */
  public static List<Contact> filterContactsWithOCVVersion(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<Contact> contactList = new List<Contact>();
    for (Contact contactNew : records) {
      Contact contactOld = contactsOldMap.get(contactNew.Id);
      if (contactNew.OCV_Event_Version__c <= 0) {
        continue;
      }
      if (
        contactOld.OCV_Event_Version__c != null &&
        contactOld.OCV_Event_Version__c > 0
      ) {
        continue;
      }
      contactList.add(contactNew);
    }
    return contactList;
  }

  /**
   * @description blank office group if broker set changing
   * @author  Utkarsh Singh | Salesforce | 27-02-2025
   * @param records contains new value
   * @param oldMap contains old value
   **/
  public static void setBlankOfficeGroupOnChangeBrokerSet(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    if (USER_INFO.checkProfile('Integration User')) {
      return;
    }
    records = ListUtil.filter(records, oldMap)
      .changed(Contact.Broker_Set__c)
      .toList();

    ListUtil.setField(records, Contact.Office_Group__c, null);
  }

  /**
   * @description Generate and publish Broker contact GCP cloud events
   * @param records list of new version of contacts from trigger context
   * @param contactsNewMap map of New version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   */
  public static void contactMergeEvent(
    List<Contact> records,
    Map<Id, Contact> contactsNewMap,
    Map<Id, Contact> contactsOldMap
  ) {
    List<Contact> filteredVictimContactList = filterVictimContacts(
      records,
      contactsOldMap
    );

    List<Broker_Code__c> brokerCodesToBeDeleted = CONTACT_REPOSITORY.getRelatedBrokerCodes(
      new Map<id, contact>(filteredVictimContactList).keySet()
    );

    DML_REPOSITORY.doDelete(brokerCodesToBeDeleted, new DmlConfig());

    Set<String> survivorExternalIdList = ListUtil.getStrings(
      filteredVictimContactList,
      Contact.Survivor_Party_Id__c
    );
    List<contact> survivorContactsList = CONTACT_REPOSITORY.queryContactRecordsByExternalIds(
      survivorExternalIdList
    );

    processDataMerge(filteredVictimContactList, survivorContactsList);
    List<Contact> updatedContacts = updateAssistedBrokerLookup(
      contactsNewMap,
      contactsOldMap
    );

    Set<Id> ccrContactIds = getCCRContactIds(contactsNewMap, contactsOldMap);

    Map<String, List<Contact>> contactListForDuplicateContact = RetailBrokerDuplicateContactAction.checkOldandNewValuesDuplicateContacts(
      records,
      contactsOldMap
    );

    Map<string, List<contact>> contactsMapedbyField = new Map<string, List<contact>>();
    contactsMapedbyField.put('survivorContactsList', survivorContactsList);

    contactsMapedbyField.put(
      'duplicateEmailContacts',
      contactListForDuplicateContact.get('duplicateEmailContacts')
    );
    contactsMapedbyField.put(
      'duplicateOcvIdContacts',
      contactListForDuplicateContact.get('duplicateOcvIdContacts')
    );

    enqueueBrokerRelationUpdate(
      filteredVictimContactList,
      contactsMapedbyField,
      ccrContactIds,
      updatedContacts
    );
  }

  /**
   * @description Process the data merge event
   * @param victimContactsList List<Contact> List of Victim Contacts
   * @param contactsMapedbyField Map<String,List<Contact>> List of Contacts mapped by field for survivor, duplicate email and duplicate ocvid contacts
   * @param ccrContactIds of Contact Ids for CCREvent
   * @param updatedContacts List of updated contacts
   */
  public static void enqueueBrokerRelationUpdate(
    List<Contact> victimContactsList,
    Map<string, List<contact>> contactsMapedbyField,
    Set<Id> ccrContactIds,
    List<Contact> updatedContacts
  ) {
    List<Contact> allContactsList = new List<Contact>(victimContactsList);
    allContactsList.addAll(contactsMapedbyField.get('survivorContactsList'));

    Map<String, contact> contactMap = (Map<String, contact>) ListUtil.mapBy(
      allContactsList,
      Contact.External_Id__c
    );
    List<Contact> survivorDuplicatesList = new List<Contact>();
    Map<Id, String> contactIdByBrokerSet = new Map<Id, String>();
    Map<Id, String> contactIdByOfficeGroup = new Map<Id, String>();
    Map<String, List<Contact>> contactMapForQueueable = new Map<String, List<Contact>>();
    for (Contact victim : victimContactsList) {
      Contact survivor = contactMap.get(victim.Survivor_Party_Id__c);
      if (survivor == null) {
        continue;
      }
      if (survivor.Broker_Set__c != null || victim.Broker_Set__c == null) {
        continue;
      }

      survivorDuplicatesList.add(survivor);
      contactIdByBrokerSet.put(survivor.Id, victim.Broker_Set__c);
      contactIdByOfficeGroup.put(survivor.Id, victim.Office_Group__c);
    }
    contactMapForQueueable = new Map<String, List<Contact>>();
    contactMapForQueueable.put(
      'survivorDuplicatesList',
      survivorDuplicatesList
    );
    contactMapForQueueable.put('updatedContacts', updatedContacts);
    contactMapForQueueable.put(
      'duplicateEmailContacts',
      contactsMapedbyField.get('duplicateEmailContacts')
    );
    contactMapForQueueable.put(
      'duplicateOcvIdContacts',
      contactsMapedbyField.get('duplicateOcvIdContacts')
    );

    System.enqueueJob(
      new UpdateBrokerRelationLookupQueueable(
        contactMapForQueueable,
        contactIdByBrokerSet,
        contactIdByOfficeGroup,
        ccrContactIds
      )
    );
  }
  /**
   * @description Process the data merge event
   * @param victimContactsList List<Contact> List of Victim Contacts
   * @param survivorContactsList List<Contact> List of survivor Contacts
   */
  public static void processDataMerge(
    List<Contact> victimContactsList,
    List<Contact> survivorContactsList
  ) {
    List<Contact> allContactsList = new List<Contact>(victimContactsList);
    allContactsList.addAll(survivorContactsList);

    Map<String, contact> contactMap = (Map<String, contact>) ListUtil.mapBy(
      allContactsList,
      Contact.External_Id__c
    );

    try {
      for (Contact victim : victimContactsList) {
        Contact survivor = contactMap.get(victim.Survivor_Party_Id__c);
        if (survivor == null) {
          continue;
        }
        survivor.Survivor_Party_Id__c = victim.Survivor_Party_Id__c;
        survivor.Victim_Party_Id__c = victim.Victim_Party_Id__c;
        if (survivor.Is_Beta_Broker__c != true) {
          survivor.Is_Beta_Broker__c = victim.Is_Beta_Broker__c;
        }
        if (
          survivor.Sync_Status__c != null &&
          !survivor.Sync_Status__c.contains(SYNC_STATUS_BLOCKED)
        ) {
          survivor.Sync_Status__c = SYNC_STATUS_BROKER_ORG;
          survivor.is_Synced_To_Broker_Org__c = true;
        }
        Database.MergeResult result = Database.merge(survivor, victim, false);

        if (result.isSuccess()) {
          continue;
        }
        Logger.error(
            'Contact Merge failed for following contacts' +
              survivor.Id +
              ' and ' +
              victim.Id +
              'Error_Message: ',
            result
          )
          .save();
      }
    } catch (Exception ex) {
      Logger.error(' Contact Merge Failed due to : ', ex).save();
    }
  }

  /**
   * @description filter records based on updation of Survivor and Victim party Ids, Sync Status field value
   * @param records records from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return List<contact> list of filtered contact records based on updation of Survivor and Victim party Ids, Sync Status field value
   */
  public static List<Contact> filterVictimContacts(
    List<contact> records,
    Map<Id, contact> contactsOldMap
  ) {
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Contact.Survivor_Party_Id__c,
      Contact.Victim_Party_Id__c
    };

    Set<String> victimIdsSet = ListUtil.getStrings(
      records,
      Contact.Victim_Party_Id__c
    );
    List<contact> filteredVictimRecords = ListUtil.filter(
        records,
        contactsOldMap
      )
      .anyChanged(fieldsToValidateChange)
      .isNotBlank(contact.Survivor_Party_Id__c)
      .isNotBlank(contact.Victim_Party_Id__c)
      .equals(Contact.External_Id__c, victimIdsSet)
      .notcontains(Contact.Sync_Status__c, SYNC_STATUS_BLOCKED)
      .toList();

    return filteredVictimRecords;
  }

  /**
   * @description Enqueues a Queueable job to update related RLA records based on contact TPMISAO
   * @param newMap Map of new Contact records.
   * @param oldMap Map of old Contact records.
   * @return List<Contact> List of updated contacts.
   */
  public static List<Contact> updateAssistedBrokerLookup(
    Map<Id, Contact> newMap,
    Map<Id, Contact> oldMap
  ) {
    Set<String> externalIdSet = ListUtil.getStrings(
      newMap.values(),
      Contact.External_Id__c
    );

    List<Contact> updatedContacts = (List<Contact>) ListUtil.filter(
        newMap.values()
      )
      .contains(Contact.Sync_status__c, BrokerConstants.SYNC_STATUS_BROKER_ORG)
      .isNotBlank(contact.Survivor_Party_Id__c)
      .equals(Contact.Survivor_Party_Id__c, externalIdSet)
      .toList();

    return updatedContacts;
  }

  /**
   * @description Gets Contact IDs that changed to "Retail" accreditation and have a Broker Set.
   * @param newMap The map of new Contact records
   * @param oldMap The map of old Contact records
   * @return Set<Id> Set of Contact IDs that meet the criteria.
   */
  private static Set<Id> getCCRContactIds(
    Map<Id, contact> newMap,
    Map<Id, contact> oldMap
  ) {
    List<Contact> oldValidCCRContacts = (List<Contact>) ListUtil.filter(
        oldMap.values()
      )
      .notContains(
        Contact.Broker_Accreditation_Type__c,
        BrokerConstants.ACCREDITATION_RETAIL
      )
      .toList();

    Set<Id> oldIds = ListUtil.getIds(oldValidCCRContacts, Contact.Id);

    List<Contact> updatedCCRContacts = (List<Contact>) ListUtil.filter(
        newMap.values()
      )
      .equals(Contact.Id, oldIds)
      .contains(
        Contact.Broker_Accreditation_Type__c,
        BrokerConstants.ACCREDITATION_RETAIL
      )
      .isNotNull(Contact.Broker_Set__c)
      .toList();
    return ListUtil.getIds(updatedCCRContacts, Contact.Id);
  }
}
