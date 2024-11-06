/**
 * @author       : Ayushi Gupta
 * @since        : 21-08-2024
 * @description  : This class contains public repository for all queries used in CommercialAppFormProductActions
 **/
public class CommercialAppFormProductActionsRepo {
  /**
   * @description getApplicationForms to get app forms records related to commercial opp
   * @param appFormIds set of new app form ids
   * @return List<ApplicationForm> app forms list
   */
  public List<ApplicationForm> getApplicationForms(Set<Id> appFormIds) {
    if (appFormIds.isEmpty()) {
      return new List<ApplicationForm>();
    }
    return [
      SELECT
        Id,
        OpportunityId,
        Opportunity.RecordTypeId,
        Opportunity.closeDate,
        (SELECT Id, ApplicationFormId FROM ApplicationFormProducts)
      FROM ApplicationForm
      WHERE
        Id IN :appFormIds
        AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
      WITH USER_MODE
    ];
  }

  /**
   * @description getOppProductRelatedToAFP - To fetch the product related to Application Form Product
   * @param productIds - Ids of Products on AFP
   * @param oppIds - List of Opportunity
   * @return  List<OpportunityLineItem> Opportunity line item list
   */
  public List<OpportunityLineItem> getOppProductRelatedToAFP(
    Set<Id> productIds,
    Set<Id> oppIds
  ) {
    if (productIds.isEmpty() || oppIds.isEmpty()) {
      return new List<OpportunityLineItem>();
    }
    return new List<OpportunityLineItem>(
      [
        SELECT Id, Product2Id, OpportunityId, Expected_Settlement_Date__c
        FROM OpportunityLineItem
        WHERE Product2Id IN :productIds AND OpportunityId IN :oppIds
        WITH USER_MODE
      ]
    );
  }
}
