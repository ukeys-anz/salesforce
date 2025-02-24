/**
 * @author MLCRM Developer
 * @since 11/2024
 * @description This class provide SOQL,DML and mocking helper for class related to Customer_Relationship__c.
 */
public with sharing class CustomerRelationshipsRepository {
  /**
   * @description getCustomerRelationshipByAccountIds method return Customer_Relationship__c associated to the given Accountids
   * @param idsOfAcc Id of the updated Accounts
   * @return List<Customer_Relationship__c> list of Customer_Relationship__c
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
}
