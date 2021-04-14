/**
 * @author Boobalakrishnan Duraisamy, Jasmine Nguyen
 * @since 10 2020
 * @lastModified: March 2021
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class ChatTopicRelatedListController {
  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topics related to account.
   *
   * @param accountId Salesforce ID of the Account record from the lwc component
   * @param nextURL URL substring related to next offset (if there is a next) from API the response
   * @return String
   */
  @AuraEnabled(cacheable=false)
  public static ChatChannelModel getChatTopicsOnAccount(
    String accountId,
    String nextURL
  ) {
    // Query for Customer OCV ID by passing in the Account ID
    String ocvId;
    if (Account.sObjectType.getDescribe().isQueryable()) {
      List<Account> accounts = [
        SELECT OCV_ID__c
        FROM Account
        WHERE Id = :accountId
      ];
      if (!accounts.isEmpty()) {
        ocvId = accounts[0].OCV_ID__c;
      }

      if (String.isNotBlank(ocvID)) {
        // Make a callout to Twilio Service to fetch all Chat Topics related to the customer
        CallCenterAPIRepository ccap = new CallCenterAPIRepository();
        ChatChannelModel responseBody = ccap.getChatTopicsByCustomer(
          ocvId,
          nextURL
        );

        return responseBody;
      }
    }

    return null;
  }

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topic related to case.
   *
   * @param caseId from lwc component
   * @return String
   */
  @AuraEnabled(cacheable=false)
  public static ChatChannelModel getChatTopicInfoOnCase(String caseId) {
    // Query for Twilio Chat Channel SID by passing in the Case ID
    String channelSID;
    String ocvId;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      List<Case> cases = [
        SELECT Twilio_Channel_SID__c, Account.OCV_ID__c
        FROM Case
        WHERE Twilio_Channel_SID__c != NULL AND Id = :caseId
      ];
      if (!cases.isEmpty()) {
        channelSID = cases[0].Twilio_Channel_SID__c;
        ocvId = cases[0].Account.OCV_ID__c;
      }
    }

    if (String.isNotBlank(ocvID) && String.isNotBlank(channelSID)) {
      // Make a callout to Twilio Service to fetch Chat Topic information linked with the Case
      CallCenterAPIRepository ccap = new CallCenterAPIRepository();
      ChatChannelModel responseBody = ccap.getChatTopicsByChannelSID(
        ocvId,
        channelSID
      );

      return responseBody;
    }

    return null;
  }
}
