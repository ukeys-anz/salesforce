/**
 * @author Prahlad Bhadani
 * @since  10/2025
 * @group Platform
 * @description OCV Duplicate table controller repository class.
 */
public with sharing class OCVDuplicateTableControllerRepository {
  /**
   * @description getCustomer detail
   * @name getCustomer
   * @param recordId String account record id.
   * @return Account
   */
  public Account getCustomer(String recordId) {
    if (String.isBlank(recordId)) {
      return null;
    }
    return [
      SELECT OCV_Id__c, Source_System_Name__c
      FROM Account
      WHERE Id = :recordId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description getAllCustomers
   * @name getAllCustomers
   * @param ocvId String ocv id.
   * @param sourceSystemName Source system value
   * @return List<Account>
   */
  public List<Account> getAllCustomers(String ocvId, String sourceSystemName) {
    if (String.isBlank(ocvId)) {
      return new List<Account>();
    }
    return [
      SELECT Id, Name, Source_System_Name__c, Source_System_ID__c, OCV_ID__c
      FROM Account
      WHERE OCV_ID__c = :ocvId AND Source_System_Name__c = :sourceSystemName
      WITH USER_MODE
      LIMIT 10
    ];
  }
}
