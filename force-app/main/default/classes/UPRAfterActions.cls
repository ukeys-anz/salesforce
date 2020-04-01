/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description This class will be called in User Provisioning Request Trigger to update User Object based on the Request Type.
 */
public with sharing class UPRAfterActions {
  /**
   * @description This function is called to update User object with Business Function, Business Role and Manager id for Modify Request type. 
   * Used as a future method to avoid Mixed_DML_Operation error 
   * @param uprModifyList List of JSON serialized User provisioning records from trigger
   */
  @future
  public static void modifyUserAccess(List<String> uprModifyList) {
    List<User_Provisioning_Request__c> uprRecords = new List<User_Provisioning_Request__c>();

    Map<String, User_Provisioning_Request__c> uprModifyMap = new Map<String, User_Provisioning_Request__c>();

    List<User> modifyUserList = new List<user>();

    Set<String> managerUUIDs = new Set<String>();

    Map<String, String> managerMap = new Map<String, String>();

    if (!uprModifyList.isEmpty()) {
      for (String uprRecord : uprModifyList) {
        uprRecords.add(
          (User_Provisioning_Request__c) JSON.deserialize(
            uprRecord,
            User_Provisioning_Request__c.class
          )
        );
      }
    }

    if (!uprRecords.isEmpty()) {
      for (User_Provisioning_Request__c upr : uprRecords) {
        uprModifyMap.put(upr.Requestor_UUID__c, upr);
        if (String.isNotBlank(upr.Manager_UUID__c)) {
          managerUUIDs.add(upr.Manager_UUID__c);
        }
      }
    }

    if (!managerUUIDs.isEmpty()) {
      managerMap = getManagerUsers(managerUUIDs);
    }

    if (!uprModifyMap.isEmpty()) {
      modifyUserList = getModifyUserList(uprModifyMap, managerMap);
    }
    if (!modifyUserList.isEmpty()) {
      List<Database.SaveResult> updateUserList = Database.update(
        modifyUserList,
        false
      );
    }
  }

  /**
   * @description Method to get manager user id by passing manager UUID from User provisioning request
   * @param managerUUIDs from User provisioning request
   * @return 'Map<String, String>'
   */
  private static Map<String, String> getManagerUsers(Set<String> managerUUIDs) {
    Map<String, String> managerMap = new Map<String, String>();

    for (User managerUser : [
      SELECT Id, FederationIdentifier
      FROM User
      WHERE FederationIdentifier IN :managerUUIDs AND isActive = true
    ]) {
      managerMap.put(managerUser.FederationIdentifier, managerUser.Id);
    }
    return managerMap;
  }

  /**
   * @description Method to identify users to update their Business Function, Business Role and Manager id based on UPR request
   * @param uprModifyMap User Provisioning Request Map
   * @param managerMap manager user map
   * @return 'List<User>'
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private static List<User> getModifyUserList(
    Map<String, User_Provisioning_Request__c> uprModifyMap,
    Map<String, String> managerMap
  ) {
    List<User> modifyUserList = new List<User>();

    modifyUserList = [
      SELECT Id, Business_Function__c, Business_Role__c, FederationIdentifier
      FROM User
      WHERE FederationIdentifier IN :uprModifyMap.keySet() AND isActive = true
    ];

    for (User usr : modifyUserList) {
      usr.Business_Function__c = uprModifyMap.get(usr.FederationIdentifier)
        .Business_Function__c;
      usr.Business_Role__c = uprModifyMap.get(usr.FederationIdentifier)
        .Business_Role__c;
      if (
        managerMap.containskey(
          uprModifyMap.get(usr.FederationIdentifier).Manager_UUID__c
        )
      ) {
        usr.ManagerId = managerMap.get(
          uprModifyMap.get(usr.FederationIdentifier).Manager_UUID__c
        );
      }
    }
    return modifyUserList;
  }

  /**
   * @description This function is called to identify and deactivate users for Revoke User Provisioning Requests.
   * Used as a future method to avoid Mixed_DML_Operation error 
   * @param uprRevokeIds Set of Requestor UUIDs from UPR request
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  @future
  public static void revokeUserAccess(Set<String> uprRevokeIds) {
    List<User> revokeUserList = new List<user>();

    if (!uprRevokeIds.isEmpty()) {
      List<User> userList = [
        SELECT Id, Business_Function__c, Business_Role__c, FederationIdentifier
        FROM User
        WHERE FederationIdentifier IN :uprRevokeIds AND isActive = true
      ];

      for (User usr : userList) {
        usr.IsActive = false;
        revokeUserList.add(usr);
      }
    }
    if (!revokeUserList.isEmpty()) {
      List<Database.SaveResult> updateUserList = Database.update(
        revokeUserList,
        false
      );
    }
  }
}
