/**
 * @author MLCRM Developer
 * @since 08/2024
 * @description This class provide SOQL for User related queries.
 */
public with sharing class UserActionsRepository {
  /**
   * @since  08/2024
   * @group MLCRM (Mobile Lending CRM)
   * @name getUserMapFromUserIds
   * @param idsofUserIds ids of sObject records
   * @return Map<Id, User> map of sObject records
   * @description  method to get map of users for given set of ids
   * Cannot use USER_MODE as deployment user is not having access on Profile fields of User and many existing test classes are breaking due to USER_MODE
   */
  public Map<Id, User> getUserMapFromUserIds(Set<ID> idsofUserIds) {
    if (idsofUserIds.isEmpty()) {
      return new Map<Id, User>();
    }
    return new Map<Id, User>(
      [
        SELECT Id, Username, profile.Name, Name, Email, UserRoleId, Lan_Id__c
        FROM User
        WHERE Id IN :idsofUserIds
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description This method gets map of Id vs Users for given set of email
   * @name getUsersFromEmailIds
   * @param emailSet Set of email
   * @return List<User> list of User records
   */
  public List<User> getUsersFromEmailIds(Set<String> emailSet) {
    if (emailSet.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Name, Email
      FROM User
      WHERE isActive = TRUE AND Email IN :emailSet
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @since  10/2024
   * @name getUserIdFromListOfUsername
   * @param lstOfuserName List<String> list of usernames
   * @return Set<Id> Set of ids
   * @description  method to get set of userIds for given list of usernames
   */
  public Set<Id> getUserIdFromListOfUsername(List<String> lstOfuserName) {
    if (lstOfuserName.isEmpty()) {
      return null;
    }
    Map<Id, User> mapOfUsers = new Map<Id, User>(
      [SELECT Id FROM User WHERE userName IN :lstOfuserName]
    );
    return mapOfUsers.keySet();
  }

  /**
   * @description isCurrentLoggedInNotMLOrAdminUser check if the user is not ML or Admin Profile
   * @return Boolean
   */
  public Boolean isCurrentLoggedInNotMLOrAdminUser() {
    return (UserInfo.getProfileId() != QueryProfile.anzMLStandardUser.Id &&
    UserInfo.getProfileId() != QueryProfile.systemAdmin.Id);
  }

  /**
   * @description isCurrentLoggedInMLOrAdminUser check if the user is ML or Admin Profile
   * @return Boolean
   */
  public Boolean isCurrentLoggedInMLOrAdminUser() {
    return (UserInfo.getProfileId() == QueryProfile.anzMLStandardUser.Id ||
    UserInfo.getProfileId() == QueryProfile.systemAdmin.Id);
  }

  /**
   * @description isCustomValidationsSkipped check Custom Validations Skipped
   * @return Boolean
   */
  public Boolean isCustomValidationsSkipped() {
    return (FeatureManagement.checkPermission('CCRM_Skip_Validation') ||
    Salesforce_Library_Settings__c.getInstance(UserInfo.getUserId())
      .Disable_VRs__c);
  }

  /**
   * @description get list of users for given set of ids
   * @name getUserbyUserIds
   * @param setOfUserId Set of User Ids from User_Territory_Setup_Event__e records
   * @return List<User> list of Users
   */
  public List<User> getUserbyUserIds(Set<String> setOfUserId) {
    if (setOfUserId.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, ML_Territories__c, ML_Role__c, IsActive
      FROM User
      WHERE Id IN :setOfUserId
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @since  01/2025
   * @group MLCRM (Mobile Lending CRM)
   * @name getUserFromUserIds
   * @param idOfUserId id of user
   * @return User user record
   * @description  method to get users for given id
   */
  public User getUserFromUserIds(Id idOfUserId) {
    if (String.isEmpty(idOfUserId)) {
      return new User();
    }
    return [
      SELECT Id, Lan_Id__c
      FROM User
      WHERE Id = :idOfUserId
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Check if user is ADOBE/UNICA integration user
   * @name isIntegrationUser
   * @return `Boolean` True if user is integration user
   */
  public Boolean isIntegrationUser() {
    return UserInfo.getUserName()
        .startsWithIgnoreCase(Label.UnicaIntegrationUserName) ||
      UserInfo.getUserName()
        .startsWithIgnoreCase(Label.AdobeIntegrationUserName);
  }
}
