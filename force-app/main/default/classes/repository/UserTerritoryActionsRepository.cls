/**
 * @author MLCRM Developer
 * @since 08/2024
 * @description This class provide SOQL for User Territory related queries.
 * Used SYSTEM_MODE as User Territories aligned in system mode
 */
public without sharing class UserTerritoryActionsRepository {
  public static final String STATUS_ACTIVE = 'Active';
  /**
   * @description getUserTerrritoriesFromUserIds method return user Territories associated to the given ids of the users
   * @param idsofOwnerIds Id of the Territories
   * @return List<User_Territory__c> User Territory List
   */
  public List<User_Territory__c> getUserTerrritoriesFromUserIds(
    Set<ID> idsofOwnerIds
  ) {
    if (idsofOwnerIds.isEmpty()) {
      return new List<User_Territory__c>();
    }
    return [
      SELECT Territory__c, User__c, Territory__r.Primary_Franchise_Owner__c
      FROM User_Territory__c
      WHERE
        User__c IN :idsofOwnerIds
        AND Status__c = :STATUS_ACTIVE
        AND Territory__r.Status__c = :STATUS_ACTIVE
      WITH SYSTEM_MODE
      ORDER BY Territory__r.Name
    ];
  }
  /**
   * @description getActiveUserTerrritories method return user Territories associated to the given ids of the Active users
   * @param idsofOwnerIds Id of the Territories
   * @return List<User_Territory__c> User Territory List
   */
  public List<User_Territory__c> getActiveUserTerrritories(
    Set<ID> idsofOwnerIds
  ) {
    if (idsofOwnerIds.isEmpty()) {
      return new List<User_Territory__c>();
    }
    return [
      SELECT Id, ML_Role__c, User__c, Territory__c
      FROM User_Territory__c
      WHERE User__c IN :idsofOwnerIds AND Status__c = :STATUS_ACTIVE
      WITH SYSTEM_MODE
    ];
  }
  /**
   * @description getUserTerritoryFromFranchiseOwnerId method return user Territories associated to Primary Franchise Owners
   * @param idsOfFranchiseOwner Id of the Primary Franchise Owner
   * @return List<User_Territory__c> User Territory List
   */
  public List<User_Territory__c> getUserTerritoryFromFranchiseOwnerId(
    Set<Id> idsOfFranchiseOwner
  ) {
    if (idsOfFranchiseOwner.isEmpty()) {
      return new List<User_Territory__c>();
    }
    return [
      SELECT Id, Territory__r.Primary_Franchise_Owner__c, User__c
      FROM User_Territory__c
      WHERE
        Territory__r.Primary_Franchise_Owner__c IN :idsOfFranchiseOwner
        AND Status__c = :STATUS_ACTIVE
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description This method is used to get user territory records based on territory id set
   * @name getUserTerritories
   * @param idsOfTerritory record terriotry ids
   * @param idsOfOwner record owner ids
   * @return List<User_Territory__c>
   */
  public List<User_Territory__c> getUserTerritories(
    Set<Id> idsOfTerritory,
    Set<Id> idsOfOwner
  ) {
    if (idsOfTerritory.isEmpty() || idsOfOwner.isEmpty()) {
      return new List<User_Territory__c>();
    }
    return [
      SELECT
        Id,
        ML_Role__c,
        User__c,
        Territory__c,
        Territory__r.Access_Scope__c,
        Status__c
      FROM User_Territory__c
      WHERE
        Territory__c IN :idsOfTerritory
        AND (Status__c = :STATUS_ACTIVE
        OR User__c IN :idsOfOwner)
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description This method is used to get territory records based on user id set
   * @name getTerritoriesbyUserIds
   * @param setOfUserId Set of User Ids
   * @return List<User_Territory__c>
   */
  public List<User_Territory__c> getTerritoriesbyUserIds(
    Set<String> setOfUserId
  ) {
    if (setOfUserId.isEmpty()) {
      return new List<User_Territory__c>();
    }
    return new List<User_Territory__c>(
      [
        SELECT
          Id,
          User__c,
          Territory__c,
          Status__c,
          ML_Role__c,
          Territory__r.Name
        FROM User_Territory__c
        WHERE User__c IN :setOfUserId
        WITH SYSTEM_MODE
      ]
    );
  }
}
