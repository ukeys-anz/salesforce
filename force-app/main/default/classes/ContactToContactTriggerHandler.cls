/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2023
 * @description handler class for ContactToContactTrigger which extends Lib_TriggerHandler from the trigger framework used.
 */
public with sharing class ContactToContactTriggerHandler extends Lib_TriggerHandler {
  static String ownerIdForStaffCRs {
    get {
      if (String.isBlank(ownerIdForStaffCRs)) {
        String userName = System.Label.Broker_Staff_User_as_Owner_of_Staff_BDM_records;
        ownerIdForStaffCRs = [
          SELECT Id
          FROM User
          WHERE Name = :userName AND IsActive = TRUE
          LIMIT 1
        ]
        .Id;
      }
      return ownerIdForStaffCRs;
    }
    set;
  }
  static List<FinServ__ContactContactRelation__c> masterCRs = new List<FinServ__ContactContactRelation__c>();
  static Map<Id, FinServ__ContactContactRelation__c> brokerStaffCRs = new Map<Id, FinServ__ContactContactRelation__c>();
  static List<FinServ__ReciprocalRole__c> reciprocalRoles {
    get {
      if (reciprocalRoles == null) {
        reciprocalRoles = [
          SELECT Id, Name, FinServ__InverseRelationship__c
          FROM FinServ__ReciprocalRole__c
        ];
      }
      return reciprocalRoles;
    }
    set;
  }

  static Map<Id, String> reciprocalRoleIdAndName {
    get {
      if (reciprocalRoleIdAndName == null) {
        reciprocalRoleIdAndName = new Map<Id, String>();
      }
      for (FinServ__ReciprocalRole__c reciprocalRole : reciprocalRoles) {
        reciprocalRoleIdAndName.put(reciprocalRole.Id, reciprocalRole.Name);
      }
      return reciprocalRoleIdAndName;
    }
    set;
  }

  /** @description onBeforeInsert to handle after update trigger actions.
   */
  public override void onBeforeInsert() {
    for (
      FinServ__ContactContactRelation__c cr : (List<FinServ__ContactContactRelation__c>) records
    ) {
      if (cr.RecordTypeId != GetHelpConstants.BROKER_STAFF_RT_ID) {
        masterCRs.add(cr);
        continue;
      }
      String relatedRole = reciprocalRoleIdAndName.get(cr.FinServ__Role__c);
      if (relatedRole == 'Broker') {
        brokerStaffCRs.put(cr.Staff__c, cr);
        continue;
      }
      if (relatedRole == 'Staff - BDM') {
        if (String.isBlank(ownerIdForStaffCRs)) {
          cr.addError(System.Label.Broker_Staff_Issue_with_Valid_Owner_Id);
          continue;
        }
        cr.OwnerId = ownerIdForStaffCRs;
      }
    }
    CCRMContactToContactActions.setExternalId(masterCRs);
    updateCROwnership(brokerStaffCRs);
  }

  /**
   * @description onBeforeUpdate to handle Before update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onBeforeUpdate(Map<Id, SObject> oldMap) {
    Map<Id, FinServ__ContactContactRelation__c> brokerStaffCRs = new Map<Id, FinServ__ContactContactRelation__c>();
    for (
      FinServ__ContactContactRelation__c cr : (List<FinServ__ContactContactRelation__c>) records
    ) {
      if (cr.RecordTypeId != GetHelpConstants.BROKER_STAFF_RT_ID) {
        continue;
      }
      String relatedRole = reciprocalRoleIdAndName.get(cr.FinServ__Role__c);
      if (relatedRole != 'Broker') {
        continue;
      }
      FinServ__ContactContactRelation__c oldCR = (FinServ__ContactContactRelation__c) oldMap.get(
        cr.Id
      );
      if (oldCR.Staff__c != cr.Staff__c) {
        brokerStaffCRs.put(cr.Staff__c, cr);
      }
    }
    updateCROwnership(brokerStaffCRs);
  }

  /**
   * @description onAfterUpdate to handle After update trigger actions.
   * @param oldMap old trigger values
   */
  public override void onAfterUpdate(Map<Id, SObject> oldMap) {
    List<FinServ__ContactContactRelation__c> masterCRs = new List<FinServ__ContactContactRelation__c>();
    for (
      FinServ__ContactContactRelation__c cr : (List<FinServ__ContactContactRelation__c>) records
    ) {
      if (cr.RecordTypeId != GetHelpConstants.BROKER_STAFF_RT_ID) {
        masterCRs.add(cr);
      }
    }
    CCRMContactToContactActions.checkRelationshipStatus(masterCRs);
  }

  /**
   * @description updateContactRelationshipsOwnership to update records's ownership to make the them visible in My Broker list
   * @param brokerStaffCRs Contact Relationship records with record type as Broker-Staff
   */
  private void updateCROwnership(
    Map<Id, FinServ__ContactContactRelation__c> brokerStaffCRs
  ) {
    if (brokerStaffCRs.size() == 0) {
      return;
    }
    List<Contact> contacts = new List<Contact>(
      [SELECT Id, Lan_Id__c FROM Contact WHERE Id IN :brokerStaffCRs.keySet()]
    );
    Map<Id, String> contactsWithLanIds = new Map<Id, String>();
    for (Contact contactWithLanId : contacts) {
      contactsWithLanIds.put(contactWithLanId.Id, contactWithLanId.Lan_Id__c);
    }
    List<User> usersWithLanId = new List<User>(
      [
        SELECT Id, Lan_Id__c
        FROM User
        WHERE Lan_Id__c IN :contactsWithLanIds.values()
      ]
    );
    Map<String, Id> landIdsWithUserIds = new Map<String, Id>();
    for (User userWithLanId : usersWithLanId) {
      landIdsWithUserIds.put(userWithLanId.Lan_Id__c, userWithLanId.Id);
    }
    updateOwnership(brokerStaffCRs, contactsWithLanIds, landIdsWithUserIds);
  }

  /**
   * @description updateOwnership to find the correct user and update it as the owner of CR record.
   * @param brokerStaffCRs Contact Relationship records with record type as Broker-Staff
   * @param contactsWithLanIds Staff contacts with their respective Lan Ids
   * @param landIdsWithUserIds Lan Ids and the User Ids they below to
   */
  private void updateOwnership(
    Map<Id, FinServ__ContactContactRelation__c> brokerStaffCRs,
    Map<Id, String> contactsWithLanIds,
    Map<String, Id> landIdsWithUserIds
  ) {
    for (FinServ__ContactContactRelation__c cr : brokerStaffCRs.values()) {
      Id staffRecordId = cr.Staff__c;
      if (String.isBlank(contactsWithLanIds.get(staffRecordId))) {
        cr.addError(System.Label.Broker_Staff_No_Lan_Id_for_Staff);
        continue;
      }
      String staffLanId = contactsWithLanIds.get(staffRecordId);
      if (String.isBlank(landIdsWithUserIds.get(staffLanId))) {
        cr.addError(System.Label.Broker_Staff_No_User_for_Staff_s_Lan_Id);
        continue;
      }
      Id userId = landIdsWithUserIds.get(staffLanId);
      cr.OwnerId = userId;
    }
  }
}
