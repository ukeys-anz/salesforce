/**
 * @description Provide database operation for {@link ProfileStagingTracker}
 * @author Tan Phan
 * @since 06/2024
 */
public with sharing class ProfileStagingRepository {
  /**
   * @description Queries customer profile updates along with customer info based on the provided list of records.
   * @param records The list of customer profile update records to query.
   * @return A list of customer profile update records matching the provided IDs.
   */
  public List<Customer_Profile_Updates__c> queryCustomerProfileUpdates(
    List<Customer_Profile_Updates__c> records
  ) {
    if (records.isEmpty()) {
      return new List<Customer_Profile_Updates__c>();
    }
    return [
      SELECT Id, Customer_Name__r.RecordType.DeveloperName
      FROM Customer_Profile_Updates__c
      WHERE Id IN :records
      WITH USER_MODE
    ];
  }
}
