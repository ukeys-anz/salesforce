/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description UserProvisioningAfterActions class is called in UserTriggerHandler to assign Permission set, Permission Set Group
 * and Public group automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
public with sharing class UserProvisioningAfterActions {
  private static final UserProvisioningActionsRepository USER_REPOSITORY = (UserProvisioningActionsRepository) Lib_InstanceProvider.forType(
    UserProvisioningActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final UserProvisioningAfterActions USER_ACTIONS = (UserProvisioningAfterActions) Lib_InstanceProvider.forType(
    UserProvisioningAfterActions.class
  );
  @TestVisible
  private static Id anzProfile = QueryProfile.anzUser.Id;
  private static final String PSET_LIC_ASSIGN_ERROR = 'Not enough permissions to create PermissionSetLicenseAssign.';
  private static final String PSET_ERROR = 'Not enough permissions to create PermissionSetAssignment.';
  private static final String GROUP_ERROR = 'Not enough permissions to create GroupMember.';

  /**
   * @description This method is called in OnAfterInsert & OnAfterUpdate to assign Permission sets, Permission set groups and public groups to user record.
   * Permission set name, Permission set group name and Public group names are identified from User_Provisioning_Setting__mdt object based on the combination of Business Function and Business Role from user object.
   * @param records List of user records from trigger
   */

  public static void assignMembership(List<User> records) {
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
    List<GroupMember> groupMemberList = new List<GroupMember>();

    for (User record : records) {
      psetLicenseAssignmentList.addAll(assignPermissionSetLicences(record));
      psetAssignmentList.addAll(assignPermissionSet(record));
      psetAssignmentList.addAll(assignPermissionSetGroup(record));
      groupMemberList.addAll(assignPublicGroup(record));
    }

    insertPsetLicenseAssign(psetLicenseAssignmentList);

    insertPsetAssignment(psetAssignmentList);

    insertGroupAssignment(groupMemberList);
  }

  /**
   * @description This method is called in assignMembership to assign Permission sets to user record.
   * @param record User record from trigger
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSet(
    User record
  ) {
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();
    List<String> pSetList = getPermissionToBeAssignedValues(
      'Permission_sets__c',
      UserProvisioningCommonActions.generateKey(record)
    );
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
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSetGroup(
    User record
  ) {
    List<PermissionSetAssignment> psetAssignmentList = new List<PermissionSetAssignment>();
    List<String> pSetGroupList = getPermissionToBeAssignedValues(
      'Permission_Set_Groups__c',
      UserProvisioningCommonActions.generateKey(record)
    );
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
   * @return `List<PermissionSetLicenseAssign>` List of permission set license assignment for insert
   */
  private static List<PermissionSetLicenseAssign> assignPermissionSetLicences(
    User record
  ) {
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();
    List<String> pSetLicenseList = getPermissionToBeAssignedValues(
      'Permission_Set_Licences__c',
      UserProvisioningCommonActions.generateKey(record)
    );
    for (String pSetLicenseName : pSetLicenseList) {
      PermissionSetLicenseAssign assignPsetLicense = new PermissionSetLicenseAssign();
      assignPsetLicense.AssigneeId = record.id;
      assignPsetLicense.PermissionSetLicenseId = QueryPSetLicense.getByName(
          pSetLicenseName
        )
        .Id;
      psetLicenseAssignmentList.add(assignPsetLicense);
    }

    return psetLicenseAssignmentList;
  }

  /**
   * @description This method is called in assignMembership to assign Public Groups to user record.
   * @param record User record from trigger
   * @return `List<GroupMember>` List of group member for insert
   */
  private static List<GroupMember> assignPublicGroup(User record) {
    List<GroupMember> groupMemberList = new List<GroupMember>();
    List<String> groupList = getPermissionToBeAssignedValues(
      'Public_Groups__c',
      UserProvisioningCommonActions.generateKey(record)
    );
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
  @TestVisible
  private static void insertPsetLicenseAssign(
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList
  ) {
    if (
      USER_ACTIONS.checkCreatePermissions(
        PermissionSetLicenseAssign.SObjectType,
        psetLicenseAssignmentList
      )
    ) {
      Logger.error(PSET_LIC_ASSIGN_ERROR).save();
      throw new InsufficientAccessException(PSET_LIC_ASSIGN_ERROR);
    }
    // DML running in partial mode and all the errors occured will be logged.
    DML_REPOSITORY.doInsert(
      psetLicenseAssignmentList,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorlog('Error While Inserting Permission Set License Assignments')
    );
  }

  /**
   * @description This method is called in assignMembership to insert Permission Set Assignments to user record.
   * @param psetAssignmentList Permission Set Assignment List
   */
  @TestVisible
  public static void insertPsetAssignment(
    List<PermissionSetAssignment> psetAssignmentList
  ) {
    if (
      USER_ACTIONS.checkCreatePermissions(
        PermissionSetAssignment.SObjectType,
        psetAssignmentList
      )
    ) {
      Logger.error(PSET_ERROR).save();
      throw new InsufficientAccessException(PSET_ERROR);
    }
    // DML running in partial mode and all the errors occured will be logged.
    DML_REPOSITORY.doInsert(
      psetAssignmentList,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorlog('Error While Inserting Permission Set Assignments')
    );
  }

  /**
   * @description This method is called in assignMembership to insert Group Member to user record.
   * @param groupMemberList Group Member List
   */
  @TestVisible
  private static void insertGroupAssignment(List<GroupMember> groupMemberList) {
    if (
      USER_ACTIONS.checkCreatePermissions(
        GroupMember.SObjectType,
        groupMemberList
      )
    ) {
      Logger.error(GROUP_ERROR).save();
      throw new InsufficientAccessException(GROUP_ERROR);
    }
    DML_REPOSITORY.doInsert(
      groupMemberList,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorlog('Error While Inserting GroupMember')
    );
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
    Set<String> pSets = new Set<String>();

    Set<String> pGroups = new Set<String>();

    for (String roles : oldBusinessFuncAndRoles) {
      pSets.addAll(
        getPermissionToBeAssignedValues('Permission_Sets__c', roles)
      );
      pSets.addAll(
        getPermissionToBeAssignedValues('Permission_Set_Groups__c', roles)
      );
      pGroups.addAll(
        getPermissionToBeAssignedValues('Public_Groups__c', roles)
      );
    }

    deletePsetAssignment(
      USER_REPOSITORY.getDeletePSetAssignmentList(userIds, pSets)
    );

    deleteGroupAssignment(
      USER_REPOSITORY.getDeleteGroupMemberList(userIds, pGroups)
    );
  }
  /**
   * @description This method is called in revokeMembership to delete Permission Set Assignments to user record.
   * @param deletePsetList Permission Set Assignment List
   */
  @TestVisible
  private static void deletePsetAssignment(
    List<PermissionSetAssignment> deletePsetList
  ) {
    if (
      USER_ACTIONS.checkDeletePermissions(PermissionSetAssignment.sObjectType)
    ) {
      Logger.error('PermissionSetAssignment is not deletable');
      Logger.saveLog();
      return;
    }
    DML_REPOSITORY.doDelete(
      deletePsetList,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorLog('Failure deleting permission assignment')
    );
  }

  /**
   * @description This method is called in revokeMembership to delete Group Member assignment to user record.
   * @param deleteGroupMemberList Group Member List
   */
  @TestVisible
  private static void deleteGroupAssignment(
    List<GroupMember> deleteGroupMemberList
  ) {
    if (USER_ACTIONS.checkDeletePermissions(GroupMember.sObjectType)) {
      Logger.error('GroupMember is not deletable');
      Logger.saveLog();
      return;
    }
    DML_REPOSITORY.doDelete(
      deleteGroupMemberList,
      new DmlConfig()
        .allowPartial()
        .systemMode()
        .errorLog('Failure deleting permission assignment')
    );
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
    CollaborationGroup cmosGroup = QueryCollaborationGroup.getByName(
      System.Label.CMOS_Chatter_Group_Name
    );
    if (cmosGroup == null) {
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
    addUserToGroup(addUserIds);
    removeUserToGroup(removeUserIds);
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
   */
  @future
  private static void addUserToGroup(set<Id> userId) {
    List<CollaborationGroupMember> collGroupMembers = new List<CollaborationGroupMember>();
    for (Id usrId : userId) {
      CollaborationGroupMember member = new CollaborationGroupMember();
      member.MemberId = usrId;
      member.CollaborationGroupId = QueryCollaborationGroup.getByName(
          System.Label.CMOS_Chatter_Group_Name
        )
        .Id;
      collGroupMembers.add(member);
    }
    DML_REPOSITORY.doInsert(collGroupMembers, new DmlConfig().withoutSharing());
  }
  /**
   * @description Method to remove user to chatter group
   * @param userId userIds going to be removed from group
   */
  @testvisible
  @future
  private static void removeUserToGroup(set<Id> userId) {
    List<CollaborationGroupMember> collGroupMembers = USER_REPOSITORY.queryChatterGroupUser(
      userId,
      QueryCollaborationGroup.getByName(System.Label.CMOS_Chatter_Group_Name).Id
    );

    DML_REPOSITORY.doDelete(collGroupMembers, new DmlConfig().withoutSharing());
  }
  /**
   * @description extend the Exception class to allow errors to be thrown if the user does not have access
   */
  private class InsufficientAccessException extends Exception {
  }
  /**
   * @description Method to get list of permissions assigned to user based on thier business function role
   * @param metaField permission assigned to user
   * @param businessFunctionRoleKey Business function key for the user
   * @return `List<String>` List of permissions assigned to users
   */
  private static List<String> getPermissionToBeAssignedValues(
    String metaField,
    String businessFunctionRoleKey
  ) {
    User_Provisioning_Setting__mdt usrMdt = QueryUserProvisioningSetting.getByName(
      businessFunctionRoleKey
    );
    String value = String.valueOf(usrMdt?.get(metaField));
    List<String> pSetLicenseList = String.isBlank(value)
      ? new List<String>()
      : value.deleteWhitespace().split(';');

    return pSetLicenseList;
  }
  /**
   * @description check object and field permission
   * @param obj SObjectType
   * @param sObjectList List of sobject
   * @return boolean permission check
   */
  public boolean checkCreatePermissions(
    Schema.SObjectType obj,
    List<sobject> sObjectList
  ) {
    return (!obj.getDescribe().isCreateable() ||
    Security.stripInaccessible(AccessType.CREATABLE, sObjectList)
      .getRemovedFields()
      .isEmpty() == false);
  }
  /**
   * @description check object permission
   * @param obj SObjectType
   * @return boolean permission check
   */
  public boolean checkDeletePermissions(Schema.SObjectType obj) {
    return (!obj.getDescribe().isDeletable());
  }
}
