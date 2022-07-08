/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description UserProvisioningBeforeActions class is called in UserTriggerHandler to assign Profile, Role automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 */
public with sharing class UserProvisioningBeforeActions {
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
