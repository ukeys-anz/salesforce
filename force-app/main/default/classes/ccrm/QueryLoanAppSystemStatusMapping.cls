/**
 * @author Ayushi Gupta
 * @since May 2025
 * @description holds loan app system status metadata records
 */
public with sharing class QueryLoanAppSystemStatusMapping {
  private static Map<String, Loan_Application_System_Status_Mapping__mdt> loanAppSystemStatusMapping = new Map<String, Loan_Application_System_Status_Mapping__mdt>();
  static {
    for (Loan_Application_System_Status_Mapping__mdt rec : [
      SELECT
        Id,
        Application_Product_Stage__c,
        Application_Record_Type__c,
        Source_System_Status__c
      FROM Loan_Application_System_Status_Mapping__mdt
      WHERE Application_Record_Type__c = :RTApplicationForm.ambitApplicationName
      WITH SYSTEM_MODE
    ]) {
      loanAppSystemStatusMapping.put(rec.Source_System_Status__c, rec);
    }
  }

  /**
   * @description Returns a mapping metadata for source system status
   * @param sourceSystemStatus Source System Status
   * @return The metadata record associated with source system status
   */
  public static Loan_Application_System_Status_Mapping__mdt getBySourceSystemStatus(
    String sourceSystemStatus
  ) {
    return loanAppSystemStatusMapping.get(sourceSystemStatus);
  }
}
