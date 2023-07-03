/**
 * @author Boobalakrishnan Duraisamy
 * @since  05/2023
 * @group CCRM (Commercial CRM)
 * @description to handle all commercial CRM Contact to Contact actions
 */
public with sharing class CCRMContactToContactActions {
  private static Map<Id, FinServ__ReciprocalRole__c> reciprocalRolesIdMap {
    get {
      if (reciprocalRolesIdMap == null) {
        reciprocalRolesIdMap = new Map<Id, FinServ__ReciprocalRole__c>();
        for (FinServ__ReciprocalRole__c reciprocalRole : reciprocalRoles) {
          reciprocalRolesIdMap.put(reciprocalRole.Id, reciprocalRole);
        }
      }
      return reciprocalRolesIdMap;
    }
    set;
  }

  private static Map<String, FinServ__ReciprocalRole__c> reciprocalRolesOCVRoleMap {
    get {
      if (reciprocalRolesOCVRoleMap == null) {
        reciprocalRolesOCVRoleMap = new Map<String, FinServ__ReciprocalRole__c>();
        for (FinServ__ReciprocalRole__c reciprocalRole : reciprocalRoles) {
          reciprocalRolesOCVRoleMap.put(
            reciprocalRole.OCV_Role__c,
            reciprocalRole
          );
        }
      }
      return reciprocalRolesOCVRoleMap;
    }
    set;
  }

  private static List<FinServ__ReciprocalRole__c> reciprocalRoles {
    get {
      if (reciprocalRoles == null) {
        reciprocalRoles = [
          SELECT Id, Name, FinServ__InverseRelationship__c, OCV_Role__c
          FROM FinServ__ReciprocalRole__c
          WHERE OCV_Role__c != NULL
          WITH SECURITY_ENFORCED
        ];
      }
      return reciprocalRoles;
    }
    set;
  }

  /**
   * @description set External Id of FinServ__ContactContactRelation__c object based on OCV Role ID from Finserv__ReciprocalRole__c
   * @name setExternalId
   * @param records The Contact to contacts records passed from beforeInsert()
   */
  public static void setExternalId(
    List<FinServ__ContactContactRelation__c> records
  ) {
    Map<String, FinServ__ContactContactRelation__c> contactToContactMap = getExistingExternalIds(
      records
    );
    Map<Id, String> contactExtIdMap = getPersonContacts(records);
    for (FinServ__ContactContactRelation__c record : records) {
      populateRoleId(record);
      populateExternalId(record, contactToContactMap, contactExtIdMap);
    }
  }

  /**
   * @description query FinServ__ContactContactRelation__c object and get existing external ids
   * @name getExistingExternalIds
   * @param records The Contact to contacts records passed from beforeInsert()
   * @return Map<String, FinServ__ContactContactRelation__c>
   */
  private static Map<String, FinServ__ContactContactRelation__c> getExistingExternalIds(
    List<FinServ__ContactContactRelation__c> records
  ) {
    Map<String, FinServ__ContactContactRelation__c> contactToContactMap = new Map<String, FinServ__ContactContactRelation__c>();
    Set<String> externalIdSet = new Set<String>();
    for (FinServ__ContactContactRelation__c record : records) {
      if (String.isNotBlank(record.External_Id__c)) {
        externalIdSet.add(record.External_Id__c);
      }
    }
    for (FinServ__ContactContactRelation__c contactToContactRec : [
      SELECT Id, External_Id__c, FinServ__Contact__c, FinServ__RelatedContact__c
      FROM FinServ__ContactContactRelation__c
      WHERE External_Id__c IN :externalIdSet
      WITH SECURITY_ENFORCED
    ]) {
      contactToContactMap.put(
        contactToContactRec.External_Id__c,
        contactToContactRec
      );
    }
    return contactToContactMap;
  }

  /**
   * @description get external ids of related person contacts from account object
   * @name getPersonContacts
   * @param records The Contact to contacts records passed from beforeInsert()
   * @return Map<Id, String>
   */
  private static Map<Id, String> getPersonContacts(
    List<FinServ__ContactContactRelation__c> records
  ) {
    Map<Id, String> contactExtIdMap = new Map<Id, String>();
    Set<Id> personContactIds = new Set<Id>();
    for (FinServ__ContactContactRelation__c record : records) {
      personContactIds.add(record.FinServ__Contact__c);
      personContactIds.add(record.FinServ__RelatedContact__c);
    }
    for (Account personAccount : [
      SELECT id, External_Id__c, PersonContactId
      FROM Account
      WHERE PersonContactId IN :personContactIds
      WITH SECURITY_ENFORCED
    ]) {
      contactExtIdMap.put(
        personAccount.PersonContactId,
        personAccount.External_Id__c
      );
    }
    return contactExtIdMap;
  }

  /**
   * @description populates FinServ__Role__c or OCV_Role__c based on FinServ__ReciprocalRole__c table
   * @name populateRoleId
   * @param record FinServ__ContactContactRelation__c record from trigger
   */
  private static void populateRoleId(
    FinServ__ContactContactRelation__c record
  ) {
    if (
      String.isBlank(record.FinServ__Role__c) &&
      reciprocalRolesOCVRoleMap.containsKey(record.OCV_Role__c)
    ) {
      record.FinServ__Role__c = reciprocalRolesOCVRoleMap.get(
          record.OCV_Role__c
        )
        .Id;
    }
    if (reciprocalRolesIdMap.containsKey(record.FinServ__Role__c)) {
      record.OCV_Role__c = reciprocalRolesIdMap.get(record.FinServ__Role__c)
        .OCV_Role__c;
    }

    if (!reciprocalRolesOCVRoleMap.containsKey(record.OCV_Role__c)) {
      record.addError(CCRMConstants.INVALID_OCV_ROLE_ERROR_MESSAGE);
    }
  }

  /**
   * @description populates External_Id__c when salesforce automatically creates a FinServ__ContactContactRelation__c record
   * @name populateExternalId
   * @param record FinServ__ContactContactRelation__c record from trigger
   * @param contactToContactMap Existing FinServ__ContactContactRelation__c records map
   * @param contactExtIdMap person accounts map created from contact field values in FinServ__ContactContactRelation__c
   */
  private static void populateExternalId(
    FinServ__ContactContactRelation__c record,
    Map<String, FinServ__ContactContactRelation__c> contactToContactMap,
    Map<Id, String> contactExtIdMap
  ) {
    if (isValidForExternalIdUpdate(record, contactToContactMap)) {
      if (
        String.isNotBlank(
          reciprocalRolesIdMap.get(record.FinServ__Role__c)
            .FinServ__InverseRelationship__c
        )
      ) {
        setReciprocalExternalId(record, contactExtIdMap);
      } else {
        setNonReciprocalExternalId(record, contactExtIdMap);
      }
    }
  }

  /**
   * @description check if the FinServ__ContactContactRelation__c record is valid for updating External ID
   * @name isValidForExternalIdUpdate
   * @param record FinServ__ContactContactRelation__c record from trigger
   * @param contactToContactMap Existing FinServ__ContactContactRelation__c records map
   * @return Boolean
   */
  private static Boolean isValidForExternalIdUpdate(
    FinServ__ContactContactRelation__c record,
    Map<String, FinServ__ContactContactRelation__c> contactToContactMap
  ) {
    return contactToContactMap.containsKey(record.External_Id__c) &&
      contactToContactMap.get(record.External_Id__c).FinServ__Contact__c ==
      record.FinServ__RelatedContact__c &&
      contactToContactMap.get(record.External_Id__c)
        .FinServ__RelatedContact__c == record.FinServ__Contact__c &&
      reciprocalRolesIdMap.containsKey(record.FinServ__Role__c);
  }

  /**
   * @description sets External ID for reciprocal role record
   * @name setReciprocalExternalId
   * @param record FinServ__ContactContactRelation__c record from trigger
   * @param contactExtIdMap person accounts map created from contact field values in FinServ__ContactContactRelation__c
   */
  private static void setReciprocalExternalId(
    FinServ__ContactContactRelation__c record,
    Map<Id, String> contactExtIdMap
  ) {
    record.External_Id__c =
      contactExtIdMap.get(record.FinServ__RelatedContact__c) +
      '_' +
      contactExtIdMap.get(record.FinServ__Contact__c) +
      '_' +
      reciprocalRolesIdMap.get(record.FinServ__Role__c).Name;
  }

  /**
   * @description sets External ID for non reciprocal role record
   * @name setNonReciprocalExternalId
   * @param record FinServ__ContactContactRelation__c record from trigger
   * @param contactExtIdMap person accounts map created from contact field values in FinServ__ContactContactRelation__c
   */
  private static void setNonReciprocalExternalId(
    FinServ__ContactContactRelation__c record,
    Map<Id, String> contactExtIdMap
  ) {
    record.External_Id__c =
      contactExtIdMap.get(record.FinServ__Contact__c) +
      '_' +
      contactExtIdMap.get(record.FinServ__RelatedContact__c) +
      '_' +
      reciprocalRolesIdMap.get(record.FinServ__Role__c).Name;
  }
}
