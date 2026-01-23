/**
 * @author Naman Garg
 * @since  Jun 2025
 * @description This is the Repository class for CommercialOppLineItemActions
 */
public with sharing class CommercialOppLineItemRepository {
  private static final Set<Id> AF_RT_SET = new Set<Id>{
    RTApplicationForm.ambitApplication,
    RTApplicationForm.bbdApplication,
    RTApplicationForm.acmApplication,
    RTApplicationForm.internalApplication,
    RTApplicationForm.ocpApplication
  };

  /**
   * @description This is used to fetch opp line items related to commercial Opp
   * @name getOliRecords
   * @param oliIdsSet Set of Opp line item ids
   * @return List<OpportunityLineItem> List of OLI records
   */
  public List<OpportunityLineItem> getOliRecords(Set<Id> oliIdsSet) {
    if (oliIdsSet.isEmpty()) {
      return new List<OpportunityLineItem>();
    }

    return [
      SELECT Id, Product2Id, OpportunityId, Opportunity.RecordTypeId
      FROM OpportunityLineItem
      WHERE
        Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
        AND Id IN :oliIdsSet
      WITH USER_MODE
    ];
  }

  /**
   * @description This is used to fetch App form product
   * @name getAppFormProduct
   * @param oppIdsSet Set of Opportunity ids
   * @return List<ApplicationFormProduct> List of APF records
   */
  public List<ApplicationFormProduct> getAppFormProduct(Set<Id> oppIdsSet) {
    if (oppIdsSet.isEmpty()) {
      return new List<ApplicationFormProduct>();
    }

    return [
      SELECT
        Id,
        ApplicationFormId,
        ProductId,
        ApplicationForm.RecordTypeId,
        ApplicationForm.OpportunityId,
        ApplicationForm.Opportunity.RecordTypeId
      FROM ApplicationFormProduct
      WHERE
        ApplicationForm.OpportunityId IN :oppIdsSet
        AND ApplicationForm.RecordTypeId IN :AF_RT_SET
      WITH USER_MODE
    ];
  }

  /**
   * @description To fetch the Opportunity records
   * @param oppIdsSet Set of Opportunity Ids
   * @return List<Opportunity> opp List
   */
  public List<Opportunity> getOpportunityRecords(Set<Id> oppIdsSet) {
    return new List<Opportunity>(
      [
        SELECT Id, Name, RecordTypeId
        FROM Opportunity
        WHERE
          Id IN :oppIdsSet
          AND RecordTypeId = :RTOpportunity.commercialOpportunity
        WITH USER_MODE
      ]
    );
  }

  /**
   * @description To fetch the existing Opportunity Line Items records
   * @param oppIdsSet Set of Opportunity Ids
   * @return List<OpportunityLineItem> list of Opportunity Line Items records
   */
  public List<OpportunityLineItem> getExistingOLIsList(Set<Id> oppIdsSet) {
    return [
      SELECT Id, OpportunityId, Product2Id, Opp_Product_Name__c
      FROM OpportunityLineItem
      WHERE
        OpportunityId IN :oppIdsSet
        AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
      WITH USER_MODE
      ORDER BY Createddate DESC
    ];
  }

  /**
   * @description To fetch the existing product
   * @param productIdsSet Set of Product Ids
   * @return Map<Id, Product2> Map of Products
   */
  public Map<Id, Product2> getProductMap(Set<Id> productIdsSet) {
    return new Map<Id, Product2>(
      [
        SELECT Id, Name
        FROM Product2
        WHERE Id IN :productIdsSet
        WITH USER_MODE
      ]
    );
  }
}
