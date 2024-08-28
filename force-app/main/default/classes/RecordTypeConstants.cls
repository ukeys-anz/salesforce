/**
 * @author Hrushikesh Pathak
 * @since 08/2024
 * @description RecordTypeConstants will consist of the record types constants
 */
public with sharing class RecordTypeConstants {
  /**
   * @description caseCustomerComplaint is to get record type id
   * @return Id of the record type
   */
  public static Id caseCustomerComplaint {
    get {
      return caseCustomerComplaint ??
        (caseCustomerComplaint = SObjectType.Case.getRecordTypeInfosByDeveloperName()
          .get('Customer_Complaint')
          .getRecordTypeId());
    }
    private set;
  }
}
