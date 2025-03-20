/**
 * @author MLCRM Developer
 * @since 07/2024
 * @description This class provide SOQL,DML and mocking helper for class related to MLCRMLeadActions.
 */
public with sharing class LeadActionsRepository {
  private static final String ADMIN_PROFILE_NAME = 'System Administrator';
  private static final String CLG = 'Customer Lending Group';
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

  /**
   * @description to query account account relationship records
   * @name getAccountAccountRelations
   * @param accountIdsSet set of Account Ids
   * @return List<FinServ__AccountAccountRelation__c>
   */
  public List<FinServ__AccountAccountRelation__c> getAccountAccountRelations(
    Set<Id> accountIdsSet
  ) {
    if (accountIdsSet.isEmpty()) {
      return new List<FinServ__AccountAccountRelation__c>();
    }

    return [
      SELECT
        Id,
        Name,
        Relationship__c,
        FinServ__Account__c,
        FinServ__RelatedAccount__c,
        FinServ__RelatedAccount__r.CLG__c,
        FinServ__RelatedAccount__r.CPID__c,
        FinServ__RelatedAccount__r.RecordTypeId,
        FinServ__RelatedAccount__r.Controlling_Post__r.OwnerId
      FROM FinServ__AccountAccountRelation__c
      WHERE
        FinServ__Account__c IN :accountIdsSet
        AND Relationship__c = :CLG
        AND FinServ__RelatedAccount__r.RecordTypeId = :RTAccount.clgAccount
      WITH USER_MODE
    ];
  }
}
