/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL,DML and mocking helper for class related to MLCRMLeadActions.
 */
public with sharing class LeadActionsRepository {
  private static final String ADMIN_PROFILE_NAME = 'System Administrator';
  /**
   * @description to check if the user have 'ML_Allow_Lead_Creation' custom permission
   * @name isAllowLeadCreationCustomPermission
   * @return Boolean true if the user have 'ML_Allow_Lead_Creation' custom permission
   */
  public Boolean isAllowLeadCreationCustomPermission() {
    return FeatureManagement.checkPermission('ML_Allow_Lead_Creation');
  }

  /**
   * @description Check whether the logged in user is Admin User
   * @return Boolean True if a user is Admin User false otherwise
   */
  public Boolean isCurrentUserAdmin() {
    return (UserInfo.getProfileId() ==
    CommonUtil.getProfileByName(ADMIN_PROFILE_NAME).Id);
  }
}
