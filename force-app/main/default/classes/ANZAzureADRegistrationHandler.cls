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
    debugToken(data);
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
  }

  /**
   * @description This method queries salesforce to find the matching user record
   * @param data User data from Azure AD
   * @return User record from salesforce.
   */
  private User getUser(Auth.UserData data) {
    List<User> users = new List<User>();
    String upn = getUPN(data);
    if (Schema.sObjectType.User.isQueryable()) {
      users = [
        SELECT ID, USERNAME, FIRSTNAME, LASTNAME, FederationIdentifier
        FROM User
        WHERE FederationIdentifier = :upn AND isActive = true
      ];
    }

    if (users.size() > 0) {
      return users[0];
    } else {
      return null;
    }
  }

  /**
   * @description This method is used to debug the token received from Azure AD
   * @param data User data from Azure AD
   */
  private void debugToken(Auth.UserData data) {
    Map<String, String> attributeMap = data.attributeMap;

    for (String key : attributeMap.keySet()) {
      System.debug(key + ' = ' + attributeMap.get(key));
    }

    String uniqueName = attributeMap.get('unique_name');
    System.debug('---- unique_name ---- ' + uniqueName);
  }

  /**
   * @description This method returns the unique UPN value from input data
   * @param data User data from Azure AD
   * @return unique UPN value
   */

  private String getUPN(Auth.UserData data) {
    Map<String, String> attributeMap = data.attributeMap;
    String upn = attributeMap.get('unique_name');
    return upn;
  }
}
