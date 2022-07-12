/**
 * @author Sahil S
 * @since  10/2021
 * @group CCRM (Commercial CRM)
 * @description CCRMCampaignFlexFieldActions is class to handle all the CCRM (Commercial CRM) Actions
 */
public with sharing class CCRMCampaignFlexFieldActions {
  /**
   * @global declarations.
   */

  /**
   * @description Before Insert CCRM Campaign_Flex_Field__c Actions.
   * @name populateUUID
   * @param records from the trigger
   */
  public static void populateUUID(List<Campaign_Flex_Field__c> records) {
    for (Campaign_Flex_Field__c record : records) {
      if (String.isBlank(record.UUID__C)) {
        record.UUID__C = CommonUtil.generateUUID();
      }
    }
  }
}
