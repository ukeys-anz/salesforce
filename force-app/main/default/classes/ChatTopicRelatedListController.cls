/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
public with sharing class ChatTopicRelatedListController {
  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topics related to account.
   *
   * @param accountId from the lwc component
   * @return List<Chat_Topic__c>
   */
  @AuraEnabled(cacheable=true)
  public static list<Chat_Topic__c> getChatTopicsFromAccount(String accountId) {
    List<Chat_Topic__c> chatTopicList;
    if (Chat_Topic__c.sObjectType.getDescribe().isQueryable()) {
      chatTopicList = [
        SELECT Id, Name, Status__c, LastModifiedDate, Twilio_Channel_SID__c
        FROM Chat_Topic__c
        WHERE Related_Customer__c = :accountId
        ORDER BY LastModifiedDate DESC
      ];
    }

    if (chatTopicList.isEmpty()) {
      return null;
    }

    return chatTopicList;
  }

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topic related to case.
   *
   * @param caseId from lwc component
   * @return List<Chat_Topic__c>
   */
  @AuraEnabled(cacheable=true)
  public static List<Case> getChatTopicFromCase(String caseId) {
    List<Case> caseList;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      caseList = [
        SELECT
          Id,
          Chat_Topic__r.Name,
          Chat_Topic__r.Status__c,
          Chat_Topic__r.LastModifiedDate,
          Chat_Topic__r.Twilio_Channel_SID__c
        FROM Case
        WHERE Id = :caseId AND Chat_Topic__c != NULL
      ];
    }

    if (caseList.isEmpty()) {
      return null;
    }

    return caseList;
  }
}
