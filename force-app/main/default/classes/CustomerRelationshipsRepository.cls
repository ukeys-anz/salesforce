/**
 * @author MLCRM Developer
 * @since 11/2024
 * @description This class provide SOQL,DML and mocking helper for class related to Customer_Relationship__c.
 */
public with sharing class CustomerRelationshipsRepository {
  private static final String RELATIONSHIP_TO_FRANCHISE = 'Primary';

  /**
   * @description getCustomerRelationshipByAccountIds method return Customer_Relationship__c associated to the given Accountids
   * @param idsOfAcc Id of the updated Accounts
   * @return List<Customer_Relationship__c> list of Customer_Relationship__c
   * Added SYSTEM_MODE as Lead conversion process runs in SYSTEM_MODE
   */
  public List<Customer_Relationship__c> getCustomerRelationshipByAccountIds(
    Set<ID> idsOfAcc
  ) {
    if (idsOfAcc.isEmpty()) {
      return new List<Customer_Relationship__c>();
    }
    return new List<Customer_Relationship__c>(
      [
        SELECT
          Id,
          Customer_Name__c,
          Customer__c,
          Customer__r.Name,
          Customer__r.Salutation
        FROM Customer_Relationship__c
        WHERE Customer__c IN :idsOfAcc
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description getCustomerRelationshipByCustomerIds method returns Customer_Relationship__c associated to the given Accountids
   * @param idsOfCustomer Id of the updated Accounts
   * @return List<Customer_Relationship__c> list of Customer_Relationship__c
   * Added SYSTEM_MODE as Lead conversion process runs in SYSTEM_MODE
   */
  public List<Customer_Relationship__c> getCustomerRelationshipByCustomerIds(
    Set<ID> idsOfCustomer
  ) {
    if (idsOfCustomer.isEmpty()) {
      return new List<Customer_Relationship__c>();
    }
    return new List<Customer_Relationship__c>(
      [
        SELECT Id, Customer__c, Territory__r.Primary_Franchise_Owner__c
        FROM Customer_Relationship__c
        WHERE
          Customer__c IN :idsOfCustomer
          AND Relationship_To_Franchise__c = :RELATIONSHIP_TO_FRANCHISE
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description getTerritoriesbyPrimaryFranchiseOwnerIds method returns Territory__c based on Primary Franchise Owner
   * @param idsOfPrimaryOwner Id of the Primary Franchise Owner from updated records
   * @return Map<Id, Territory__c> Map of Id, Territory__c
   * Added SYSTEM_MODE as Lead conversion process runs in SYSTEM_MODE
   */
  public Map<Id, Territory__c> getTerritoriesbyPrimaryFranchiseOwnerIds(
    Set<ID> idsOfPrimaryOwner
  ) {
    if (idsOfPrimaryOwner.isEmpty()) {
      return new Map<Id, Territory__c>();
    }
    return new Map<Id, Territory__c>(
      [
        SELECT Id, Primary_Franchise_Owner__c
        FROM Territory__c
        WHERE Primary_Franchise_Owner__c IN :idsOfPrimaryOwner
        WITH SYSTEM_MODE
      ]
    );
  }

  /**
   * @description getCustRelationshipIdofShellProspectAccount method returns Customer_Relationhip__c based on Primary Franchise Owner and associated to Shell Prospect Account
   * @param strPrimaryOwnerId Id of the Primary Franchise Owner
   * @param shellProspectAccountId Id of the Shell Prospect Account
   * @return List<Customer_Relationship__c> List of Customer Relationships of Shell Prospect Account
   * Added SYSTEM_MODE as Lead conversion process runs in SYSTEM_MODE
   */
  public List<Customer_Relationship__c> getCustRelationshipIdofShellProspectAccount(
    Id strPrimaryOwnerId,
    Id shellProspectAccountId
  ) {
    if (strPrimaryOwnerId == null || shellProspectAccountId == null) {
      return new List<Customer_Relationship__c>();
    }
    return new List<Customer_Relationship__c>(
      [
        SELECT Id
        FROM Customer_Relationship__c
        WHERE
          Relationship_To_Franchise__c = :RELATIONSHIP_TO_FRANCHISE
          AND Territory__r.Primary_Franchise_Owner__c = :strPrimaryOwnerId
          AND Customer__c = :shellProspectAccountId
        WITH SYSTEM_MODE
        LIMIT 1
      ]
    );
  }

  /**
   * @description CC-2175 create CustomerRelationship against shell prospect after receiving response from cap API
   * @name getCRDetails
   * @param recordId sobject recordId from where we need to get territory details
   * @return List<SObject>
   */
  public List<SObject> getCRDetails(Id recordId) {
    if (recordId == null) {
      return new List<SObject>();
    }
    String recordQuery = String.format(
      'SELECT Id, Territory__c,Territory__r.Primary_Franchise_Owner__c FROM {0} WHERE Id = :recordId AND Territory__r.Primary_Franchise_Owner__c != null',
      new List<String>{ recordId.getSObjectType().toString() }
    );
    return Database.queryWithBinds(
      recordQuery,
      new Map<String, Object>{ 'recordId' => recordId },
      AccessLevel.SYSTEM_MODE
    );
  }
}
