/**
 * @author Prahlad Bhadani
 * @since  01/Aug/2025
 * @group MLCRM (Moblie Lending CRM)
 * @description OpportunityContactRoleActionsHelper is class to have helper methods
 */
public with sharing class OpportunityContactRoleActionsHelper {
  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );
  private static final String RELATIONSHIP_TO_FRANCHISE = 'Primary';

  /**
   * @description This method will insert new customer relationship records.
   * @name insertCustomerRelationships
   * @param insertedRecords inserted customer relationships
   * @param existingCRRMap existing CRR map.
   * @return List<Customer_Relationship__c> list of customer relationship records to insert
   */
  public static List<Customer_Relationship__c> insertCustomerRelationships(
    List<OpportunityContactRole> insertedRecords,
    Map<String, Customer_Relationship__c> existingCRRMap
  ) {
    //new list for inserting records.
    List<Customer_Relationship__c> newCustomerRelationships = new List<Customer_Relationship__c>();
    for (OpportunityContactRole ocr : insertedRecords) {
      if (ocr.Opportunity.Territory__r?.Primary_Franchise_Owner__c == null) {
        continue;
      }

      String crrKey = generateCustomerFranchiseKey(
        ocr.Contact.AccountId,
        ocr.Opportunity.Territory__r.Primary_Franchise_Owner__c
      );
      if (existingCRRMap.containsKey(crrKey)) {
        continue;
      }
      newCustomerRelationships.add(createCRRInstance(ocr));
    }
    return newCustomerRelationships;
  }

  /**
   * @description This method will return a set of customer ids from the given OpportunityContactRole records.
   * @name getCustomerIds
   * @param insertedRecords List<OpportunityContactRole>
   * @return set of customer ids
   */
  public static Set<Id> getCustomerIds(
    List<OpportunityContactRole> insertedRecords
  ) {
    Set<Id> customerIds = new Set<Id>();
    for (OpportunityContactRole ocr : insertedRecords) {
      customerIds.add(ocr.Contact.AccountId);
    }
    return customerIds;
  }

  /**
   * @description This method will create an instance of Customer relationship record.
   * @name createCRRInstance
   * @param ocr OCR for the details.
   * @return Customer_Relationship__c record instance
   */
  @testVisible
  private static Customer_Relationship__c createCRRInstance(
    OpportunityContactRole ocr
  ) {
    Customer_Relationship__c crr = new Customer_Relationship__c();
    crr.Customer__c = ocr.Contact.AccountId;
    crr.Territory__c = ocr.Opportunity.Territory__c;
    crr.OwnerId = ocr.Opportunity.OwnerId;
    crr.Relationship_To_Franchise__c = RELATIONSHIP_TO_FRANCHISE;
    crr.Date_Relationship_Commenced__c = System.today();
    return crr;
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
}
