/**
 * @author Naman Garg
 * @since 09/2024
 * @description This class provide SOQL and DML helper for class related to CCRMContactActions.
 */

public with sharing class CommercialContactRepository {
  /**
   * @description It will fetch the current user's user name
   * @return String userName of the current user
   */
  public String getUserName() {
    return UserInfo.getUserName();
  }
}
