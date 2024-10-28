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
    if (oppId == null || !PermissionUtils.canQuery('OpportunityLineItem')) {
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
    ];
  }
}
