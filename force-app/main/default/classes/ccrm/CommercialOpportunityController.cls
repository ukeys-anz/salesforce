/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Controller class for publishToPega LWC.
 **/
public with sharing class CommercialOpportunityController {
  private static final CommercialOpportunityRepository REPOSITORY = (CommercialOpportunityRepository) Lib_InstanceProvider.forType(
    CommercialOpportunityRepository.class
  );

  /**
   * @description Returns all the related OpportunityLineItems.
   * @param opportunityId The ID of the Opportunity record.
   * @return List of OpportunityLineItem records.
   */
  @AuraEnabled
  public static List<OpportunityLineItem> getOppLineItems(Id opportunityId) {
    Set<Id> oppIds = new Set<Id>{ opportunityId };
    return REPOSITORY.getOppProductsForOpportunity(oppIds);
  }

  /**
   * @description Publishes Opportunity data to Pega system by creating a case.
   * @param opportunityId The ID of the Opportunity record.
   * @param relatedEntityIds The list of selected related entity IDs.
   * @param entityProductMapping The entity product mapping notes
   */
  @AuraEnabled
  public static void publishCaseToPega(
    Id opportunityId,
    List<Id> relatedEntityIds,
    String entityProductMapping
  ) {
    Logger.debug(
      DateTimeUtils.timeString +
      ' | CommercialOpportunityController.publishCaseToPega started'
    );

    try {
      String caseId = CommercialOpportunityHelper.processPublishCaseToPega(
        opportunityId,
        relatedEntityIds,
        entityProductMapping
      );

      // TODO: Confirm if Case Link will be included in the response
      CommercialOpportunityHelper.updateOpportunityWithPegaDetails(
        opportunityId,
        caseId,
        entityProductMapping
      );
    } catch (Exception e) {
      Logger.error('Error occured while creating Case to Pega', e).save();
      throw new AuraHandledException(e.getMessage());
    } finally {
      Logger.debug(
          DateTimeUtils.timeString +
          ' | CommercialOpportunityController.publishCaseToPega finished'
        )
        .save();
    }
  }
}
