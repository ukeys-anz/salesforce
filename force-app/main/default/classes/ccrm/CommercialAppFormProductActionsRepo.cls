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
    if (appFormIds.isEmpty() || !PermissionUtils.canQuery('ApplicationForm')) {
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
    ];
  }

  /**
   * @description getCommercialAppFormsWithAggregatedAmount to get app forms records with total app amount
   * @param oppIds opp Ids
   * @return  List<Map<String, Object>> app forms list
   */
  public List<Map<String, Object>> getCommercialAppFormsWithAggregatedAmount(
    Set<Id> oppIds
  ) {
    List<Map<String, Object>> result = new List<Map<String, Object>>();
    if (oppIds.isEmpty() || !PermissionUtils.canQuery('ApplicationForm')) {
      return result;
    }

    for (AggregateResult ar : [
      SELECT
        OpportunityId,
        SUM(Application_Amount__c) Amount,
        Opportunity.RecordTypeId
      FROM ApplicationForm
      WHERE
        OpportunityId IN :oppIds
        AND Opportunity.RecordTypeId = :RTOpportunity.commercialOpportunity
        AND Application_Amount__c != NULL
      GROUP BY OpportunityId, Opportunity.RecordTypeId
    ]) {
      result.add(ar.getPopulatedFieldsAsMap());
    }
    return result;
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
    if (
      productIds.isEmpty() ||
      oppIds.isEmpty() ||
      !PermissionUtils.canQuery('OpportunityLineItem')
    ) {
      return new List<OpportunityLineItem>();
    }
    return new List<OpportunityLineItem>(
      [
        SELECT Id, Product2Id, OpportunityId, Expected_Settlement_Date__c
        FROM OpportunityLineItem
        WHERE Product2Id IN :productIds AND OpportunityId IN :oppIds
      ]
    );
  }
}
