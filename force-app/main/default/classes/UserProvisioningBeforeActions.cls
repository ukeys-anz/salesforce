/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description UserProvisioningBeforeActions class is called in UserTriggerHandler to assign Profile, Role automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 */
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class UserProvisioningBeforeActions {
  /**
   * @description This method is called in OnBeforeInsert to check if there is a User provisioning request record created by Service Now with Approved status.
   * @param records List of user records from trigger
   * @param federationIds Set of Federation ID's from user records
   */
  public static void checkUserProvisioingRequest(
    List<User> records,
    Set<String> federationIds
  ) {
    Set<String> managerUUIDs = new Set<String>();

    Map<String, String> managerMap = new Map<String, String>();

    Map<String, User_Provisioning_Request__c> uprMap = getUPRRecords(
      federationIds
    );

    for (User_Provisioning_Request__c upr : uprMap.values()) {
      if (String.isNotBlank(upr.Manager_UUID__c)) {
        managerUUIDs.add(upr.Manager_UUID__c);
      }
    }

    if (!managerUUIDs.isEmpty()) {
      managerMap = UserProvisioningCommonActions.getManagerRecords(
        managerUUIDs
      );
    }
    if (!uprMap.isEmpty()) {
      for (User record : (List<User>) records) {
        assignBusiFuncToRecord(record, uprMap, managerMap);
      }
    }
  }
  /**
   * @description This method is called to get the User provisioning request records and manager UUIDs.
   * @param federationIds Set of Federation ID's from user records
   * @return `Map<String, User_Provisioning_Request__c>` User Provisiong request records map
   */
  public static Map<String, User_Provisioning_Request__c> getUPRRecords(
    Set<String> federationIds
  ) {
    Map<String, User_Provisioning_Request__c> uprMap = new Map<String, User_Provisioning_Request__c>();

    for (User_Provisioning_Request__c uprRecord : [
      SELECT
        Id,
        Business_Function__c,
        Business_Role__c,
        Requestor_UUID__c,
        Manager_UUID__c,
        Status__c,
        Requestor__c
      FROM User_Provisioning_Request__c
      WHERE Requestor_UUID__c IN :federationIds AND Status__c = 'New'
      ORDER BY CreatedDate ASC
    ]) {
      uprMap.put((uprRecord.Requestor_UUID__c), uprRecord);
    }
    return uprMap;
  }

  /**
   * @description This method is called to get manager user records using manager UUID from UPR record.
   * @param record User record from trigger
   * @param uprMap User Provisiong request records map
   * @param managerMap combination of manager's Federation id and user id
   */

  private static void assignBusiFuncToRecord(
    User record,
    Map<String, User_Provisioning_Request__c> uprMap,
    Map<String, String> managerMap
  ) {
    if (uprMap.containskey(record.FederationIdentifier)) {
      record.Business_Function__c = uprMap.get(record.FederationIdentifier)
        .Business_Function__c;
      record.Business_Role__c = uprMap.get(record.FederationIdentifier)
        .Business_Role__c;
      if (
        managerMap.containskey(
          uprMap.get(record.FederationIdentifier).Manager_UUID__c
        )
      ) {
        record.ManagerId = managerMap.get(
          uprMap.get(record.FederationIdentifier).Manager_UUID__c
        );
      }
    }
  }

  /**
   * @description This method is called in OnBeforeInsert & OnBeforeUpdate to assign Profile and Role to user record.
   * Profileid and UserRoleId are identified from User_Provisioning_Setting__mdt object based on the combination of Business Function and Business Role from user object.
   * @param records List of user records from trigger
   * @param businessFuncAndRoles Set of Business Function and Roles key values combinations from trigger
   */
  public static void assignProfileAndRole(
    List<User> records,
    Set<String> businessFuncAndRoles
  ) {
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = UserProvisioningCommonActions.getBusinesFunctionAndRoles(
      businessFuncAndRoles
    );

    if (!businessFunctionMap.isEmpty()) {
      Map<String, Profile> profileMap = UserProvisioningCommonActions.getAllProfileMap();
      Map<String, UserRole> userRoleMap = UserProvisioningCommonActions.getAllUserRoleMap();
      Map<String, CallCenter> callCenterMap = UserProvisioningCommonActions.getAllCallCenterMap();

      for (User record : (List<User>) records) {
        if (UserProvisioningCommonActions.isValidRecordForProcessing(record)) {
          assignProfileToRecord(record, businessFunctionMap, profileMap);
          assignRoleToRecord(record, businessFunctionMap, userRoleMap);
          assignCallCenterToRecord(record, businessFunctionMap, callCenterMap);
        }
      }
    }
  }

  /**
   * @description This method is used to assign profile to users by fetching the profile name from Custom metadata based on user Business Function and Role.
   * @param record user record from trigger
   * @param businessFunctionMap Business Function Map from Custom metadata
   * @param profileMap Profile Map with profile name as a key
   */

  private static void assignProfileToRecord(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, Profile> profileMap
  ) {
    String profileName;
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      profileName = businessFunctionMap.get(businessFunctionRoleKey)
        .Profile_Name__c;
    }
    if (profileMap.containskey(profileName)) {
      record.ProfileId = profileMap.get(profileName).Id;
    }
  }

  /**
   * @description This method is used to assign role to users by fetching the role name from Custom metadata based on user Business Function and Role.
   * @param record user record from trigger
   * @param businessFunctionMap Business Function Map from Custom metadata
   * @param userRoleMap UserRole Map with Role name as a key
   */

  private static void assignRoleToRecord(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, UserRole> userRoleMap
  ) {
    String roleName;
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      roleName = businessFunctionMap.get(businessFunctionRoleKey).Role_Name__c;
    }
    if (userRoleMap.containskey(roleName)) {
      record.UserRoleId = userRoleMap.get(roleName).Id;
    }
  }

  /**
   * @description This method is used to assign call center to users by fetching the call center name from Custom metadata based on user Business Function and Role.
   * @param record user record from trigger
   * @param businessFunctionMap Business Function Map from Custom metadata
   * @param callCenterMap CallCenter Map with InternalName as a key
   */
  private static void assignCallCenterToRecord(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, CallCenter> callCenterMap
  ) {
    String callCenterName;
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      callCenterName = businessFunctionMap.get(businessFunctionRoleKey)
        .Call_Center_Name__c;
    }
    if (String.isBlank(callCenterName)) {
      record.CallCenterId = null;
    } else if (callCenterMap.containskey(callCenterName)) {
      record.CallCenterId = callCenterMap.get(callCenterName).Id;
    }
  }
}
