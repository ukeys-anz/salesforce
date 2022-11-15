/**
 * @author Mairaj H
 * @since  04/2022
 * @group CCRM (Commercial CRM)
 * @description CCRMLeadActionsHelper is a helper class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CCRMLeadActionsHelper {
  /**
   * @description Set field CCRM_Duplicate_Block__c to true if the lead's status is New or In progress
   * @name setDuplicateBlock
   * @param record current record
   * @param oldRec old record
   */
  public static void setDuplicateBlock(Lead record, Lead oldRec) {
    if (
      record.Status == CCRMConstants.STATUS_NEW ||
      record.Status == CCRMConstants.STATUS_IN_PROGRESS
    ) {
      record.CCRM_Duplicate_Block_Check__c = 'Yes';
    } else {
      record.CCRM_Duplicate_Block_Check__c = 'No';
    }
  }
}
