/**
 * @author Sahil S
 * @since  10/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMCampaignDocumentActions is class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CCRMCampaignDocumentActions {
  /**
   * @global declarations.
   */

  /**
   * @description Before Inser CCRM Campaign_Document__c Actions.
   * @name populateUUID
   * @param records from the trigger
   */
  public static void populateUUID(List<Campaign_Document__C> records) {
    for (Campaign_Document__c record : records) {
      if (String.isBlank(record.UUID__C)) {
        record.UUID__C = CommonUtil.generateUUID();
      }
    }
  }
}
