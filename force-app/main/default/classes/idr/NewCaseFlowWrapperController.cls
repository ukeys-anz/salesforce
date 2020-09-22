/**
 * @author saiero
 * @since 2020
 * @group IDR(Internal Dispute Resolution)
 * @description Controller for the lightning component wrapping the Case creation flow, currently only for Complaints.
 */
public with sharing class NewCaseFlowWrapperController {
  /**
   * @description Get the Developer Name of a Case record type based on its Id
   * @param id Record Type ID
   * @return The RT's Dev Name
   */
  @AuraEnabled
  public static String getCaseRecordTypeDevNameById(Id id) {
    return Schema.SObjectType.Case.getRecordTypeInfosById()
      .get(id)
      .getDeveloperName();
  }

  /**
   * @description Get the active Chat Topic ID (if any) by the Account ID (customer)
   * @param accountID Account ID related to the customer
   * @return String having the Active Chat Topic ID
   */
  @AuraEnabled
  public static string getActiveChatTopicIDByCustomer(Id accountID) {
    String activeChatTopicID = null;
    List<Chat_Topic__c> chatTopics = new List<Chat_Topic__c>();

    if (Chat_Topic__c.sObjectType.getDescribe().isQueryable()) {
      chatTopics = [
        SELECT Id
        FROM Chat_Topic__c
        WHERE Related_Customer__c = :accountID AND Currently_Active__c = TRUE
        ORDER BY LastModifiedDate DESC
        LIMIT 1
      ];
    }

    if (!chatTopics.isEmpty()) {
      if (chatTopics.size() == 1) {
        activeChatTopicID = chatTopics[0].Id;
      } else {
        //TODO: Log an Application Log entry including a comma seperated string of all returned Chat Topic IDs
        //TODO: Return comma seperated string of all returned Chat Topic IDs, and save it on a custom field on Case object (not visible on Page Layout) ?
      }
    }

    return activeChatTopicID;
  }
}
