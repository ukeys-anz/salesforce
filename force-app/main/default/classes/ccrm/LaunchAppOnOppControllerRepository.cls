/**
 * @author Ayushi Gupta
 * @since  08/2024
 * @description Repo class for LaunchAppOnOppController
 */
public with sharing class LaunchAppOnOppControllerRepository {
  /**
   * @description get opp line items related to opp
   * @name getOpportunityLineItems
   * @param oppId opportunity Id
   * @return List<OpportunityLineItem> opp line items list
   */
  public List<OpportunityLineItem> getOpportunityLineItems(Id oppId) {
    if (oppId == null) {
      return new List<OpportunityLineItem>();
    }
    return [
      SELECT
        Id,
        OpportunityId,
        Product2Id,
        Product2.Name,
        Funding_purpose__c,
        UnitPrice,
        Opp_Product_name__c
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppId
      WITH USER_MODE
    ];
  }
  /**
   * @description get opp line items related to product and Opportunity
   * @name getSelectedOppLineItems
   * @param oppLineItemsIds opp line items Ids Set
   * @return List<OpportunityLineItem> opp line items list
   */
  public List<OpportunityLineItem> getSelectedOppLineItems(
    Set<Id> oppLineItemsIds
  ) {
    if (oppLineItemsIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return [
      SELECT Id, Product2Id, UnitPrice, OpportunityId, Opportunity.Opp_Id__c
      FROM OpportunityLineItem
      WHERE Id IN :oppLineItemsIds
      WITH USER_MODE
    ];
  }

  /**
   * @description get app form products related to opp
   * @name getAppFormProductsRelatedToOpp
   * @param oppId opp Id
   * @param recordTypeName  app form record type name
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<ApplicationFormProduct> getAppFormProductsRelatedToOpp(
    Id oppId,
    String recordTypeName
  ) {
    if (
      oppId == null ||
      recordTypeName != RTApplicationForm.ambitApplicationName
    ) {
      return new List<ApplicationFormProduct>();
    }
    return [
      SELECT
        Id,
        Source_System_Id__c,
        ApplicationForm.OpportunityId,
        ApplicationForm.RecordTypeId,
        ApplicationForm.RecordType.DeveloperName
      FROM ApplicationFormProduct
      WHERE
        ApplicationForm.OpportunityId = :oppId
        AND ApplicationForm.RecordTypeId = :RTApplicationForm.ambitApplication
      WITH USER_MODE
    ];
  }

  /**
   * @description get app form products not related to AMBIT
   * @name getAppFormProductsNotRelatedToAMBIT
   * @param oppId opp Id
   * @return List<ApplicationFormProduct> app form products list
   */
  public List<ApplicationFormProduct> getAppFormProductsNotRelatedToAMBIT(
    Id oppId
  ) {
    if (oppId == null) {
      return new List<ApplicationFormProduct>();
    }
    return [
      SELECT
        Id,
        Opportunity_Product__c,
        Opportunity_Product__r.Name,
        ApplicationForm.OpportunityId,
        ApplicationForm.RecordTypeId,
        Opportunity_Product__r.Opp_Product_name__c
      FROM ApplicationFormProduct
      WHERE
        ApplicationForm.OpportunityId = :oppId
        AND ApplicationForm.RecordTypeId != :RTApplicationForm.ambitApplication
      WITH USER_MODE
    ];
  }

  /**
   * @description get field values
   * @name getOppIdAndSourceSystemId
   * @param oppId opp Id
   * @return Opportunity opportunity record
   */
  public Opportunity getOppIdAndSourceSystemId(Id oppId) {
    return [
      SELECT Id, Opp_Id__c, Account.Source_System_ID__c
      FROM Opportunity
      WHERE Id = :oppId
      WITH USER_MODE
    ] ?? null;
  }

  /**
   * @description get the Opportunity and its related object field value
   * @name getOpportunityData
   * @param oppId Opportunity Id
   * @return Opportunity Opportunity record
   */
  public Opportunity getOpportunityData(Id oppId) {
    return [
      SELECT
        Id,
        AccountId,
        Opp_Id__c,
        Account.RecordType.Name,
        Broker_Name__c,
        Broker_Name__r.Broker_Accreditation_Type__c,
        Broker_Name__r.Asset_Finance_Accreditation_Status__c,
        Owner.Lan_Id__c,
        Broker_Name__r.AssetFinanceTPMISAO__c,
        Account.Source_System_ID__c,
        (
          SELECT Id, User.Name, TeamMemberRole, User.Lan_Id__c
          FROM OpportunityTeamMembers
          WHERE TeamMemberRole = 'Asset Finance'
          ORDER BY Createddate DESC
          LIMIT 1
        )
      FROM Opportunity
      WHERE Id = :oppId
      WITH USER_MODE
    ];
  }
}
