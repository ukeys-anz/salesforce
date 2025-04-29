/**
 * @author Naman Garg
 * @since  Feb 2025
 * @description Repo class for CCRMLogAResponseController
 */

public with sharing class LogAResponseControllerRepository {
  /**
   * @description To get the lead info
   * @name getLeadInfo
   * @param leadId Id of Lead
   * @return Lead lead record
   */
  public Lead getLeadInfo(Id leadId) {
    if (leadId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        RecordTypeId,
        Primary_Contact_Method__c,
        Home_Phone__c,
        MobilePhone,
        Work_Phone__c
      FROM Lead
      WHERE Id = :leadId
      WITH USER_MODE
    ] ?? null;
  }
}
