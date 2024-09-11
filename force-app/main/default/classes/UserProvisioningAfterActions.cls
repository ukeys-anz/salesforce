/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description UserProvisioningAfterActions class is called in UserTriggerHandler to assign Permission set, Permission Set Group
 * and Public group automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class UserProvisioningAfterActions {
  private static Set<Id> failedRecordIds = new Set<Id>();

  private static final UserProvisioningActionsRepository USER_REPOSITORY = (UserProvisioningActionsRepository) Lib_InstanceProvider.forType(
    UserProvisioningActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static Id anzProfile = CommonUtil.getProfileByName(
      'ANZ Standard User'
    )
    .Id;

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
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
    List<GroupMember> groupMemberList = new List<GroupMember>();
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap = UserProvisioningCommonActions.getBusinesFunctionAndRoles(
      businessFuncAndRoles
    );

    if (businessFunctionMap.isEmpty()) {
      return;
    }

    Map<String, PermissionSetLicense> pSetLicenseMap = UserProvisioningCommonActions.getAllPSetLicenseMap();

    for (User record : records) {
      psetLicenseAssignmentList.addAll(
        assignPermissionSetLicences(record, businessFunctionMap, pSetLicenseMap)
      );
      psetAssignmentList.addAll(
        assignPermissionSet(record, businessFunctionMap)
      );
      psetAssignmentList.addAll(
        assignPermissionSetGroup(record, businessFunctionMap)
      );
      groupMemberList.addAll(assignPublicGroup(record, businessFunctionMap));
    }

    if (!psetLicenseAssignmentList.isEmpty()) {
      insertPsetLicenseAssign(psetLicenseAssignmentList);
    }
    if (!psetAssignmentList.isEmpty()) {
      insertPsetAssignment(psetAssignmentList);
    }
    if (!groupMemberList.isEmpty()) {
      insertGroupAssignment(groupMemberList);
    }
  }

  /**
   * @description This method is called in assignMembership to assign Permission sets to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSet(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap
  ) {
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
    if (businessFunctionMap.containskey(businessFunctionRoleKey) == false) {
      return new List<PermissionSetAssignment>();
    }
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();
    List<String> pSetList = businessFunctionMap.get(businessFunctionRoleKey)
      .Permission_sets__c.deleteWhitespace()
      .split(';');
    for (String pSetName : pSetList) {
      PermissionSetAssignment assignPset = new PermissionSetAssignment();
      assignPset.AssigneeId = record.id;
      if (QueryPS.get(PsetName) != null) {
        assignPset.PermissionSetId = QueryPS.get(pSetName).Id;
        psetAssignmentList.add(assignPset);
      }
    }

    return psetAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Permission set groups to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations

   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSetGroup(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap
  ) {
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );

    if (businessFunctionMap.containskey(businessFunctionRoleKey) == false) {
      return new List<PermissionSetAssignment>();
    }
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();
    List<String> pSetGroupList = businessFunctionMap.get(
        businessFunctionRoleKey
      )
      .Permission_Set_Groups__c.deleteWhitespace()
      .split(';');
    for (String pSetGroupName : pSetGroupList) {
      PermissionSetAssignment assignPset = new PermissionSetAssignment();
      assignPset.AssigneeId = record.id;
      if (QueryPSG.get(pSetGroupName) != null) {
        assignPset.PermissionSetGroupId = QueryPSG.get(pSetGroupName).Id;
        psetAssignmentList.add(assignPset);
      }
    }

    return psetAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Permission set licences to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @param pSetLicenseMap Permission Set License Map with permission set licence name as a key
   * @return `List<PermissionSetLicenseAssign>` List of permission set license assignment for insert
   */
  private static List<PermissionSetLicenseAssign> assignPermissionSetLicences(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, PermissionSetLicense> pSetLicenseMap
  ) {
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );

    if (businessFunctionMap.containskey(businessFunctionRoleKey) == false) {
      return new List<PermissionSetLicenseAssign>();
    }

    List<PermissionSetLicenseAssign> psetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
    List<String> pSetLicenseList = businessFunctionMap.get(
        businessFunctionRoleKey
      )
      .Permission_Set_Licences__c.deleteWhitespace()
      .split(';');

    for (String pSetLicenseName : pSetLicenseList) {
      PermissionSetLicenseAssign assignPsetLicense = new PermissionSetLicenseAssign();
      assignPsetLicense.AssigneeId = record.id;
      if (pSetLicenseMap.containskey(pSetLicenseName)) {
        assignPsetLicense.PermissionSetLicenseId = pSetLicenseMap.get(
            pSetLicenseName
          )
          .Id;
        psetLicenseAssignmentList.add(assignPsetLicense);
      }
    }

    return psetLicenseAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Public Groups to user record.
   * @param record User record from trigger
   * @param businessFunctionMap Business Function and Role combinations
   * @return `List<GroupMember>` List of group member for insert
   */
  private static List<GroupMember> assignPublicGroup(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap
  ) {
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );

    if (businessFunctionMap.containskey(businessFunctionRoleKey) == false) {
      return new List<GroupMember>();
    }
    List<GroupMember> groupMemberList = new List<GroupMember>();
    List<String> groupList = businessFunctionMap.get(businessFunctionRoleKey)
      .Public_Groups__c.deleteWhitespace()
      .split(';');
    for (String groupName : groupList) {
      GroupMember assignGroup = new GroupMember();
      assignGroup.UserOrGroupId = record.id;
      assignGroup.GroupId = QueryPublicGroup.get(groupName).Id;
      groupMemberList.add(assignGroup);
    }

    return groupMemberList;
  }

  /**
   * @description This method is called in assignMembership to insert Permission Set License Assignments to user record.
   * @param psetLicenseAssignmentList Permission Set License Assignment List
   */
  private static void insertPsetLicenseAssign(
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList
  ) {
    if (
      PermissionSetLicenseAssign.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.PermissionSetLicenseAssign.fields.AssigneeId.isCreateable() &&
      Schema.sObjectType.PermissionSetLicenseAssign.fields.PermissionSetLicenseId.isCreateable()
    ) {
      //no logic written to check if the user is already having that membership, Database.insert(list,false) is used to handle those records.
      List<Database.SaveResult> results = Database.insert(
        psetLicenseAssignmentList,
        false
      );

      for (Integer i = 0; i < psetLicenseAssignmentList.size(); i++) {
        Database.SaveResult sr = results[i];
        PermissionSetLicenseAssign rec = psetLicenseAssignmentList[i];

        if (sr.isSuccess()) {
          continue;
        }

        for (Database.Error err : sr.getErrors()) {
          if (String.valueOf(err.getStatusCode()) == 'DUPLICATE_VALUE') {
            continue;
          }
          failedRecordIds.add(rec.AssigneeId);
          logError(rec.AssigneeId, err);
        }
        Logger.saveLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'UserProvisioningAfterActions',
        'insertPsetLicenseAssign',
        'Not enough permissions to create PermissionSetLicenseAssign.'
      );
    }
  }

  /**
   * @description This method is called in assignMembership to insert Permission Set Assignments to user record.
   * @param psetAssignmentList Permission Set Assignment List
   */
  private static void insertPsetAssignment(
    List<PermissionSetAssignment> psetAssignmentList
  ) {
    if (
      PermissionSetAssignment.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetGroupId.isCreateable() &&
      Schema.sObjectType.PermissionSetAssignment.fields.AssigneeId.isCreateable() &&
      Schema.sObjectType.PermissionSetAssignment.fields.PermissionSetId.isCreateable()
    ) {
      //no logic written to check if the user is already having that membership, Database.insert(list,false) is used to handle those records.
      List<Database.SaveResult> results = Database.insert(
        psetAssignmentList,
        false
      );

      for (Integer i = 0; i < psetAssignmentList.size(); i++) {
        Database.SaveResult sr = results[i];
        PermissionSetAssignment rec = psetAssignmentList[i];

        if (sr.isSuccess()) {
          continue;
        }
        for (Database.Error err : sr.getErrors()) {
          if (String.valueOf(err.getStatusCode()) == 'DUPLICATE_VALUE') {
            continue;
          }
          failedRecordIds.add(rec.AssigneeId);
          logError(rec.AssigneeId, err);
        }
        Logger.saveLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'UserProvisioningAfterActions',
        'insertPsetAssignment',
        'Not enough permissions to create PermissionSetAssignment.'
      );
    }
  }

  /**
   * @description This method is called in assignMembership to insert Group Member to user record.
   * @param groupMemberList Group Member List
   */
  private static void insertGroupAssignment(List<GroupMember> groupMemberList) {
    if (
      GroupMember.sObjectType.getDescribe().isCreateable() &&
      Schema.sObjectType.GroupMember.fields.UserOrGroupId.isCreateable() &&
      Schema.sObjectType.GroupMember.fields.GroupId.isCreateable()
    ) {
      List<Database.SaveResult> results = Database.insert(
        groupMemberList,
        false
      );

      for (Integer i = 0; i < groupMemberList.size(); i++) {
        Database.SaveResult sr = results[i];
        GroupMember rec = groupMemberList[i];

        if (sr.isSuccess()) {
          continue;
        }
        for (Database.Error err : sr.getErrors()) {
          failedRecordIds.add(rec.UserOrGroupId);
          logError(rec.UserOrGroupId, err);
        }
        Logger.saveLog();
      }
    } else {
      CommonUtil.logAndThrowIAE(
        'UserProvisioningAfterActions',
        'insertGroupAssignment',
        'Not enough permissions to create GroupMember.'
      );
    }
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
      deletePsetAssignment(deletePsetList);
    }

    if (!deleteGroupMemberList.isEmpty()) {
      deleteGroupAssignment(deleteGroupMemberList);
    }
  }

  /**
   * @description This method is used to get Permission Set, Permission Set Group and Public Group name list based on users Business Function and Role.
   * @param oldBusinessFuncAndRoles Set of old Business Function and Roles key values combinations from trigger
   * @return `List<User_Provisioning_Setting__mdt>` return business function mapping of old user record
   */
  private static List<User_Provisioning_Setting__mdt> getOldRecordBusinessFunctions(
    Set<String> oldBusinessFuncAndRoles
  ) {
    List<User_Provisioning_Setting__mdt> businessFunctionList = new List<User_Provisioning_Setting__mdt>();
    if (Schema.sObjectType.User_Provisioning_Setting__mdt.isQueryable()) {
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
    }
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
      SELECT id, PermissionSet.Name, AssigneeId
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
      SELECT id, Group.DeveloperName, UserOrGroupId
      FROM GroupMember
      WHERE UserOrGroupId IN :userIds
    ]) {
      if (pGroups.contains(publicGroupMember.Group.DeveloperName)) {
        deleteGroupMemberList.add(publicGroupMember);
      }
    }
    return deleteGroupMemberList;
  }

  /**
   * @description This method is called in revokeMembership to delete Permission Set Assignments to user record.
   * @param deletePsetList Permission Set Assignment List
   */
  private static void deletePsetAssignment(
    List<PermissionSetAssignment> deletePsetList
  ) {
    if (PermissionSetAssignment.sObjectType.getDescribe().isDeletable()) {
      List<Database.DeleteResult> deleteResult = Database.delete(
        deletePsetList,
        false
      );
      for (Integer i = 0; i < deletePsetList.size(); i++) {
        Database.DeleteResult sr = deleteResult[i];
        PermissionSetAssignment rec = deletePsetList[i];
        if (sr.isSuccess()) {
          continue;
        }
        for (Database.Error err : sr.getErrors()) {
          failedRecordIds.add(rec.AssigneeId);
          logError(rec.AssigneeId, err);
        }
        Logger.saveLog();
      }
    } else {
      Logger.error('PermissionSetAssignment is not deletable');
      Logger.saveLog();
    }
  }

  /**
   * @description This method is called in revokeMembership to delete Group Member assignment to user record.
   * @param deleteGroupMemberList Group Member List
   */
  private static void deleteGroupAssignment(
    List<GroupMember> deleteGroupMemberList
  ) {
    if (GroupMember.sObjectType.getDescribe().isDeletable()) {
      List<Database.DeleteResult> deleteResult = Database.delete(
        deleteGroupMemberList,
        false
      );
      for (Integer i = 0; i < deleteGroupMemberList.size(); i++) {
        Database.DeleteResult sr = deleteResult[i];
        GroupMember rec = deleteGroupMemberList[i];
        if (sr.isSuccess()) {
          continue;
        }
        for (Database.Error err : sr.getErrors()) {
          failedRecordIds.add(rec.UserOrGroupId);
          logError(rec.UserOrGroupId, err);
        }
        Logger.saveLog();
      }
    } else {
      Logger.error('GroupMember is not deletable');
      Logger.saveLog();
    }
  }

  /**
   * @description Generic method to log failures
   * @param recordId record Id of the failed record
   * @param error Database.Error
   */
  private static void logError(String recordId, Database.Error error) {
    Logger.error(error.getMessage(), recordId);
  }

  /**
   * @description Method to log when user records are manually created
   * @param users List<User> User records created
   */
  public static void logManualUserProvisioning(List<User> users) {
    String currentUsername = Userinfo.getUserName();
    Id currentUserProfileId = Userinfo.getProfileId();
    String sailPointUsername = 'sailpoint.user@anzx.com';
    Id sailPointUserProfileId = CommonUtil.getProfileByName(
        'Minimum Access - External Apps'
      )
      .Id;
    if (
      currentUsername.contains(sailPointUsername) &&
      currentUserProfileId.equals(sailPointUserProfileId)
    ) {
      return;
    }
    for (User u : users) {
      Logger.error(
        'User ' + u.Username + ' manually created by ' + currentUsername,
        Logger.Severity.CRITICAL
      );
      Logger.saveLog();
    }
  }
  /**
     * @description Method to Add or Remove User to Chatter Group
     * @param users List<User> User records created
     * @param oldMap oldmap of user record

     */

  public static void addOrRemoveUsertoChatterGroup(
    List<User> users,
    Map<Id, User> oldMap
  ) {
    Set<Id> addUserIds = new Set<Id>();
    Set<Id> removeUserIds = new Set<Id>();
    List<CollaborationGroup> cmosGroup = USER_REPOSITORY.queryChatterGroup(
      System.Label.CMOS_Chatter_Group_Name
    );
    if (cmosGroup.isEmpty()) {
      return;
    }
    List<User> updatedUsers = ListUtil.filter(users, oldMap)
      .equals(User.IsActive, true)
      .changed(User.ProfileId)
      .toList();
    for (User userObj : updatedUsers) {
      User oldRec = oldMap.get(userObj.Id);
      if (checkforValidUserProfile(userObj)) {
        addUserIds.add(userObj.Id);
      }
      if (
        oldRec != null &&
        oldRec.ProfileId == anzProfile &&
        !checkforValidUserProfile(userObj)
      ) {
        removeUserIds.add(userObj.Id);
      }
    }

    addUserToGroup(addUserIds, cmosGroup[0].Id);
    removeUserToGroup(removeUserIds, cmosGroup[0].Id);
  }
  /**
   * @description Method to check valid user to be addedd to Group
   * @param newUser new version of user record
   * @return Boolean isValidUser
   */
  @TestVisible
  private static Boolean checkforValidUserProfile(User newUser) {
    Boolean isValidUser = false;
    if (newUser.ProfileId == anzProfile) {
      isValidUser = true;
    }
    return isValidUser;
  }
  /**
     * @description Method to add user to chatter group
     * @param userId userIds going to be addedd in group
     * @param groupId Id of Chatter group

     */
  @future
  private static void addUserToGroup(set<Id> userId, Id groupId) {
    List<CollaborationGroupMember> collGroupMembers = new List<CollaborationGroupMember>();
    for (Id usrId : userId) {
      CollaborationGroupMember member = new CollaborationGroupMember();
      member.MemberId = usrId;
      member.CollaborationGroupId = groupId;
      collGroupMembers.add(member);
    }
    DML_REPOSITORY.insertRecords(
      collGroupMembers,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.SYSTEM_MODE
    );
  }
  /**
     * @description Method to remove user to chatter group
     * @param userId userIds going to be removed from group
     * @param groupId Id of Chatter group

     */
  @future
  private static void removeUserToGroup(set<Id> userId, Id groupId) {
    List<CollaborationGroupMember> collGroupMembers = USER_REPOSITORY.queryChatterGroupUser(
      userId,
      groupId
    );

    DML_REPOSITORY.deleteRecords(
      collGroupMembers,
      DmlRepository.ALLOW_PARTIAL,
      DmlRepository.SYSTEM_MODE
    );
  }
}
