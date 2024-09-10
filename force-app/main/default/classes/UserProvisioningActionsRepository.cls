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
    return [
      SELECT Id, MemberId
      FROM CollaborationGroupMember
      WHERE CollaborationGroupId = :groupId AND MemberId = :userId
    ];
  }
  /**
   * @description get name of active chatter group
   * @param groupName Chatter Group Name
   * @return List of CollaborationGroups
   */
  public List<CollaborationGroup> queryChatterGroup(String groupName) {
    return [
      SELECT Id, name
      FROM CollaborationGroup
      WHERE Name = :groupName
    ];
  }
}
