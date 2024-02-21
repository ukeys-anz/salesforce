/**
 * @author Ashish Kumar
 * @since  08/2023
 * @group MLCRM (Mobile Lending CRM)
 * @description ML_UserActions is class to handle onboarding of user and creating/updating user territory record.
 */
public with sharing class ML_UserActions {
  /**
   * @description Salesforce Automation for Onboarding MLCRM User
   * @name createTerritoryForMLUser
   * @param lstOfUsers new list user
   * @param oldMapUsers old values of user when it is updated
   * @author Ashish Kumar
   * @US CC-4820
   */
  public static void createTerritoryForMLUser(
    List<user> lstOfUsers,
    Map<Id, user> oldMapUsers
  ) {
    Id mlRoleId = CommonUtil.getUserRoleByDevName(
        MLCRMConstants.ML_ROLE_DEV_NAME
      )
      ?.Id;
    Set<String> setOfTerritories = new Set<String>();
    List<User_Territory_Setup_Event__e> lstOfUserTerritory = new List<User_Territory_Setup_Event__e>();
    String strUserIds = null;
    for (User objUser : lstOfUsers) {
      if (
        // user is an ML franchise user
        objUser.Profile_Name__c == 'ANZ ML Standard User' &&
        objUser.UserRoleId == mlRoleId &&
        // user is new and has role or territory populated
        ((oldMapUsers == null &&
        objUser.ML_Territories__c != null &&
        objUser.ML_Role__c != null) ||
        // OR, user has isActive, ML territory, ML role, userRole, profile updated
        (oldMapUsers != null &&
        (oldMapUsers.get(objUser.Id).IsActive != objUser.IsActive ||
        oldMapUsers.get(objUser.Id).ML_Territories__c !=
        objUser.ML_Territories__c ||
        oldMapUsers.get(objUser.Id).ML_Role__c != objUser.ML_Role__c ||
        oldMapUsers.get(objUser.Id).UserRoleId != objUser.UserRoleId ||
        oldMapUsers.get(objUser.Id).profileId != objUser.profileId)))
      ) {
        if (strUserIds == null) {
          strUserIds = objUser.Id + ';';
        } else {
          strUserIds = strUserIds + objUser.Id + ';';
        }
      }
    }
    if (strUserIds != null) {
      User_Territory_Setup_Event__e objEvent = new User_Territory_Setup_Event__e();
      objEvent.User_Id__c = strUserIds.removeEnd(';');
      Eventbus.publish(objEvent);
    }
  }
}
