/**
 * @author Boobalakrishnan Duraisamy
 * @since 10 2020
 * @description ChatTopicRelatedListController is the apex side controller for the chatTopicRelatedList LWC
 */
@SuppressWarnings('PMD.ApexSuggestUsingNamedCred')
public with sharing class ChatTopicRelatedListController {
  public static final String CHANNELS_ENDPOINT_SUFFIX = '/channels';
  public static final Integer OFFSET_LIMIT = 1;

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topics related to account.
   *
   * @param accountId from the lwc component
   * @return List<Chat_Topic__c>
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
    // ocvId = 'muley';
    String responseBody = getChatTopicsByCustomer(ocvId, nextURL);

    // String responseBody = '{'+
    // '    \"channels\": ['+
    // '        {'+
    // '            \"id\": \"CH157e3ffaac344204b65a2ca6ce0e5cad\",'+
    // '            \"name\": \"Dispute Transaction\",'+
    // '            \"status\": \"inactive\",'+
    // '            \"chatFlowStatus\": \"ON_HOLD\",'+
    // '            \"onHoldReason\": \"WAITING_ON_CUSTOMER\",'+
    // '            \"lastModified\": \"2020-12-21T01:10:25Z\"'+
    // '        },'+
    // '        {'+
    // '            \"id\": \"CH157e3ffaac344204b65a2ca6ce0e1111\",'+
    // '            \"name\": \"Home Loan Enquiry\",'+
    // '            \"status\": \"active\",'+
    // '            \"chatFlowStatus\": \"OPEN\",'+
    // '            \"onHoldReason\": \"\",'+
    // '            \"lastModified\": \"2020-12-21T01:10:25Z\"'+
    // '        },'+
    // '        {'+
    // '            \"id\": \"CH861a283ceed84330a80a383b4620118c\",'+
    // '            \"name\": \"Lost Phone\",'+
    // '            \"status\": \"inactive\",'+
    // '            \"chatFlowStatus\": \"RESOLVED\",'+
    // '            \"onHoldReason\": \"\",'+
    // '            \"lastModified\": \"2020-12-03T06:29:44Z\"'+
    // '        }'+
    // '    ],'+
    // '    \"_links\": {'+
    // '        \"_links\": {'+
    // '            \"next\": \"/chat/users/muley/channels?limit=10&sortBy=lastModified&order=desc&offset=PTCHa52aca009e834e05a279b1fa0160d86b\",'+
    // '            \"self\": \"/chat/users/muley/channels?limit=10&sortBy=lastModified&order=desc\"'+
    // '        }'+
    // '    }'+
    // '}';

    return responseBody;
  }

  /**
   * @description This method is used to chatTopicRelatedList lwc component to retrive chat topic related to case.
   *
   * @param caseId from lwc component
   * @return List<Chat_Topic__c>
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

      //TODO remove this later
      // ocvId = '4017640246';
      // String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvId);
      // request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
      //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          System.debug(response);
          System.debug(response.getBody());

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
        //throw new AuraHandledException(e.getMessage());
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }

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

      //TODO remove this later
      // ocvId = '4017640246';
      // String serializedToken = AuthTokenCacheUtil.getStaffToken(ocvId);
      // request.setHeader('Authorization', 'Bearer ' + serializedToken);
      request.setHeader('client_id', '{!$Credential.Username}');
      request.setHeader('client_secret', '{!$Credential.Password}');
      //Todo: This needs to be replaced with uniquely generated id based on what is accepted by forge
      //request.setHeader('x-correlation-id', RequestUtils.getRequestId());
      HTTPResponse response = null;
      try {
        Http http = new Http();
        response = http.send(request);
        if (response.getStatusCode() == 200) {
          System.debug(response);
          System.debug(response.getBody());

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
        //throw new AuraHandledException(e.getMessage());
        AuraHandledException ahe = new AuraHandledException(e.getMessage());
        ahe.setMessage(e.getMessage());
        throw ahe;
      }
    }

    return responseBody;
  }
}
