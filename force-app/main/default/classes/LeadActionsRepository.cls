/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL and DML helper for class related to MLCRMLeadActions.
 */
public with sharing class LeadActionsRepository {
  /**
   * @description getTerrritories method return Territories associated to teh given ids of the Territory
   * @param idsOfTerritory Id of the Territories
   * @return List<Territory__c> Territory__c List
   */
  public List<Territory__c> getTerrritories(Set<ID> idsOfTerritory) {
    if (!Schema.sObjectType.Territory__c.isQueryable()) {
      return new List<Territory__c>();
    }
    if (idsOfTerritory.isEmpty()) {
      return new List<Territory__c>();
    }
    return [
      SELECT Id, Primary_Franchise_Owner__c
      FROM Territory__c
      WHERE Id IN :idsOfTerritory
      WITH SECURITY_ENFORCED
    ];
  }
  /**
   * @description to check if the user is Unica/Adobe/System Admin or have' ML_Allow_Lead_Creation' custom permission
   * @name isSkipValidationUser
   * @return Boolean true if the user is Unica/Adobe/System Admin or have' ML_Allow_Lead_Creation' custom permission
   */
  public Boolean isSkipValidationUser() {
    String currUsername = UserInfo.getUserName();
    return (currUsername.startsWith(Label.UnicaIntegrationUserName) ||
    currUsername.startsWith(Label.AdobeIntegrationUserName) ||
    UserInfo.getProfileId() ==
    CommonUtil.getProfileByName(MLCRMConstants.ADMIN_PROFILE_NAME).Id ||
    FeatureManagement.checkPermission('ML_Allow_Lead_Creation'));
  }
}
