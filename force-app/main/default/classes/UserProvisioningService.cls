/**
 * @author Boobalakrishnan Duraisamy
 * @since  02/2020
 * @description UserProvisioningService class is called in UserTriggerHandler to assign Profile, Role, Permission set, Permission Set Group
 * and Public group automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class UserProvisioningService {
  /**
   * @description This function is to check if the user business function and business role is not empty.
   * @param record User record from trigger
   * @return `Boolean` True if the User business function and role is not empty. Otherwise return false.
   */
  public static Boolean isValidRecordForProcessing(User record) {
    if (
      String.isNotBlank(record.Business_Function__c) &&
      String.isNotBlank(record.Business_Role__c) &&
      record.IsActive == true
    ) {
      return true;
    } else {
      return false;
    }
  }

  /**
   * @description This function returns true if user business function and role is changed.
   * @param record User record from trigger
   * @param oldRecord User old record from trigger
   * @return `Boolean` True if current record business function and role are not matches old record business function and role.
   */
  public static Boolean isValidRecordForUpdate(User record, User oldRecord) {
    if (
      (record.Business_Function__c != oldRecord.Business_Function__c) ||
      (record.Business_Role__c != oldRecord.Business_Role__c)
    ) {
      return true;
    } else {
      return false;
    }
  }
  /**
   * @description This method is used to generate Business Function and Role key which will be used as a key in Custom Metadata.
   * @param record User record from trigger
   * @return `String` True if the the record type is of IDR type false otherwise.
   */
  public static String generateKey(User record) {
    String businessFunctionKey =
      record.Business_Function__c.trim().replaceAll(' ', '_') +
      '_' +
      record.Business_Role__c.trim().replaceAll(' ', '_');

    return businessFunctionKey;
  }

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

    Map<String, User_Provisioning_Request__c> uprMap = getUPRRecords(federationIds);

    for (User_Provisioning_Request__c upr : uprMap.values()) {
      if (String.isNotBlank(upr.Manager_UUID__c)) {
        managerUUIDs.add(upr.Manager_UUID__c);
      }
    }

    if (!managerUUIDs.isEmpty()) {
      managerMap = getManagerRecords(managerUUIDs);
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
  private static Map<String, User_Provisioning_Request__c> getUPRRecords(
    Set<String> federationIds
  ) {
    Map<String, User_Provisioning_Request__c> uprMap = new Map<String, User_Provisioning_Request__c>();

    for (User_Provisioning_Request__c uprRecord : [
      SELECT
        Id,
        Business_Function__c,
        Business_Role__c,
        Requestor_UUID__c,
        Manager_UUID__c
      FROM User_Provisioning_Request__c
      WHERE Requestor_UUID__c IN :federationIds AND Type__c = 'Grant'
    ]) {
      uprMap.put((uprRecord.Requestor_UUID__c), uprRecord);
    }
    return uprMap;
  }

  /**
   * @description This method is called to get manager user records using manager UUID from UPR record.
   * @param managerUUIDs manager UUIDs from User Provisioning Request record
   * @return `Map<String, String>` returns combination of manager's Federation id and user id
   */

  private static Map<String, String> getManagerRecords(
    Set<String> managerUUIDs
  ) {
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

    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = getBusinesFunctionAndRoles(businessFuncAndRoles);

    if (!businessFunctionMap.isEmpty()) {
      Map<String, Profile> profileMap  = getAllProfileMap();
      Map<String, UserRole> userRoleMap = getAllUserRoleMap();

      for (User record : (List<User>) records) {
        if (isValidRecordForProcessing(record)) {
          assignProfileToRecord(record, businessFunctionMap, profileMap);
          assignRoleToRecord(record, businessFunctionMap, userRoleMap);
        }
      }
    }
  }

  /**
   * @description This method is called to get user permission API names from User Provisioning Setting Metadata based on Business function and role key from user record.
   * @param businessFuncAndRoles Set of Business Function and Roles key values combinations from trigger
   * @return `Map<String, User_Provisioning_Setting__mdt>` returns User Provisioning Setting list with DevloperName as a key
   */

  private static Map<String, User_Provisioning_Setting__mdt> getBusinesFunctionAndRoles(
    Set<String> businessFuncAndRoles
  ) {
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = new Map<String, User_Provisioning_Setting__mdt>();

    for (User_Provisioning_Setting__mdt businessFunction : [
      SELECT
        Id,
        Label,
        DeveloperName,
        Profile_Name__c,
        Role_Name__c,
        Permission_Sets__c,
        Permission_Set_Groups__c,
        Public_Groups__c
      FROM User_Provisioning_Setting__mdt
      WHERE DeveloperName IN :BusinessFuncAndRoles
    ]) {
      businessFunctionMap.put(
        (businessFunction.DeveloperName),
        businessFunction
      );
    }
    return businessFunctionMap;
  }

  /**
   * @description This method is called to get all profile names and their profile ids.
   * @return `Map<String, Profile>`
   */

  private static Map<String, Profile> getAllProfileMap() {
    Map<String, Profile> profileMap = new Map<String, Profile>();

    for (Profile prof : [SELECT Id, Name FROM Profile]) {
      profileMap.put(prof.Name, prof);
    }
    return profileMap;
  }

  /**
   * @description This method is called to get all userrole names and their ids.
   * @return `Map<String, UserRole>`
   */

  private static Map<String, UserRole> getAllUserRoleMap() {
    Map<String, UserRole> userRoleMap = new Map<String, UserRole>();

    for (UserRole uRole : [SELECT Id, DeveloperName FROM UserRole]) {
      userRoleMap.put(uRole.DeveloperName, uRole);
    }
    return userRoleMap;
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
    String businessFunctionRoleKey = generateKey(record);
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
    String businessFunctionRoleKey = generateKey(record);
    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      roleName = businessFunctionMap.get(businessFunctionRoleKey).Role_Name__c;
    }
    if (userRoleMap.containskey(roleName)) {
      record.UserRoleId = userRoleMap.get(roleName).Id;
    }
  }

  /**
   * @description This method is called in OnAfterInsert & OnAfterUpdate to assign Permission sets, Permission set groups and public groups to user record.
   * Permission set name, Permission set group name and Public group names are identified from User_Provisioning_Setting__mdt object based on the combination of Business Function and Business Role from user object.
   * @param records List of user records from trigger
   * @param businessFuncAndRoles Set of Business Function and Roles key values combinations from trigger
   */

  public static void assignMembership(
    List<User> records,
    Set<String> businessFuncAndRoles
  ) {

    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();

    List<GroupMember> groupMemberList = new List<GroupMember>();

    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = getBusinesFunctionAndRoles(businessFuncAndRoles);

    if (!businessFunctionMap.isEmpty()) {
      Map<String, PermissionSet> pSetMap = getAllPSetMap();
      Map<String, PermissionSetGroup> pSetGroupMap = getAllPsetGroupMap();
      Map<String, Group> publicGroupMap = getAllPublicGroupMap();

      for (User record : records) {
        psetAssignmentList.addAll(assignPermissionSet(
          record,
          businessFunctionMap,
          pSetMap
        ));
        psetAssignmentList.addAll(assignPermissionSetGroup(
          record,
          businessFunctionMap,
          pSetGroupMap
        ));
        groupMemberList.addAll(assignPublicGroup(
          record,
          businessFunctionMap,
          publicGroupMap
        ));
      }
    }

    //no logic written to check if the user is already having that membership, Database.insert(list,false) is used to handle those records.
    if (!psetAssignmentList.isEmpty()) {
      List<Database.SaveResult> psetAssingment = Database.insert(
        psetAssignmentList,
        false
      );
      system.debug(
        System.LoggingLevel.INFO,
        'Permission Set Assignments Save Results:' + psetAssingment
      );
    }
    if (!groupMemberList.isEmpty()) {
      List<Database.SaveResult> publicGroup = Database.insert(
        groupMemberList,
        false
      );
      system.debug(
        System.LoggingLevel.INFO,
        'Public Group Assignments Save Results:' + publicGroup
      );
    }
  }

  /**
   * @description This method is called to get all permission set names and their ids.
   * @return `Map<String, PermissionSet>`
   */

  private static Map<String, PermissionSet> getAllPSetMap() {
    Map<String, PermissionSet> pSetMap = new Map<String, PermissionSet>();

    for (PermissionSet pSet : [SELECT Id, Name FROM PermissionSet]) {
      pSetMap.put(pSet.Name, pSet);
    }
    return pSetMap;
  }

  /**
   * @description This method is called to get all permission set group names and their ids.
   * @return `Map<String, PermissionSetGroup>`
   */

  private static Map<String, PermissionSetGroup> getAllPsetGroupMap() {
    Map<String, PermissionSetGroup> pSetGroupMap = new Map<String, PermissionSetGroup>();

    for (PermissionSetGroup pSetGroup : [
      SELECT Id, DeveloperName
      FROM PermissionSetGroup
    ]) {
      pSetGroupMap.put(pSetGroup.DeveloperName, pSetGroup);
    }
    return pSetGroupMap;
  }

  /**
   * @description This method is called to get all Group names and their ids.
   * @return `Map<String, Group>`
   */

  private static Map<String, Group> getAllPublicGroupMap() {
    Map<String, Group> publicGroupMap = new Map<String, Group>();

    for (Group publicGroup : [
      SELECT Id, DeveloperName
      FROM Group
      WHERE Type = 'Regular'
    ]) {
      publicGroupMap.put(publicGroup.DeveloperName, publicGroup);
    }
    return publicGroupMap;
  }

  /**
   * @description This method is called in assignMembership to assign Permission sets to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @param pSetMap Permission Set Map with permission set name as a key
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSet(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, PermissionSet> pSetMap
  ) {
    String businessFunctionRoleKey = generateKey(record);
    String pSetNames;
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();

    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      pSetNames = businessFunctionMap.get(businessFunctionRoleKey)
        .Permission_sets__c;
    }

    if (String.isNotBlank(pSetNames)) {
      List<String> pSetList = pSetNames.deleteWhitespace().split(';');
      for (String pSetName : pSetList) {
        PermissionSetAssignment assignPset = new PermissionSetAssignment();
        assignPset.AssigneeId = record.id;
        if (pSetMap.containskey(PsetName)) {
          assignPset.PermissionSetId = pSetMap.get(pSetName).Id;
          psetAssignmentList.add(assignPset);
        }
      }
    }
    return psetAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Permission set groups to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @param pSetGroupMap Permission Set Group Map with permission set group name as a key
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSetGroup(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, PermissionSetGroup> pSetGroupMap
  ) {
    String businessFunctionRoleKey = generateKey(record);
    String pSetGroupNames;
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();

    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      pSetGroupNames = businessFunctionMap.get(businessFunctionRoleKey)
        .Permission_Set_Groups__c;
    }
    if (String.isNotBlank(pSetGroupNames)) {
      List<String> pSetGroupList = pSetGroupNames.deleteWhitespace().split(';');
      for (String pSetGroupName : pSetGroupList) {
        PermissionSetAssignment assignPset = new PermissionSetAssignment();
        assignPset.AssigneeId = record.id;
        if (pSetGroupMap.containskey(pSetGroupName)) {
          assignPset.PermissionSetGroupId = pSetGroupMap.get(pSetGroupName).Id;
          psetAssignmentList.add(assignPset);
        }
      }
    }
    return psetAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Public Groups to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @param publicGroupMap Public Group Map with group name as a key
   * @return `List<GroupMember>` List of group member for insert
   */
  private static List<GroupMember> assignPublicGroup(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, Group> publicGroupMap
  ) {
    String businessFunctionRoleKey = generateKey(record);
    String groupNames;
    List<GroupMember> groupMemberList = new List<GroupMember>();

    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      groupNames = businessFunctionMap.get(businessFunctionRoleKey)
        .Public_Groups__c;
    }
    if (String.isNotBlank(groupNames)) {
      List<String> groupList = groupNames.deleteWhitespace().split(';');
      for (String groupName : groupList) {
        GroupMember assignGroup = new GroupMember();
        assignGroup.UserOrGroupId = record.id;
        if (publicGroupMap.containskey(groupName)) {
          assignGroup.GroupId = publicGroupMap.get(groupName).Id;
          groupMemberList.add(assignGroup);
        }
      }
    }
    return groupMemberList;
  }

  /**
   * @description This method is called in OnAfterUpdate to revoke Permission sets, Permission set groups and public groups which were previously assigned.
   * @param userIds List of user ids from trigger
   * @param oldBusinessFuncAndRoles Set of old Business Function and Roles key values combinations from trigger
   */
  public static void revokeMembership(
    List<Id> userIds,
    Set<String> oldBusinessFuncAndRoles
  ) {

    List<PermissionSetAssignment> deletePsetList = new List<PermissionSetAssignment>();

    List<GroupMember> deleteGroupMemberList = new List<GroupMember>();

    Set<String> pSets = new Set<String>();

    Set<String> pGroups = new Set<String>();

    List<User_Provisioning_Setting__mdt> businessFunctionList = getOldRecordBusinessFunctions(
      oldBusinessFuncAndRoles
    );

    for (
      User_Provisioning_Setting__mdt businessFunction : businessFunctionList
    ) {
      if (String.isNotBlank(businessFunction.Permission_Sets__c)) {
        pSets.addAll(
          businessFunction.Permission_Sets__c.deleteWhitespace().split(';')
        );
      }
      if (String.isNotBlank(businessFunction.Permission_Set_Groups__c)) {
        pSets.addAll(
          businessFunction.Permission_Set_Groups__c.deleteWhitespace()
            .split(';')
        );
      }
      if (String.isNotBlank(businessFunction.Public_Groups__c)) {
        pGroups.addAll(
          businessFunction.Public_Groups__c.deleteWhitespace().split(';')
        );
      }
    }

    deletePsetList = getDeletePSetAssignmentList(userIds, pSets);

    deleteGroupMemberList = getDeleteGroupMemberList(userIds, pGroups);

    if (!deletePsetList.isEmpty()) {
      List<Database.DeleteResult> deleteResult = Database.delete(
        deletePsetList,
        false
      );
      system.debug(
        System.LoggingLevel.INFO,
        'Permission Set Assignments Delete Results:' + deleteResult
      );
    }

    if (!deleteGroupMemberList.isEmpty()) {
      List<Database.DeleteResult> deleteResult = Database.delete(
        deleteGroupMemberList,
        false
      );
      system.debug(
        System.LoggingLevel.INFO,
        'Group Member Delete Results:' + deleteResult
      );
    }
  }

  /**
   * @description This method is used to get Permission Set, Permission Set Group and Public Group name list based on users Business Function and Role.
   * @param oldBusinessFuncAndRoles Set of old Business Function and Roles key values combinations from trigger
   * @return `List<User_Provisioning_Setting__mdt>` return business function mapping of old user record
   */
  @SuppressWarnings('PMD.ApexCRUDViolation')
  private static List<User_Provisioning_Setting__mdt> getOldRecordBusinessFunctions(
    Set<String> oldBusinessFuncAndRoles
  ) {
    List<User_Provisioning_Setting__mdt> businessFunctionList = New List<User_Provisioning_Setting__mdt>(); 
    businessFunctionList = [
      SELECT
        Id,
        Label,
        DeveloperName,
        Profile_Name__c,
        Role_Name__c,
        Permission_Sets__c,
        Permission_Set_Groups__c,
        Public_Groups__c
      FROM User_Provisioning_Setting__mdt
      WHERE DeveloperName IN :oldBusinessFuncAndRoles
    ];
    return businessFunctionList;
  }

  /**
   * @description This method is used to populate permission set assignment list of old business function and role.
   * @param userIds list of user ids from user trigger
   * @param pSets Set of permission set and permission set group names
   * @return `List<PermissionSetAssignment>`
   */

  private static List<PermissionSetAssignment> getDeletePSetAssignmentList(
    List<Id> userIds,
    Set<String> pSets
  ) {
    List<PermissionSetAssignment> deletePsetList = new List<PermissionSetAssignment>();

    for (PermissionSetAssignment pSetAssignment : [
      SELECT id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId IN :userIds
    ]) {
      if (pSets.contains(pSetAssignment.PermissionSet.Name)) {
        deletePsetList.add(pSetAssignment);
      }
    }
    return deletePsetList;
  }

  /**
   * @description This method is used to populate group member list of old business function and role.
   * @param userIds list of user ids from user trigger
   * @param pGroups Set of public group names
   * @return `List<GroupMember>`
   */

  private static List<GroupMember> getDeleteGroupMemberList(
    List<Id> userIds,
    Set<String> pGroups
  ) {
    List<GroupMember> deleteGroupMemberList = new List<GroupMember>();

    for (GroupMember publicGroupMember : [
      SELECT id, Group.DeveloperName
      FROM GroupMember
      WHERE UserOrGroupId IN :userIds
    ]) {
      if (pGroups.contains(publicGroupMember.Group.DeveloperName)) {
        deleteGroupMemberList.add(publicGroupMember);
      }
    }
    return deleteGroupMemberList;
  }
}