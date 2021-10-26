/**
 * @author Boobalakrishnan Duraisamy, Jasmine Nguyen
 * @since 10 2020
 * @lastModified: March 2021
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class ChatTopicRelatedListController {
  public static AccountQueryHelper accountHelper = new AccountQueryHelper();
  public static CaseQueryHelper caseHelper = new CaseQueryHelper();
  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topics related to account.
   *
   * @param accountId Salesforce ID of the Account record from the lwc component
   * @param nextURL URL substring related to next offset (if there is a next) from API the response
   * @return `ChatChannelModel`  a list of channels
   */
  @AuraEnabled(cacheable=false)
  public static ChatChannelModel getChatTopicsOnAccount(
    String accountId,
    String nextURL
  ) {
    // Query for Customer OCV ID by passing in the Account ID
    String ocvId;
    String ppid;
    if (Account.sObjectType.getDescribe().isQueryable()) {
      List<Account> accounts = accountHelper.findAccountsByAccountId(accountId);
      if (!accounts.isEmpty()) {
        ocvId = accounts[0].OCV_ID__c;
        ppid = accounts[0].PPID__c;
      }

      if (String.isNotBlank(ocvID) && String.isNotBlank(ppid)) {
        // Make a callout to Twilio Service to fetch all Chat Topics related to the customer
        CallCenterAPIRepository ccap = new CallCenterAPIRepository();
        ChatChannelModel responseBody = ccap.getChatTopicsByCustomer(
          ocvId,
          ppid,
          nextURL
        );

        return responseBody;
      }
    }

    return null;
  }

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrieve chat topic related to case.
   *
   * @param caseId from lwc component
   * @return `ChatChannelModel.Channel` a single channel
   */
  @AuraEnabled(cacheable=false)
  public static ChatChannelModel.Channel getChatTopicInfoOnCase(String caseId) {
    // Query for Twilio Chat Channel SID by passing in the Case ID
    String channelSID;
    String ocvId;
    if (Case.sObjectType.getDescribe().isQueryable()) {
      List<Case> cases = caseHelper.findChatCaseByCaseId(caseId);
      if (!cases.isEmpty()) {
        channelSID = cases[0].Twilio_Channel_SID__c;
        ocvId = cases[0].Account.OCV_ID__c;
      }
    }

    if (String.isNotBlank(ocvID) && String.isNotBlank(channelSID)) {
      // Make a callout to Twilio Service to fetch Chat Topic information linked with the Case
      CallCenterAPIRepository ccap = new CallCenterAPIRepository();
      ChatChannelModel.Channel responseBody = ccap.getChatTopicsByChannelSID(
        ocvId,
        channelSID
      );

      return responseBody;
    }

    return null;
  }
}
