/**
 * @author Karen Valeriano
 * @since 07/2024
 * @description  COBPIDViewAndEditRepository is the repository class for COBPIDViewAndEditController.
 */
public with sharing class COBPIDViewAndEditRepository {
  /**
   * @description method to query a COBPrimaryIDDocument__c record by ID
   * @param recordId Salesforce ID of the COBPrimaryIDDocument__c record from the lwc component
   * @return `COBPrimaryIDDocument__c`
   */
  public COBPrimaryIDDocument__c getCOBPIDByRecordId(String recordId) {
    return [
      SELECT
        Id,
        PersonaId__c,
        IdDocumentType__c,
        LicenceNumber__c,
        LicenceNumberOCRClient__c,
        LicenceNumberOCRServer__c,
        LicenceCardNumber__c,
        LicenceCardNumberOCRClient__c,
        LicenceCardNumberOCRServer__c,
        PassportNumber__c,
        PassportNumberOCRClient__c,
        PassportNumberOCRServer__c,
        FirstName__c,
        FirstNameOCRClient__c,
        FirstNameOCRServer__c,
        MiddleNames__c,
        MiddleNamesOCRClient__c,
        MiddleNamesOCRServer__c,
        LastName__c,
        LastNameOCRClient__c,
        LastNameOCRServer__c,
        DateOfBirth__c,
        DateOfBirthOCRClient__c,
        DateOfBirthOCRServer__c,
        StateOfIssue__c,
        StateOfIssueOCRClient__c,
        StateOfIssueOCRServer__c,
        CountryOfIssue__c,
        CountryOfIssueOCRClient__c,
        CountryOfIssueOCRServer__c,
        ExpiryDate__c,
        ExpiryDateOCRClient__c,
        ExpiryDateOCRServer__c
      FROM COBPrimaryIDDocument__c
      WHERE ID = :recordId
      WITH USER_MODE
      LIMIT 1
    ];
  }

  /**
   * @description method to get associated ID Ops Case by COB Doc's Persona ID
   * @param record the COBPrimaryIDDocument__c record
   * @return `Case` the ID Ops Case
   */
  public Case getIdOpsCase(COBPrimaryIDDocument__c record) {
    return [
      SELECT Id
      FROM Case
      WHERE
        PersonaId__c = :record.PersonaId__c
        AND RecordTypeId = :RTCase.idOpsAssistance
      WITH USER_MODE
      ORDER BY LastModifiedDate DESC
      LIMIT 1
    ] ?? null;
  }
}
