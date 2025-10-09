/**
 * @author Pooja Kirtishahi
 * @since Sep 2025
 * @description Query class for Loan Application Validity metadata records
 */

public with sharing class QueryLoanApplicationValidity {
  private static List<Loan_Application_Validity__mdt> records = [
    SELECT Id, DeveloperName, MasterLabel, Days__c, Months__c, Years__c
    FROM Loan_Application_Validity__mdt
    WITH USER_MODE
  ];
  @TestVisible
  private static Map<Id, Loan_Application_Validity__mdt> recordsById = (Map<Id, Loan_Application_Validity__mdt>) ListUtil.mapBy(
    records,
    Loan_Application_Validity__mdt.Id
  );
  @TestVisible
  private static Map<String, Loan_Application_Validity__mdt> recordsByMasterLabel = (Map<String, Loan_Application_Validity__mdt>) ListUtil.mapBy(
    records,
    Loan_Application_Validity__mdt.MasterLabel
  );
  @TestVisible
  private static Map<String, Loan_Application_Validity__mdt> recordsByDeveloperName = (Map<String, Loan_Application_Validity__mdt>) ListUtil.mapBy(
    records,
    Loan_Application_Validity__mdt.DeveloperName
  );

  /**
   * @description Retrieves a record by its Id
   * @param recordId The unique identifier of the record
   * @return The corresponding record, or null if not found
   */
  public static Loan_Application_Validity__mdt getById(Id recordId) {
    return recordsById.get(recordId);
  }

  /**
   * @description Retrieves a record by its key attribute
   * @param keyValue The key attribute value to look up - MasterLabel
   * @return The corresponding record, or null if not found
   */
  public static Loan_Application_Validity__mdt getByMasterLabel(
    String keyValue
  ) {
    return recordsByMasterLabel.get(keyValue);
  }

  /**
   * @description get custom metadata type for RLA's status
   * @param keyValue Record type name with status
   * @return Loan_Application_Validity__mdt custom metadata type
   */
  public static Loan_Application_Validity__mdt getByDeveloperName(
    String keyValue
  ) {
    return recordsByDeveloperName.get(keyValue);
  }
}
