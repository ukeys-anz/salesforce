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
        UnitPrice
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppId
      WITH USER_MODE
    ];
  }
  /**
   * @description get opp line items related to product and Opportunity
   * @name getOpportunityLineItemsRelatedToProduct
   * @param oppId opportunity Id
   * @param productIds product Ids Set
   * @return List<OpportunityLineItem> opp line items list
   */
  public List<OpportunityLineItem> getOpportunityLineItemsRelatedToOppAndProduct(
    Id oppId,
    Set<Id> productIds
  ) {
    if (oppId == null || productIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return [
      SELECT Id, Product2Id, UnitPrice, OpportunityId
      FROM OpportunityLineItem
      WHERE OpportunityId = :oppId AND Product2Id IN :productIds
      WITH USER_MODE
    ];
  }
}
