/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description Twilio implementation of the API service
 * @group Services
 */
public with sharing class TwilioService extends Service {
  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param endPoint the end point of the API callout
   * @return `HttpCalloutResponse` the api response
   * @description fetches chat channels (chat topics) from the Twilio API
   */
  public override HttpCalloutResponse fetchChatTopics(
    String ocvId,
    String endPoint
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);
    HttpCalloutResponse response = calloutService.makeRestCallout(
      endPoint,
      HTTP_METHOD.HTTP_GET,
      headers,
      null
    );
    return response;
  }

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param messageContent the content of the message to be sent
   * @param customerName the first name of the customer
   * @param issueType the issue type (default to Follow Up)
   * @param issueSubType the issue sub type (default to ANZ Plus Support)
   * @return `HttpCalloutResponse` the api response
   * @description sends the initial chat message
   */
  public override HttpCalloutResponse initiateChat(
    String ocvId,
    String messageContent,
    String customerName,
    String issueType,
    String issueSubType
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);

    InitiateChatPayload payload = new InitiateChatPayload();
    payload.messageBody = messageContent;
    payload.caseSubType = issueSubType;
    payload.issueType = issueType;
    payload.preferredName = customerName;

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Twilio' + Label.MS_Initiate_Chat,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(payload)
    );
    return response;
  }

  /**
   * @param ocvId customer id to retrieve accounts and goals for
   * @param conversationSid id the id of the chat to reinitiate
   * @return `HttpCalloutResponse` the api response
   * @description reinitiates customer chat
   */
  public override HttpCalloutResponse reinitiateChat(
    String ocvId,
    String conversationSid
  ) {
    Lib_HttpCallout calloutService = new Lib_HttpCallout();
    Map<String, String> headers = new Map<String, String>();
    setCalloutCommonHeaders(ocvID, headers);

    ReinitiateChatPayload payload = new ReinitiateChatPayload();
    payload.conversationSid = conversationSid;

    HttpCalloutResponse response = calloutService.makeRestCallout(
      'callout:SF_MS_Twilio' + Label.MS_Reinitiate_Chat,
      HTTP_METHOD.HTTP_POST,
      headers,
      JSON.serialize(payload)
    );
    return response;
  }

  /**
   * @description payload for initiateChat
   */
  private class InitiateChatPayload {
    public String messageBody;
    public String caseSubType;
    public String issueType;
    public String preferredName;
  }

  /**
   * @description payload for reinitiateChat
   */
  private class ReinitiateChatPayload {
    public String conversationSid;
  }
}
