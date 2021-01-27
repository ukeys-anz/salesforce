/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class ChatTopicRelatedListController {
  public static final String CHANNELS_ENDPOINT_SUFFIX = '/channels';
  public static final Integer OFFSET_LIMIT = 20;

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topics related to account.
   *
   * @param accountId Salesforce ID of the Account record from the lwc component
   * @param nextURL URL substring related to next offset (if there is a next) from API the response
   * @return String
   */
  @AuraEnabled(cacheable=false)
  public static String getChatTopicsOnAccount(
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
    }

    // Make a callout to Mulesoft to fetch all Chat Topics related to the customer
    String responseBody = getChatTopicsByCustomer(ocvId, nextURL);

    return responseBody;
  }

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topic related to case.
   *
   * @param caseId from lwc component
   * @return String
   */
  @AuraEnabled(cacheable=false)
  public static String getChatTopicInfoOnCase(String caseId) {
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

    // Make a callout to Mulesoft to fetch Chat Topic information linked with the Case
    String responseBody = getChatTopicByChannelSID(ocvId, channelSID);

    return responseBody;
  }

  /**
   * @description Fetch Chat Topics via API by passing in customer OCV ID
   * @param ocvID Customer OCV ID
   * @param nextURL URL to get next result set if available
   * @return String
   */
  public static String getChatTopicsByCustomer(String ocvID, String nextURL) {
    String rowLimitParam = '?limit=' + OFFSET_LIMIT;

    String responseBody = null;
    if (String.isNotBlank(ocvID)) {
      HttpRequest request = new HttpRequest();
      String urlParams = String.isBlank(nextURL) ? rowLimitParam : nextURL;
      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Get_CustomerChatChannels +
        ocvID +
        CHANNELS_ENDPOINT_SUFFIX +
        urlParams
      );

      request.setMethod('GET');
      String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvID);
      request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
      //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          responseBody = response.getBody();
        } else {
          throw new CalloutException(response.getBody());
        }
      } catch (Exception e) {
        Lib_SystemLog.logAPIError(
          ChatTopicRelatedListController.class.getName(),
          'getChatTopicsByCustomer',
          e.getMessage(),
          e.getTypeName(),
          ChatTopicRelatedListController.class.getName(),
          null,
          response != null ? response.getBody() : null
        );

        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }

  /**
   * @description Fetch Chat Topic information via API by passing in customer OCV ID and particular Channel SID
   * @param ocvID Customer OCV ID
   * @param channelSID Channel SID stored on related Case record
   * @return String
   */
  public static String getChatTopicByChannelSID(
    String ocvID,
    String channelSID
  ) {
    String responseBody = null;
    if (String.isNotBlank(ocvID) && String.isNotBlank(channelSID)) {
      HttpRequest request = new HttpRequest();
      request.setEndpoint(
        'callout:SF_MS_Fabric' +
        Label.MS_Get_CaseChatChannel +
        channelSID
      );

      request.setMethod('GET');
      String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvID);
      request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
      //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          responseBody = response.getBody();
        } else {
          throw new CalloutException(response.getBody());
        }
      } catch (Exception e) {
        Lib_SystemLog.logAPIError(
          ChatTopicRelatedListController.class.getName(),
          'getChatTopicByChannelSID',
          e.getMessage(),
          e.getTypeName(),
          ChatTopicRelatedListController.class.getName(),
          null,
          response != null ? response.getBody() : null
        );

        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }
}
