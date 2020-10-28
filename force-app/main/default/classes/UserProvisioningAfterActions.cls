/**
 * @author Boobalakrishnan Duraisamy
 * @since  04/2020
 * @description UserProvisioningAfterActions class is called in UserTriggerHandler to assign Permission set, Permission Set Group
 * and Public group automatically based on Buesiness Function and Role combinations in User Provisioning Custom Metadata object.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class UserProvisioningAfterActions {
  private static lib_systemLog log = new lib_systemLog(
    UserProvisioningAfterActions.class.getName()
  );
  private static Set<Id> failedRecordIds = new Set<Id>();

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

    if (!businessFunctionMap.isEmpty()) {
      Map<String, PermissionSet> pSetMap = UserProvisioningCommonActions.getAllPSetMap();
      Map<String, PermissionSetGroup> pSetGroupMap = UserProvisioningCommonActions.getAllPsetGroupMap();
      Map<String, PermissionSetLicense> pSetLicenseMap = UserProvisioningCommonActions.getAllPSetLicenseMap();
      Map<String, Group> publicGroupMap = UserProvisioningCommonActions.getAllPublicGroupMap();

      for (User record : records) {
        psetLicenseAssignmentList.addAll(
          assignPermissionSetLicences(
            record,
            businessFunctionMap,
            pSetLicenseMap
          )
        );
        psetAssignmentList.addAll(
          assignPermissionSet(record, businessFunctionMap, pSetMap)
        );
        psetAssignmentList.addAll(
          assignPermissionSetGroup(record, businessFunctionMap, pSetGroupMap)
        );
        groupMemberList.addAll(
          assignPublicGroup(record, businessFunctionMap, publicGroupMap)
        );
      }
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
   * @param pSetMap Permission Set Map with permission set name as a key
   * @return `List<PermissionSetAssignment>` List of permission set assignment for insert
   */
  private static List<PermissionSetAssignment> assignPermissionSet(
    User record,
    Map<String, User_Provisioning_Setting__mdt> businessFunctionMap,
    Map<String, PermissionSet> pSetMap
  ) {
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
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
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
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
    String pSetLicenseNames;
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList = new List<PermissionSetLicenseAssign>();

    if (businessFunctionMap.containskey(businessFunctionRoleKey)) {
      pSetLicenseNames = businessFunctionMap.get(businessFunctionRoleKey)
        .Permission_Set_Licences__c;
    }
    if (String.isNotBlank(pSetLicenseNames)) {
      List<String> pSetLicenseList = pSetLicenseNames.deleteWhitespace()
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
    }
    return psetLicenseAssignmentList;
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
    String businessFunctionRoleKey = UserProvisioningCommonActions.generateKey(
      record
    );
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
   * @description This method is called in assignMembership to insert Permission Set License Assignments to user record.
   * @param psetLicenseAssignmentList Permission Set License Assignment List
   */
  private static void insertPsetLicenseAssign(
    List<PermissionSetLicenseAssign> psetLicenseAssignmentList
  ) {
    //no logic written to check if the user is already having that membership, Database.insert(list,false) is used to handle those records.
    List<Database.SaveResult> results = Database.insert(
      psetLicenseAssignmentList,
      false
    );

    for (Integer i = 0; i < psetLicenseAssignmentList.size(); i++) {
      Database.SaveResult sr = results[i];
      PermissionSetLicenseAssign rec = psetLicenseAssignmentList[i];

      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          if (String.valueOf(err.getStatusCode()) != 'DUPLICATE_VALUE') {
            failedRecordIds.add(rec.AssigneeId);
            logError(rec.AssigneeId, err);
          }
        }
      }
    }
  }

  /**
   * @description This method is called in assignMembership to insert Permission Set Assignments to user record.
   * @param psetAssignmentList Permission Set Assignment List
   */
  private static void insertPsetAssignment(
    List<PermissionSetAssignment> psetAssignmentList
  ) {
    //no logic written to check if the user is already having that membership, Database.insert(list,false) is used to handle those records.
    List<Database.SaveResult> results = Database.insert(
      psetAssignmentList,
      false
    );

    for (Integer i = 0; i < psetAssignmentList.size(); i++) {
      Database.SaveResult sr = results[i];
      PermissionSetAssignment rec = psetAssignmentList[i];

      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          if (String.valueOf(err.getStatusCode()) != 'DUPLICATE_VALUE') {
            failedRecordIds.add(rec.AssigneeId);
            logError(rec.AssigneeId, err);
          }
        }
      }
    }
  }

  /**
   * @description This method is called in assignMembership to insert Group Member to user record.
   * @param groupMemberList Group Member List
   */
  private static void insertGroupAssignment(List<GroupMember> groupMemberList) {
    List<Database.SaveResult> results = Database.insert(groupMemberList, false);

    for (Integer i = 0; i < groupMemberList.size(); i++) {
      Database.SaveResult sr = results[i];
      GroupMember rec = groupMemberList[i];

      if (!sr.isSuccess()) {
        for (Database.Error err : sr.getErrors()) {
          failedRecordIds.add(rec.UserOrGroupId);
          logError(rec.UserOrGroupId, err);
        }
      }
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
    Set<String> pSets = new Set<String>();

    Set<String> pGroups = new Set<String>();

    Set<String> pLicences = new Set<String>();

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
      if (String.isNotBlank(businessFunction.Permission_Set_Licences__c)) {
        pLicences.addAll(
          businessFunction.Permission_Set_Licences__c.deleteWhitespace()
            .split(';')
        );
      }
    }

    deleteSObject(
      [
        SELECT id, PermissionSet.Name, AssigneeId
        FROM PermissionSetAssignment
        WHERE AssigneeId IN :userIds AND PermissionSet.Name IN :pSets
      ]
    );

    deleteSObject(
      [
        SELECT Id, AssigneeId, PermissionSetLicense.DeveloperName
        FROM PermissionSetLicenseAssign
        WHERE
          AssigneeId IN :userIds
          AND PermissionSetLicense.DeveloperName IN :pLicences
      ]
    );

    deleteSObject(
      [
        SELECT id, Group.DeveloperName, UserOrGroupId
        FROM GroupMember
        WHERE UserOrGroupId IN :userIds AND Group.DeveloperName IN :pGroups
      ]
    );
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
          Permission_Set_Licences__c,
          Public_Groups__c
        FROM User_Provisioning_Setting__mdt
        WHERE DeveloperName IN :oldBusinessFuncAndRoles
      ];
    }
    return businessFunctionList;
  }

  /**
   * @description This method is called in revokeMembership to delete assignments and group memberships
   * @param deleteList assignment sobject list
   */
  private static void deleteSObject(List<SObject> deleteList) {
    if (!deleteList.isEmpty()) {
      List<Database.DeleteResult> deleteResult = Database.delete(
        deleteList,
        false
      );
      for (Integer i = 0; i < deleteList.size(); i++) {
        Database.DeleteResult sr = deleteResult[i];
        SObject rec = deleteList[i];
        if (!sr.isSuccess()) {
          Id userId = rec.get('AssigneeId') != null
            ? (Id) rec.get('AssigneeId')
            : (Id) rec.get('UserOrGroupId');
          for (Database.Error err : sr.getErrors()) {
            failedRecordIds.add(userId);
            logError(userId, err);
          }
        }
      }
    }
  }

  /**
   * @description Generic method to log failures in Lib_SystemLog.addObjectMessage
   * @param recordId record Id of the failed record
   * @param error Database.Error
   */
  private static void logError(String recordId, Database.Error error) {
    log.addObjectMessage(
      'User',
      recordId,
      String.valueOf(error.getStatusCode()),
      'Id=' +
      recordId +
      ',Message:' +
      error.getMessage() +
      'Fields:' +
      error.getFields(),
      Lib_SystemLog.Severity.ERROR
    );
  }

  /**
   * @description This method is called after all the user provisioning process to update UPR status and log errors.
   * @param records user records from trigger
   */
  public static void updateUPRStatus(List<User> records) {
    Map<String, User_Provisioning_Request__c> uprMap = new Map<String, User_Provisioning_Request__c>();
    Map<String, String> userIdMap = new Map<String, String>();

    for (User record : records) {
      userIdMap.put(record.FederationIdentifier, record.Id);
    }

    //Check if there is any UPR record and Queue the status update
    uprMap = UserProvisioningBeforeActions.getUPRRecords(userIdMap.keySet());

    for (User_Provisioning_Request__c upr : uprMAP.values()) {
      upr.Requestor__c = userIdMap.get(upr.Requestor_UUID__c);
      upr.Status__c = (failedRecordIds.contains(
          userIdMap.get(upr.Requestor_UUID__c)
        )
        ? 'Error'
        : 'Completed');
    }

    if (!uprMap.isEmpty() || !log.log.isEmpty()) {
      system.enqueueJob(new QueueUPRStatusUpdate(uprMAP.values(), log));
    }
  }
}
