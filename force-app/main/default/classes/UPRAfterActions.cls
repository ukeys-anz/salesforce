/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description This class will be called in User Provisioning Request Trigger to update User Object based on the Request Type.
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
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
      managerMap = UserProvisioningCommonActions.getManagerRecords(
        managerUUIDs
      );
    }

    if (!uprModifyMap.isEmpty()) {
      modifyUserList = getModifyUserList(uprModifyMap, managerMap);
    }
    if (!modifyUserList.isEmpty()) {
      if (
        User.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.User.fields.Business_Function__c.isUpdateable() &&
        Schema.sObjectType.User.fields.Business_Role__c.isUpdateable() &&
        Schema.sObjectType.User.fields.ManagerId.isUpdateable()
      ) {
        List<Database.SaveResult> updateUserList = Database.update(
          modifyUserList,
          false
        );
      } else {
        CommonUtil.logAndThrowIAE(
          'UPRAfterActions',
          'modifyUserAccess',
          'Not enough permissions to update User.'
        );
      }
    }
  }

  /**
   * @description Method to identify users to update their Business Function, Business Role and Manager id based on UPR request
   * @param uprModifyMap User Provisioning Request Map
   * @param managerMap manager user map
   * @return 'List<User>'
   */
  private static List<User> getModifyUserList(
    Map<String, User_Provisioning_Request__c> uprModifyMap,
    Map<String, String> managerMap
  ) {
    String uprBusinessFunction;
    String uprBusinessRole;
    String uprManagerUUID;

    List<User> modifyUserList = new List<User>();
    if (Schema.sObjectType.User.isQueryable()) {
      modifyUserList = [
        SELECT
          Id,
          Business_Function__c,
          Business_Role__c,
          FederationIdentifier,
          ManagerId
        FROM User
        WHERE FederationIdentifier IN :uprModifyMap.keySet() AND isActive = TRUE
      ];
    }

    for (User usr : modifyUserList) {
      uprBusinessFunction = uprModifyMap.get(usr.FederationIdentifier)
        .Business_Function__c;
      uprBusinessRole = uprModifyMap.get(usr.FederationIdentifier)
        .Business_Role__c;
      uprManagerUUID = uprModifyMap.get(usr.FederationIdentifier)
        .Manager_UUID__c;
      if (usr.Business_Function__c != uprBusinessFunction) {
        usr.Business_Function__c = uprBusinessFunction;
      }
      if (usr.Business_Role__c != uprBusinessRole) {
        usr.Business_Role__c = uprBusinessRole;
      }
      if (managerMap.containskey(uprManagerUUID)) {
        if (usr.ManagerId != managerMap.get(uprManagerUUID)) {
          usr.ManagerId = managerMap.get(uprManagerUUID);
        }
      }
    }
    return modifyUserList;
  }

  /**
   * @description This function is called to identify and deactivate users for Revoke User Provisioning Requests.
   * Used as a future method to avoid Mixed_DML_Operation error
   * @param uprRevokeIds Set of Requestor UUIDs from UPR request
   */
  @future
  public static void revokeUserAccess(Set<String> uprRevokeIds) {
    List<User> userList = new List<user>();

    if (Schema.sObjectType.User.isQueryable()) {
      userList = [
        SELECT isActive
        FROM User
        WHERE FederationIdentifier IN :uprRevokeIds AND isActive = TRUE
      ];
    }

    for (User usr : userList) {
      usr.IsActive = false;
    }

    if (!userList.isEmpty()) {
      if (
        User.sObjectType.getDescribe().isUpdateable() &&
        Schema.sObjectType.User.fields.IsActive.isUpdateable()
      ) {
        List<Database.SaveResult> updateUserList = Database.update(
          userList,
          false
        );
      } else {
        CommonUtil.logAndThrowIAE(
          'UPRAfterActions',
          'revokeUserAccess',
          'Not enough permissions to update User.'
        );
      }
    }
  }
}
