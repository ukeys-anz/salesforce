/**
 * @author Zhiren Jason Guan
 * @since  13/02/2024
 * @description Retail Broker related trigger actions class
 * @runTests  RetailBrokerContactActionsTest
 */

public with sharing class RetailBrokerContactActions {
  private static Boolean isMergeInProgress = false;

  private static final BrokerSettingsRepository BROKER_SETTINGS_REPOSITORY = (BrokerSettingsRepository) Lib_InstanceProvider.forType(
    BrokerSettingsRepository.class
  );
  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );
  private static final RetailContactRepository CONTACT_REPOSITORY = (RetailContactRepository) Lib_InstanceProvider.forType(
    RetailContactRepository.class
  );

  private static final BrokerCodeRepository BROKER_CODE_REPOSITORY = (BrokerCodeRepository) Lib_InstanceProvider.forType(
    BrokerCodeRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final UserActionsRepository USER_REPOSITORY = (UserActionsRepository) Lib_InstanceProvider.forType(
    UserActionsRepository.class
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
          .contains(
            Contact.Sync_Status__c,
            BrokerConstants.SYNC_STATUS_BROKER_ORG
          )
          .contains(
            Contact.Broker_Accreditation_Type__c,
            BrokerConstants.ACCREDITATION_RETAIL
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
          .contains(
            Contact.Sync_Status__c,
            BrokerConstants.SYNC_STATUS_BROKER_ORG
          )
          .contains(
            Contact.Broker_Accreditation_Type__c,
            BrokerConstants.ACCREDITATION_RETAIL
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
    if (
      BROKER_SETTINGS_REPOSITORY.get().BypassBrokerEvent__c ||
      isMergeInProgress == true
    ) {
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
      String action = getAction(contactNew, contactOld);
      if (
        bypassBrokerEventPermission &&
        isBrokerSetOrOffGroupChanged(contactNew, contactOld)
      ) {
        continue;
      }
      if (
        (String.isNotBlank(action) &&
        isRecordAnEligibleBrokerContact(contactNew))
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
    List<Contact> contactList = ListUtil.filter(contactsOldMap.values())
      .notContains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      )
      .toList();
    contactList = ListUtil.filter(contactList)
      .notContains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      )
      .notContains(Contact.Sync_Status__c, BrokerConstants.SYNC_STATUS_BLOCKED)
      .notContains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL
      )
      .notContains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID
      )
      .toList();
    Set<Id> contactListIds = ListUtil.getIds(contactList, Contact.Id);
    List<Contact> processedContacts = new List<Contact>();
    for (Contact contactNew : records) {
      if (
        !contactListIds.contains(contactNew.Id) ||
        !isContactsOCVEventVersionAdded(
          contactNew,
          contactsOldMap.get(contactNew.id)
        )
      ) {
        continue;
      }
      contactNew.Sync_Status__c = PicklistUtil.addMultiPicklistValue(
        contactNew.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      );
      processedContacts.add(contactNew);
    }
    return processedContacts;
  }

  /**
   * @description get the action type based on contact's OCV Event Version
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return String action type, if it's an add or an update
   */
  @TestVisible
  private static String getAction(Contact contactNew, Contact contactOld) {
    if (
      doesSyncStatusContain(
        contactNew,
        BrokerConstants.SYNC_STATUS_BROKER_ORG
      ) == true &&
      contactNew.OCV_Event_Version__c > 0
    ) {
      return RetailBrokerEventActions.BROKER_EVENT_ADD;
    }
    return '';
  }

  /**
   * @description Indicate if record is a valid Broker contact to be published
   * @param record new version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  @TestVisible
  private static Boolean isRecordAnEligibleBrokerContact(Contact record) {
    return String.isNotBlank(record.CommercialTPMISAO__c) ||
      String.isNotBlank(record.AssetFinanceTPMISAO__c) ||
      (String.isNotBlank(record.RetailTPMISAO__c) && record.Is_Beta_Broker__c);
  }

  /**
   * @description Indicate if contact's OCV Event Version is added for the first time
   * @param contactNew new version of Contact record
   * @param contactOld old version of Contact record
   * @return Boolean to indicate the eligibility of the contact record
   */
  private static Boolean isContactsOCVEventVersionAdded(
    Contact contactNew,
    Contact contactOld
  ) {
    return contactNew.OCV_Event_Version__c > 0 &&
      (contactOld.OCV_Event_Version__c == null ||
      contactOld.OCV_Event_Version__c <= 0);
  }

  /**
   * @description Check if contact's Sync Status contains a value
   * @param contact the record
   * @param value the value to be checked if it is present in contact's Sync Status
   * @return Boolean to indicate the eligibility of the contact record
   */
  private static Boolean doesSyncStatusContain(Contact contact, String value) {
    return contact.Sync_Status__c != null &&
      contact.Sync_Status__c.contains(value);
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
   * @description Check for duplicate contacts using Email and OCV_Id__C
   * @author  Madhuri Edke | Salesforce | 08-07-2025
   * @param records contains new value
   **/
  public static void checkDuplicateContacts(List<Contact> records) {
    try {
      List<String> contactEmails = (List<String>) ListUtil.getValues(
        records,
        'Email',
        String.class
      );
      List<String> contactOcvIDs = (List<String>) ListUtil.getValues(
        records,
        'OCV_ID__c',
        String.class
      );
      List<Contact> duplicateContacts = CONTACT_REPOSITORY.getDuplicateContacts(
        contactEmails,
        contactOcvIDs
      );

      Map<String, Contact> emailDuplicates = (Map<String, Contact>) ListUtil.mapBy(
        duplicateContacts,
        contact.Email
      );
      Map<String, Contact> ocvDuplicates = (Map<String, Contact>) ListUtil.mapBy(
        duplicateContacts,
        contact.OCV_ID__c
      );
      updateDuplicateContacts(records, emailDuplicates, ocvDuplicates);
    } catch (Exception ex) {
      Logger.error(
          'Failed to fetch Contacts due to:' + ' ' + ex.getMessage(),
          ex
        )
        .save();
    }
  }

  /**
   * @description Updates Sync Status based on duplicate contacts
   * @author  Madhuri Edke | Salesforce | 08-07-2025
   * @param records new contacts from trigger
   * @param emailDuplicates Map of email to respective duplicate new contacts
   * @param ocvDuplicates Map of OCV Id to respective duplicate new contacts
   **/
  private static void updateDuplicateContacts(
    List<Contact> records,
    Map<String, Contact> emailDuplicates,
    Map<String, Contact> ocvDuplicates
  ) {
    for (Contact con : records) {
      List<String> statusValues = new List<String>();

      if (emailDuplicates.containsKey(con.Email)) {
        statusValues.add(BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL);
      }

      if (ocvDuplicates.containsKey(con.OCV_ID__c)) {
        statusValues.add(BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID);
      }
      if (!statusValues.isEmpty()) {
        String currentStatus = String.isBlank(con.Sync_Status__c)
          ? ''
          : con.Sync_Status__c + ';';

        con.Sync_Status__c = currentStatus + String.join(statusValues, ';');
      }
    }
  }

  /**
   * @description Generate and publish Broker contact GCP cloud events
   * @param records list of new version of contacts from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   */
  public static void contactMergeEvent(
    List<Contact> records,
    Map<Id, Contact> contactsOldMap
  ) {
    List<Contact> filteredContactList = filterContacts(records, contactsOldMap);
    if (filteredContactList.isEmpty()) {
      return;
    }

    List<Broker_Code__c> brokerCodesToBeDeleted = BROKER_CODE_REPOSITORY.getRelatedBrokerCodes(
      new Map<id, contact>(filteredContactList).keySet()
    );

    DML_REPOSITORY.doDelete(brokerCodesToBeDeleted, new DmlConfig());

    Set<String> survivorExternalIdList = ListUtil.getStrings(
      filteredContactList,
      Contact.Survivor_Party_Id__c
    );
    List<contact> survivorContactsList = CONTACT_REPOSITORY.queryContactRecordsByExternalIds(
      survivorExternalIdList
    );

    Map<String, contact> survivorcontactsWithExternalIds = (Map<String, contact>) ListUtil.mapBy(
      survivorContactsList,
      Contact.External_Id__c
    );

    map<String, string> mergesToProcess = getDataMergeRecords(
      filteredContactList
    );
    Set<String> contactids = new Set<String>(mergesToProcess.keySet());
    contactids.addAll(mergesToProcess.values());

    List<contact> allContactsWithExternalIds = CONTACT_REPOSITORY.queryContactRecordsByExternalIds(
      contactids
    );

    processDataMerge(mergesToProcess, allContactsWithExternalIds);

    List<Contact> contactsToUpdate = getContactsTobeUpdated(
      filteredContactList,
      survivorcontactsWithExternalIds
    );

    DML_REPOSITORY.doUpdate(contactsToUpdate, new DMLConfig());
  }

  /**
   * @description Get the survivor contacts to be updated
   * @param filteredRecords list of filtered contacts
   * @param contactsWithExternalIds Map of contacts based on ExternalId
   * @return List<contact> list of updated survivor contacts
   */
  public static List<contact> getContactsTobeUpdated(
    List<Contact> filteredRecords,
    Map<String, contact> contactsWithExternalIds
  ) {
    List<Contact> contactTobeUpdated = new List<contact>();
    if (filteredRecords.isEmpty()) {
      return contactTobeUpdated;
    }
    for (Contact victimCon : filteredRecords) {
      String survivorId = victimCon.Survivor_Party_Id__c;
      Contact survivorCon = new Contact(
        Id = contactsWithExternalIds.get(survivorId).Id
      );
      survivorCon.Survivor_Party_Id__c = victimCon.Survivor_Party_Id__c;
      survivorCon.Victim_Party_Id__c = victimCon.Victim_Party_Id__c;
      survivorCon.Sync_Status__c = 'Broker Org';

      if (
        doesSyncStatusContain(
          contactsWithExternalIds.get(survivorId),
          BrokerConstants.SYNC_STATUS_BLOCKED
        )
      ) {
        survivorCon.Sync_Status__c = BrokerConstants.SYNC_STATUS_BLOCKED;
      }

      contactTobeUpdated.add(survivorCon);
    }
    return contactTobeUpdated;
  }
  /**
   * @description Process the data merge event
   * @param filteredRecords list of filtered contacts
   * @return Map<String, String> Map of Surviving Contact Id and Victim Contact Id
   */
  public static map<String, String> getDataMergeRecords(
    List<Contact> filteredRecords
  ) {
    Map<String, String> mergesToProcess = new Map<String, String>();
    for (contact contact : filteredRecords) {
      String survivorId = contact.Survivor_Party_Id__c;
      mergesToProcess.put(survivorId, contact.Victim_Party_Id__c);
    }
    return mergesToProcess;
  }

  /**
   * @description Process the data merge event
   * @param mergesToProcess Map<Id,Id> Map of Surviving Contact and Victim Contact Ids
   * @param contactsList List<Contact> List of Contacts
   */
  public static void processDataMerge(
    Map<String, String> mergesToProcess,
    List<Contact> contactsList
  ) {
    Map<String, contact> contactMap = (Map<String, contact>) ListUtil.mapBy(
      contactsList,
      Contact.External_Id__c
    );
    List<Id> successfulSurvivorIds = new List<Id>();
    Map<Id, String> contactIdByBrokerSet = new Map<Id, String>();
    Map<Id, String> contactIdByOfficeGroup = new Map<Id, String>();
    isMergeInProgress = true;
    try {
      for (String survivorId : mergesToProcess.keySet()) {
        String victimId = mergesToProcess.get(survivorId);
        Contact victim = contactMap.get(victimId);
        Contact survivor = contactMap.get(survivorId);
        if (victim != null && survivor != null) {
          if (victim.Broker_Set__c != null) {
            contactIdByBrokerSet.put(survivor.Id, victim.Broker_Set__c);
          }
          if (victim.Office_Group__c != null) {
            contactIdByOfficeGroup.put(survivor.Id, victim.Office_Group__c);
          }

          Database.MergeResult result = Database.merge(survivor, victim, false);

          if (result.isSuccess()) {
            if (
              doesSyncStatusContain(
                survivor,
                BrokerConstants.SYNC_STATUS_BROKER_ORG
              ) == false
            ) {
              successfulSurvivorIds.add(survivor.Id);
            }
          } else {
            for (Database.Error err : result.getErrors()) {
              Logger.error(
                'Contact Merge failed for following contacts' +
                  survivorId +
                  ' and ' +
                  victimId +
                  'Error_Message: ' +
                  err.getMessage()
              );
            }
            Logger.saveLog();
          }
        }
      }

      updateBrokerRelationLookup(
        successfulSurvivorIds,
        contactIdByBrokerSet,
        contactIdByOfficeGroup
      );
    } catch (Exception e) {
      Logger.error(e.getMessage());
      Logger.saveLog();
    } finally {
      isMergeInProgress = false;
    }
  }

  /**
   * @description filter records based on updation of Survivor and Victim party Ids, Sync Status field value
   * @param records records from trigger context
   * @param contactsOldMap map of old version of contacts from trigger context
   * @return List<contact> list of filtered contact records based on updation of Survivor and Victim party Ids, Sync Status field value
   */
  public static List<Contact> filterContacts(
    List<contact> records,
    Map<Id, contact> contactsOldMap
  ) {
    if (records.isEmpty()) {
      return new List<Contact>();
    }
    Set<SObjectField> fieldsToValidateChange = new Set<SObjectField>{
      Contact.Survivor_Party_Id__c,
      Contact.Victim_Party_Id__c
    };

    Set<String> victimIdsSet = ListUtil.getStrings(
      records,
      Contact.Victim_Party_Id__c
    );

    List<contact> filterDuplicateEmailRecords = ListUtil.filter(
        records,
        contactsOldMap
      )
      .anyChanged(fieldsToValidateChange)
      .isNotBlank(contact.Survivor_Party_Id__c)
      .isNotBlank(contact.Victim_Party_Id__c)
      .equals(Contact.External_Id__c, victimIdsSet)
      .contains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_DUPLICATE_EMAIL
      )
      .notContains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID
      )
      .toList();

    List<contact> filterDuplicateOCVRecords = ListUtil.filter(
        records,
        contactsOldMap
      )
      .anyChanged(fieldsToValidateChange)
      .isNotBlank(contact.Survivor_Party_Id__c)
      .isNotBlank(contact.Victim_Party_Id__c)
      .equals(Contact.External_Id__c, victimIdsSet)
      .contains(
        Contact.Sync_Status__c,
        BrokerConstants.SYNC_STATUS_DUPLICATE_OCVID
      )
      .toList();

    List<contact> filterBrokerOrgRecords = ListUtil.filter(
        records,
        contactsOldMap
      )
      .anyChanged(fieldsToValidateChange)
      .isNotBlank(contact.Survivor_Party_Id__c)
      .isNotBlank(contact.Victim_Party_Id__c)
      .equals(Contact.External_Id__c, victimIdsSet)
      .contains(Contact.Sync_Status__c, BrokerConstants.SYNC_STATUS_BROKER_ORG)
      .toList();
    List<Contact> allRecordsfiltered = new List<Contact>(
      filterDuplicateEmailRecords
    );

    allRecordsfiltered.addAll(filterDuplicateOCVRecords);
    allRecordsfiltered.addAll(filterBrokerOrgRecords);

    return allRecordsfiltered;
  }

  /**
   * @description Enqueues a Queueable job to update related RLA records based on contact TPMISAO
   * @param records List of survivor Contact records used to extract Retail TPMISAO code.
   * @param oldMap Map of old Contact records.
   */
  public static void updateAssistedBrokerLookup(
    List<Contact> records,
    Map<Id, Contact> oldMap
  ) {
    List<Contact> updatedContacts = (List<Contact>) ListUtil.filter(
        records,
        oldMap
      )
      .changed(Contact.RetailTPMISAO__c)
      .toList();

    Set<String> brokerTPMIIds = ListUtil.getStrings(
      updatedContacts,
      Contact.RetailTPMISAO__c
    );
    System.enqueueJob(new RetailContactMergeActionsQueueable(brokerTPMIIds));
  }

  /**
   * @description Updates the Broker Set and Office Group fields on survivor contact records
   *              using values from their corresponding victim contacts after a merge.
   *              This method runs asynchronously using the @future annotation.
   *
   * @param survivorIds List of survivor Contact Ids.
   * @param contactIdByBrokerSet Map of Contact Id to Broker_Set__c value from victim contacts.
   * @param contactIdByOfficeGroup Map of Contact Id to Office_Group__c value from victim contacts.
   */
  @future
  public static void updateBrokerRelationLookup(
    List<Id> survivorIds,
    Map<Id, String> contactIdByBrokerSet,
    Map<Id, String> contactIdByOfficeGroup
  ) {
    List<Contact> contactsToUpdate = new List<Contact>();

    for (Id contactId : survivorIds) {
      Contact contactRec = new Contact(Id = contactId);
      if (
        contactIdByBrokerSet.containsKey(contactId) ||
        contactIdByOfficeGroup.containsKey(contactId)
      ) {
        contactRec.Broker_Set__c = contactIdByBrokerSet.get(contactId);
        contactRec.Office_Group__c = contactIdByOfficeGroup.get(contactId);
        contactsToUpdate.add(contactRec);
      }
    }

    DML_REPOSITORY.doUpdate(contactsToUpdate, new DMLConfig());
  }
}
