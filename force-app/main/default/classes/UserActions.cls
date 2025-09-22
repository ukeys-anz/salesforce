/**
 * @author ML Developer
 * @since  11/2024
 * @description Class to handle onboarding of user and creating/updating user territory record.
 */
public with sharing class UserActions {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final Set<SObjectField> USER_FIELDS_SET = new Set<SObjectField>{
    User.IsActive,
    User.ML_Role__c,
    User.ML_Territories__c,
    User.UserRoleId,
    User.ProfileId
  };

  /**
   * @description Salesforce Automation for Onboarding MLCRM User
   * @name createTerritoryForMLUser
   * @param lstOfUsers new list user
   * @param oldMapUsers old values of user when it is updated
   */
  public static void createTerritoryForMLUser(
    List<user> lstOfUsers,
    Map<Id, user> oldMapUsers
  ) {
    List<User> franchiseUsers = ListUtil.filter(lstOfUsers)
      .equals(User.ProfileId, QueryProfile.anzMLStandardUser.Id)
      .equals(User.UserRoleId, QueryRole.mlFranchiseRole.Id)
      .toList();
    List<User> filteredUsers = filterUsersForTerritorySetup(
      franchiseUsers,
      oldMapUsers
    );
    if (filteredUsers.isEmpty()) {
      return;
    }
    Set<Id> userIdSet = ListUtil.getIds(filteredUsers, User.Id);
    User_Territory_Setup_Event__e objEvent = new User_Territory_Setup_Event__e();
    objEvent.User_Id__c = String.join(userIdSet, ';');
    DML_REPOSITORY.doPublish(objEvent);
  }

  /**
   * @description  method to filter users for territory setup
   * @name filterUsersForTerritorySetup
   * @param franchiseUsers list of users
   * @param oldMapUsers old values of user when it is updated
   * @return List<User>
   */
  @TestVisible
  private static List<User> filterUsersForTerritorySetup(
    List<User> franchiseUsers,
    Map<Id, User> oldMapUsers
  ) {
    if (franchiseUsers.isEmpty()) {
      return new List<User>();
    }
    if (oldMapUsers == null) {
      return ListUtil.filter(franchiseUsers)
        .isNotNull(User.ML_Territories__c)
        .isNotNull(User.ML_Role__c)
        .toList();
    }
    return ListUtil.filter(franchiseUsers, oldMapUsers)
      .anyChanged(USER_FIELDS_SET)
      .toList();
  }
}
