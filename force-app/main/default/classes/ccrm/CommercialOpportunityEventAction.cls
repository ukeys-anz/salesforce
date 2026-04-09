/**
 * @author Akanksha Kulkarni
 * @since Nov 2025
 * @group (Commercial Broker)
 * @description CommercialOpportunityEventAction is an action class for sending platform events Salesforce Opportunity to GCP
 */
public with sharing class CommercialOpportunityEventAction {
  /**
   * @description Publish commercial Opportunity to CSP via GCP.
   * @param records List of newly inserted Opportunity.
   * @param appFormRecords ApplicationForm records linked to Opportunity.
   * @param oliRecords List of OpportunityLineItem records linked to Opportunity.
   * @param allProducts List of ApplicationFormProduct records linked to Opportunity.
   * @param eventContext Context of the event.
   * @return List of successfully published Cloud_Event__e records.
   */
  @TestVisible
  public static List<Cloud_Event__e> publishApplicationFormEvent(
    List<Opportunity> records,
    Map<Id, ApplicationForm> appFormRecords,
    List<OpportunityLineItem> oliRecords,
    List<ApplicationFormProduct> allProducts,
    String eventContext
  ) {
    try {
      // Since always single record
      Opportunity opp = records.isEmpty() ? null : records[0];
      // Build payload via new method
      OpportunityEventModel.OpportunityDetails payload = buildPayload(
        records,
        appFormRecords,
        oliRecords,
        allProducts
      );

      // Build Cloud Event Model
      CommercialOpportunityEventPayloadBuilder eventModel = new CommercialOpportunityEventPayloadBuilder(
        opp,
        payload,
        eventContext
      );

      // Publish
      List<Cloud_Event__e> successPublishedEvents = CloudEventController.publishCloudEvents(
        new List<CommercialOpportunityEventPayloadBuilder>{ eventModel }
      );
      CloudEventController.logSuccessEvents(
        successPublishedEvents,
        'Commercial Opportunity Event'
      );

      return successPublishedEvents;
    } catch (Exception e) {
      Logger.error(e.getMessage(), e);
      Logger.saveLog();
      return null;
    }
  }

  /**
   * @description Extracts records and builds the Opportunity payload.
   * @param records List of newly inserted Opportunity.
   * @param appFormRecords ApplicationForm records linked to Opportunity.
   * @param oliRecords List of OpportunityLineItem records linked to Opportunity.
   * @param allProducts List of ApplicationFormProduct records linked to Opportunity.
   * @return Payload structure.
   */
  @TestVisible
  private static OpportunityEventModel.OpportunityDetails buildPayload(
    List<Opportunity> records,
    Map<Id, ApplicationForm> appFormRecords,
    List<OpportunityLineItem> oliRecords,
    List<ApplicationFormProduct> allProducts
  ) {
    // Extract single records safely
    Opportunity opp = records.isEmpty() ? null : records[0];

    ApplicationFormProduct appFormProduct = (allProducts != null &&
      !allProducts.isEmpty())
      ? allProducts[0]
      : null;

    ApplicationForm appForm = (appFormRecords != null &&
      appFormProduct != null)
      ? appFormRecords.get(appFormProduct.ApplicationFormId)
      : null;

    OpportunityLineItem oliRecord = (oliRecords != null &&
      !oliRecords.isEmpty())
      ? oliRecords[0]
      : null;

    // Build payload
    return CommercialOpportunityEventBuilder.buildOpportunityNode(
      opp,
      appForm,
      oliRecord,
      appFormProduct
    );
  }
}
