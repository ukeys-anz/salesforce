/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description Builder class to build the GCP Event for the Opportunity Data
 */
public with sharing class CommercialOpportunityEventBuilder {
  /**
   * @description Build simplified JSON payload for Opportunity event
   * @param opp newly inserted Opportunity.
   * @param appForm ApplicationForm record linked to Opportunity.
   * @param oli OpportunityLineItem record linked to Opportunity.
   * @param appFormProduct ApplicationFormProduct record linked to Opportunity.
   * @return Payload structure
   */
  public static OpportunityEventModel.OpportunityDetails buildOpportunityNode(
    Opportunity opp,
    ApplicationForm appForm,
    OpportunityLineItem oli,
    ApplicationFormProduct appFormProduct
  ) {
    if (opp == null) {
      return new OpportunityEventModel.OpportunityDetails();
    }
    String externalId = opp.Account?.External_Id__c;
    String sourceSystemId = opp.Account?.Source_System_Id__c;

    // Default assignments
    String capcisId = null;
    String cacheId = sourceSystemId;

    // Override only if the CAP-CIS condition matches
    if (externalId != null && externalId.startsWith('CAP-CIS')) {
      capcisId = sourceSystemId;
      cacheId = null;
    }

    // Build payload structure
    OpportunityEventModel.OpportunityDetails node = new OpportunityEventModel.OpportunityDetails();

    node.orderID = (appForm != null &&
      appForm.Reference_Number__c != null)
      ? appForm.Reference_Number__c
      : null;
    node.capcisId = capcisId;
    node.cacheID = cacheId;
    node.quoteReferenceNumber = appFormProduct != null
      ? appFormProduct.Reference_Number__c
      : null;
    node.opportunityId = opp.Id;
    node.opportunityProductRowId = (oli != null) ? oli.Id : null;

    return node;
  }
}
