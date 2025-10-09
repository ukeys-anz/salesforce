/**
 * @since 08/2024
 * @description This class provides SOQL and DML helpers for classes related UserProvisioning related Actions
 * @runTests UserProvisioningAfterActionsTest
 */

public with sharing class UserProvisioningActionsRepository {
  /**
   * @description get Active User group members
   * @param userId set of users exist in group
   * @param groupId  Id for Chatter Group
   * @return List of CollaborationGroup members
   */

  public list<CollaborationGroupMember> queryChatterGroupUser(
    Set<Id> userId,
    String groupId
  ) {
    if (userId.isEmpty() || String.isBlank(groupId)) {
      return new List<CollaborationGroupMember>();
    }
    return [
      SELECT Id, MemberId
      FROM CollaborationGroupMember
      WHERE CollaborationGroupId = :groupId AND MemberId = :userId
      WITH USER_MODE
    ];
  }
  /**
   * @description get delete pSetAssignments
   * @param userIds userIds List of Id of users
   * @param pSets List of pset needs to be assigned to user
   * @return List of PermissionSetAssignment
   */
  public List<PermissionSetAssignment> getDeletePSetAssignmentList(
    List<Id> userIds,
    Set<String> pSets
  ) {
    if (userIds.isEmpty() || pSets.isEmpty()) {
      return new List<PermissionSetAssignment>();
    }
    return [
      SELECT id, PermissionSet.Name, AssigneeId
      FROM PermissionSetAssignment
      WHERE AssigneeId IN :userIds AND PermissionSet.Name IN :pSets
      WITH USER_MODE
    ];
  }

  /**
   * @description get delete GroupMembers
   * @param userIds userIds List of Id of users
   * @param pGroups List of public Groups needs to be assigned to user
   * @return List of GroupMember
   */
  public List<GroupMember> getDeleteGroupMemberList(
    List<Id> userIds,
    Set<String> pGroups
  ) {
    if (userIds.isEmpty() || pGroups.isEmpty()) {
      return new List<GroupMember>();
    }

    return [
      SELECT id, Group.DeveloperName, UserOrGroupId
      FROM GroupMember
      WHERE UserOrGroupId IN :userIds AND Group.DeveloperName IN :pGroups
      WITH USER_MODE
    ];
  }
}
