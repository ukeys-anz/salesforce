/**
 * @author Mairaj Haider
 * @since  06/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMOpportunityLineItemActions is class to handle all the CCRM Opportunity Line Item Actions
 */
public with sharing class CCRMOpportunityLineItemActions {
  public static final String LEGAL_ENTITY_REQUIRED = 'Please review your previous product line item and choose a legal entity prior to selecting a new product.';
  /**
   * @description This method will validate whether legal entity missing on previously added opportunity product
   * @name validateLegalEntityExist
   * @param records List of Opportunity Products
   * @param oldMap Map of old records of Opportunity Products
   */
  public static void validateLegalEntityExist(
    List<OpportunityLineItem> records,
    Map<Id, OpportunityLineItem> oldMap
  ) {
    Set<Id> oppIds = new Set<Id>();
    for (OpportunityLineItem record : records) {
      oppIds.add(record.OpportunityId);
    }
    //Get all opportunity products for an opportunity based on opportunity Id
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    if (Schema.sObjectType.OpportunityLineItem.isQueryable()) {
      oliList = [
        SELECT Id, Has_Legal_Entity__c, OpportunityId
        FROM OpportunityLineItem
        WHERE opportunityId IN :oppIds
      ];
    }

    for (OpportunityLineItem oli : oliList) {
      for (OpportunityLineItem record : records) {
        if (
          oli.OpportunityId == record.OpportunityId && !oli.Has_Legal_Entity__c
        ) {
          record.addError(LEGAL_ENTITY_REQUIRED);
        }
      }
    }
  }
}
