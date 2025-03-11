/**
 * @author       : Advait Yermalkar
 * @since        : 02-06-2025
 * @description  : This class provide SOQL and DML helper for class related to CommercialLeadConversionHelper
 **/
public with sharing class CommercialLeadConversionRepository {
  /**
   * @description return Accounts using ExternalId
   * @param externalId ExternalId of Account
   * @return  Account instance
   */
  public Account getAccountUsingExternalId(String externalId) {
    if (externalId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        External_Id__c,
        Name,
        FinServ__KYCStatus__c,
        CLG__c,
        RecordTypeId
      FROM Account
      WHERE External_Id__c = :externalId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description fetch ocv user
   * @name getOCVUser
   * @return User fetching OCV user
   */
  public User getOCVUser() {
    return [
      SELECT Id
      FROM USER
      WHERE Username = :System.Label.CCRM_OCVIntegrationUsername
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description return lead Owner Lan Id
   * @param leadOwnerId
   * @return User user record
   */
  public User getLeadOwnerLanId(Id leadOwnerId) {
    if (leadOwnerId == null) {
      return null;
    }
    return [
      SELECT ID, Lan_Id__c
      FROM User
      WHERE Id = :leadOwnerId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Check whether the user has lead update permission
   * @return Boolean True if the lead is updatable
   */
  public Boolean isLeadCAPCISUpdatable() {
    return (Schema.sObjectType.Lead.isUpdateable() &&
    Schema.sObjectType.Lead.fields.Skip_Validations__c.isUpdateable() &&
    Schema.sObjectType.Lead.fields.FinServ__RelatedAccount__c.isUpdateable() &&
    Schema.sObjectType.Lead.fields.CAPCIS_ID__c.isUpdateable());
  }
}
