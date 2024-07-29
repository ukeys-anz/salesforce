/**
 * @author Naman Garg
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to CCRMLeadActions.
 */

public with sharing class CCRMLeadRepository {
  /**
   * @description It will fetch the user Profile Id
   * @return Id Profile Id of the current user
   */
  public Id getUserProfileId() {
    return UserInfo.getProfileId();
  }
}
