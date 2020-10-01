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
  public static string getActiveChatTopicIDsByCustomer(Id accountID) {
    String activeChatTopicID = '';
    List<Chat_Topic__c> chatTopics = new List<Chat_Topic__c>();

    if (Chat_Topic__c.sObjectType.getDescribe().isQueryable()) {
      chatTopics = [
        SELECT Id
        FROM Chat_Topic__c
        WHERE Related_Customer__c = :accountID AND Status__c = 'Active'
        ORDER BY LastModifiedDate DESC
      ];
    }

    if (!chatTopics.isEmpty()) {
      if (chatTopics.size() == 1) {
        activeChatTopicID = chatTopics[0].Id;
      } else {
        // Return '|' seperated string of all returned Chat Topic IDs, and save it on a custom field on Case object (not visible on Page Layout) ?
        for (Chat_Topic__c topic : chatTopics) {
          activeChatTopicID += !String.isBlank(activeChatTopicID)
            ? '|' + topic.Id
            : topic.Id;
        }

        //Log an Application Log entry including the '|' seperated string of all returned Chat Topic IDs
        lib_systemLog.createSingleLog(
          NewCaseFlowWrapperController.class.getName(),
          'getActiveChatTopicIDsByCustomer',
          'MORE_THAN_ONE_ACTIVE_CHAT_TOPIC',
          'More than one "Acitve" Chat Topics found while trying to auto-link to a Case.' +
          ' - ' +
          'Chat Topic IDs :' +
          activeChatTopicID +
          ' - Account ID:' +
          accountID +
          ' - ' +
          'If user decides to save the Case (with or without a linked Chat Topic), the custom field "Auto_matched_Chat_Topic_IDs__c" on the particular Case record will me marked with auto-matched Chat Topic IDs to help troubleshooting.',
          lib_systemLog.Severity.WARNING
        );
      }
    }

    return activeChatTopicID;
  }
}
