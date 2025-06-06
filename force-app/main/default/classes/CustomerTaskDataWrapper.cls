/**
 * @author Shivam Swaraj
 * @since April 2025
 * @description  Wrapper class to create Customer Nudge Task and Notification Data
 */
public with sharing class CustomerTaskDataWrapper {
  /**
   * @description AEM_Content_Data__c from the AEM Fragement after removing merge fields
   */
  @AuraEnabled
  public String aemContentData { get; set; }

  /**
   * @description AEM_Content_Data__c from the AEM Fragement after removing merge fields
   */
  @AuraEnabled
  public CustomerActionWrapper aemContentObject { get; set; }

  /**
   * @description serializing this to update the content with deeplink
   * @return  serialized updated aem content
   */
  public String enrichedAemContentData() {
    return JSON.serialize(this.aemContentObject);
  }
}
