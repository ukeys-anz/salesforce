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
   * @description  method to get map of users for given set of ids.
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
