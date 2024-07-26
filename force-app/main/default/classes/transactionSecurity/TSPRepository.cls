/**
 * @description repository class for Transaction Security Policy {@link NonANZNetworkEventHandler}
 * @runTests NonANZNetworkEventHandlerTest
 * @author @hannah sainumkheaw
 * @since 22/07/2024
 */

public with sharing class TSPRepository {
  /**
   * @description to query eventuser's Profile
   * @param  userId `Id` An userId of the Event User
   * @return User `User` with Profile.Name of the Event User
   */
  public User queryProfilebyEventUserId(Id userId) {
    return [
      SELECT Id, Profile.Name
      FROM User
      WHERE Id = :userId
      WITH USER_MODE
      LIMIT 1
    ];
  }
}
