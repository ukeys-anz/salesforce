/**
 * @author Boobalakrishnan Duraisamy
 * @since  07/2020
 * @description Registration handler for Azure AD Open ID connect
 */
@SuppressWarnings('PMD.AvoidGlobalModifier')
global with sharing class ANZAzureADRegistrationHandler implements Auth.RegistrationHandler {
  /**
   * @description Here we never create a User .. either we find one in Salesforce or we don't
   * @param portalId from Azure AD
   * @param data User data from Azure AD
   * @return User record from salesforce.
   */
  global User createUser(Id portalId, Auth.UserData data) {
    User u = getUser(data);
    return u;
  }

  /**
   * @description Mandatory method which can be used to update the user record. Does nothing for now.
   * @param userId from Azure AD
   * @param portalId from Azure AD
   * @param data User data from Azure AD
   */
  @SuppressWarnings('PMD.EmptyStatementBlock')
  global void updateUser(Id userId, Id portalId, Auth.UserData data) {
    //do nothing
    getUser(data);
  }

  /**
   * @description This method queries salesforce to find the matching user record
   * @param data User data from Azure AD
   * @return User record from salesforce.
   */
  private User getUser(Auth.UserData data) {
    Map<String, String> attributeMap = data.attributeMap;
    String upn = attributeMap.get('upn');
    List<User> users = new List<User>();
    if (Schema.sObjectType.User.isQueryable()) {
      users = [
        SELECT
          ID,
          USERNAME,
          FIRSTNAME,
          LASTNAME,
          FederationIdentifier,
          Profile.Name
        FROM User
        WHERE FederationIdentifier = :upn AND isActive = TRUE
      ];
    }

    if (users.size() > 0) {
      User u = users[0];
      AuthTokenCacheUtil.storeAzureOrgTokens(
        u,
        attributeMap.get('refreshToken'),
        attributeMap.get('idToken')
      );
      return u;
    } else {
      return null;
    }
  }
}
