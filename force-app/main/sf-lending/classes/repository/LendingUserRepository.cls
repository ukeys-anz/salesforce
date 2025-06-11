/**
 *
 * @author Jaya Srivastava
 * @since 02/2025
 * @description Class to handle Lending Case actions
 */
public with sharing class LendingUserRepository {
  /**
   * @description Construct a map of User Id as key and User as value
   * @param ownerIds set<Id>
   * @return List<User>
   */
  public static List<User> getUserDetailsByIds(set<Id> ownerIds) {
    if (ownerIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, UserRole.DeveloperName
      FROM User
      WHERE Id IN :ownerIds
      WITH USER_MODE
    ];
  }
}
