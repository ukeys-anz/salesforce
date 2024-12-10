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
      SELECT Id, Product2Id, UnitPrice
      FROM OpportunityLineItem
      WHERE Id IN :oppLineItemsIds
      WITH USER_MODE
    ];
  }
}
