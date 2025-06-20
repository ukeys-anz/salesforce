/**
 * @description repository class for ManageExtraCare coontroller
 * @author Shivsharan Giram
 * @since 05/2025
 */
public with sharing class ManageExtraCareControllerRepository {
  /**
   * @description Queries customer profile updates record by Customer Id.
   * @param accountId The Id of the customer account to query.
   * @return A customer profile update records matching the provided account Id.
   */
  public Customer_Profile_Updates__c queryCustomerProfileUpdateRecordByCustomerId(
    Id accountId
  ) {
    return [
      SELECT Status__c
      FROM Customer_Profile_Updates__c
      WHERE
        Customer_Name__c = :accountId
        AND TriggeredFrom__c = 'Account.Individual.ExtraCare'
      WITH SYSTEM_MODE
      ORDER BY CreatedDate DESC
      LIMIT 1
    ] ?? null;
  }
}
