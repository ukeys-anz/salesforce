/**
 * @author       : Karen Valeriano
 * @since        : Dec 2025
 * @description  : Repository for handling API interactions related to Commercial Opportunity.
 **/
public with sharing class CommercialOpportunityAPIRepository extends RepositoryBase {
  private static final PegaCaseService SERVICE = (PegaCaseService) Lib_InstanceProvider.forType(
    PegaCaseService.class
  );

  /**
   * @description Creates the payload and publishes it to Pega Service.
   * @param opportunity The Opportunity Record.
   * @param opportunityLineItems The related Products.
   * @param relatedEntities The selected CLG Entities.
   * @return The Id of the created case in Pega.
   */
  public PegaCaseResponseModel publishCaseToPega(
    Opportunity opportunity,
    List<OpportunityLineItem> opportunityLineItems,
    List<FinServ__AccountAccountRelation__c> relatedEntities
  ) {
    PegaCaseRequestModel payload = new PegaCaseRequestModel(
      opportunity,
      opportunityLineItems,
      relatedEntities
    );
    HttpCalloutResponse response = super.processResponse(
      SERVICE.createCase(payload)
    );

    return (PegaCaseResponseModel) JSON.deserialize(
      response.body,
      PegaCaseResponseModel.class
    );
  }
}
