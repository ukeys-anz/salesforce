/**
 * @description Repository class for handling Person Digital Identity related operations
 * @author Tan Phan
 * @since 08/2025
 * @group Person Digital Entity
 */
public with sharing class PDIRepository {
  /**
   * @description Retrieves a list of devices associated with a specific person ID
   * @param personId The unique identifier of the person
   * @return List<Device__x> List of devices found for the person
   */
  public List<Device__x> getDevicesByPersonId(String personId) {
    if (String.isBlank(personId)) {
      return new List<Device__x>();
    }
    return [
      SELECT ExternalId, DeviceCorrelationId__c
      FROM Device__x
      WHERE PersonId__c = :personId
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves an access control record by its external ID
   * @param externalId The unique external identifier of the access control record
   * @return AccessControl__x The access control record found or null if none exists
   */
  public AccessControl__x getAccessControlByExternalId(String externalId) {
    return [
      SELECT ExternalId, DeviceCorrelationId__c
      FROM AccessControl__x
      WHERE ExternalId = :externalId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Get the Account record by customerId.
   * @param customerId Customer Id to search for.
   * @return List<Account> List of Account records matching the customerId.
   */
  public Account getAccountByCustomerId(String customerId) {
    return [
      SELECT Id, OCV_Id__c
      FROM Account
      WHERE
        (Id = :customerId
        OR External_Id__c = :customerId)
        AND (ANZx_Customer__c = TRUE
        OR Was_ANZx_Customer__c = TRUE)
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Get the Account record by OCV Id.
   * @param ocvId OCV Id to search for.
   * @return Account Account record matching the OCV Id.
   */
  public Account getAccountByOCVId(String ocvId) {
    return [
      SELECT Id, Name, External_Id__c
      FROM Account
      WHERE
        OCV_Id__c = :ocvId
        AND (ANZx_Customer__c = TRUE
        OR Was_ANZx_Customer__c = TRUE)
      WITH SYSTEM_MODE
      LIMIT 1
    ] ?? null;
  }
}
