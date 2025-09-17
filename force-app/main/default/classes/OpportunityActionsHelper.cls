/**
 * @author Prahlad Bhadani
 * @since  01/Aug/2025
 * @description OpportunityActionsHelper is class to have helper methods
 */
public with sharing class OpportunityActionsHelper {
  private static final OpportunityActionsRepository OPPACTION_REPOSITORY = (OpportunityActionsRepository) Lib_InstanceProvider.forType(
    OpportunityActionsRepository.class
  );
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String RELATIONSHIP_TO_FRANCHISE = 'Primary';

  /**
   * @description This method will get a map of customer relationships
   * against a combined key of customer id and primary franchise owner of the territory.
   * @name getExistingCRRMap
   * @param existingCustomerRelationships customer id
   * @return Map<String, Customer_Relationship__c>
   */
  public static Map<String, Customer_Relationship__c> getExistingCRRMap(
    List<Customer_Relationship__c> existingCustomerRelationships
  ) {
    Map<String, Customer_Relationship__c> existingCRRMap = new Map<String, Customer_Relationship__c>();
    for (Customer_Relationship__c crr : existingCustomerRelationships) {
      if (crr.Territory__r?.Primary_Franchise_Owner__c == null) {
        continue; // Skip if Primary Franchise Owner is null
      }
      String crrKey = generateCustomerFranchiseKey(
        crr.Customer__c,
        crr.Territory__r.Primary_Franchise_Owner__c
      );
      existingCRRMap.put(crrKey, crr);
    }
    return existingCRRMap;
  }

  /**
   * @description This method will insert new customer relationship records.
   * @name insertCustomerRelationships
   * @param existingCrrMap customer id
   * @param nonLeadConvertedOpportunities non lead converted opps
   * @return List<Customer_Relationship__c>
   */
  public static List<Customer_Relationship__c> insertCustomerRelationships(
    Map<String, Customer_Relationship__c> existingCrrMap,
    List<Opportunity> nonLeadConvertedOpportunities
  ) {
    //new list for inserting records.
    List<Customer_Relationship__c> newCustomerRelationships = new List<Customer_Relationship__c>();
    //get territory ids from the opportunities
    Map<Id, Territory__c> idVsTerritoryMap = OPPACTION_REPOSITORY.getTerritories(
      ListUtil.getIds(nonLeadConvertedOpportunities, Opportunity.Territory__c)
    );
    for (Opportunity opp : nonLeadConvertedOpportunities) {
      Territory__c oppTerritory = idVsTerritoryMap.get(opp.Territory__c);
      if (oppTerritory?.Primary_Franchise_Owner__c == null) {
        continue;
      }
      String crrKey = generateCustomerFranchiseKey(
        opp.AccountId,
        oppTerritory.Primary_Franchise_Owner__c
      );
      if (existingCrrMap.containsKey(crrKey)) {
        continue;
      }
      newCustomerRelationships.add(createCRRInstance(opp));
    }
    return newCustomerRelationships;
  }

  /**
   * @description This method will create an instance of Customer relationship record.
   * @name generateCustomerFranchiseKey
   * @param customerId customer id
   * @param franchiseOwnerId franchise owner id
   * @return String
   */
  @testvisible
  private static String generateCustomerFranchiseKey(
    Id customerId,
    Id franchiseOwnerId
  ) {
    return String.valueOf(customerId) + String.valueOf(franchiseOwnerId);
  }

  /**
   * @description This method will create an instance of Customer relationship record.
   * @name createCRRInstance
   * @param opp opportunity for the details.
   * @return Customer_Relationship__c
   */
  private static Customer_Relationship__c createCRRInstance(Opportunity opp) {
    Customer_Relationship__c crr = new Customer_Relationship__c();
    crr.Customer__c = opp.AccountId;
    crr.Territory__c = opp.Territory__c;
    crr.OwnerId = opp.OwnerId;
    crr.Relationship_To_Franchise__c = RELATIONSHIP_TO_FRANCHISE;
    crr.Date_Relationship_Commenced__c = System.today();
    return crr;
  }
}
