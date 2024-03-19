/**
 * @author CMOS
 * @since  03/2024
 * @description IDRCaseActionsHelper is class to handle all the IDR (Internal Dispute Resolution) Actions
 * @group IDR(Internal Dispute Resolution)
 */
public with sharing class IDRCaseActionsHelper {
  /**
   * @description Populate Date/time Registration Response Provided when AFCA Registration Response Provided is checked
   * @param oldRecord old Record of pre-update cases supplied from the trigger as well
   * @param newRecord new Record of cases from the trigger
   * @return DateTime
   */
  public static DateTime populateAfcaRegistrationResponseDate(
    Case oldRecord,
    Case newRecord
  ) {
    if (
      oldRecord.IDR_AFCA_Registration_Response_Provided__c ==
      newRecord.IDR_AFCA_Registration_Response_Provided__c
    ) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }

    if (!newRecord.IDR_AFCA_Registration_Response_Provided__c) {
      return newRecord.Date_time_Registration_Response_Provided__c;
    }
    return DateTime.now();
  }
}
