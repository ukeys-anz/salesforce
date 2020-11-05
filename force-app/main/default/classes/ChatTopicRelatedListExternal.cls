/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
public with sharing class ChatTopicRelatedListExternal {
  /**
   * @description This method is used in chatTopicRelatedList lwc component to retrive chat topics from External Object.
   *
   * @param objectName from the lwc component
   * @param fieldValue from the lwc component
   * @return List<channels__x>
   */
  @AuraEnabled(cacheable=true)
  public static list<channels__x> getChatTopics(
    String objectName,
    String fieldValue
  ) {
    List<channels__x> channelList;

    if (channels__x.sObjectType.getDescribe().isQueryable()) {
      if (objectName == 'Account') {
        channelList = [
          SELECT ExternalId, Name__c, Status__c, UpdatedDate__c
          FROM channels__x
          WHERE MemberId__c = :fieldValue
        ];
      } else if (objectName == 'Case') {
        channelList = [
          SELECT ExternalId, Name__c, Status__c, UpdatedDate__c
          FROM channels__x
          WHERE ExternalId = :fieldValue
        ];
      }
    }

    if (channelList.isEmpty()) {
      return null;
    }

    return channelList;
  }
}
