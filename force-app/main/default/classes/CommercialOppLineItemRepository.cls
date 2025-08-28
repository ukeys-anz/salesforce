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
}
