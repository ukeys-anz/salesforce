/**
 * @author Jasmine Nguyen
 * @since March 2021
 * @description model for chat channels API, extending the base
 * @group Models
 */
public with sharing class ChatChannelModel extends CalloutModel {
  /**
   * @description List of channels
   */
  @AuraEnabled
  public List<Channel> channels;

  /**
   * @description A channel
   */
  public class Channel {
    // Twilio Channel SID
    @AuraEnabled
    public String id;

    // Twilio Channel Chat Flow Status
    @AuraEnabled
    public String chatFlowStatus;

    // Twilio Channel Name
    @AuraEnabled
    public String name;

    // Twilio Channel Status
    @AuraEnabled
    public String status;

    // Twilio Channel Last Modified Date
    @AuraEnabled
    public String lastModified;

    // Twilio Channel On Hold Reason
    @AuraEnabled
    public String onHoldReason;
  }

  /**
   * @description List of failures
   */
  @AuraEnabled
  public List<Failure> failures;

  /**
   * @description A failure
   */
  public class Failure {
    // Failure id
    @AuraEnabled
    public String id;

    // Failure message
    @AuraEnabled
    public String message;
  }

  /**
   * @description Object to store first level '_links' in json
   */
  @AuraEnabled
  public Links_Z links;

  /**
   * @description Wrapper class representing first level '_links' attributes
   */
  public class Links_Z {
    // Endpoint URL to retrieve the next set of Channels
    @AuraEnabled
    public String next;

    // Endpoint URL to pointing to current set of Channels
    @AuraEnabled
    public String self;
  }

  /**
   * @description Checks for Channels in the response
   * @return Boolean
   */
  @AuraEnabled
  public boolean getHasChannels() {
    return this.channels != null;
  }

  /**
   * @description Returns the URL to fetch the next set of records, if there is any
   * @return String
   */
  @AuraEnabled
  public String getNextUrl() {
    String nextUrl;
    if (links != null && links.next != null) {
      nextUrl = this.links.next.substring(links.next.indexOf('?'));
    }
    return nextUrl;
  }

  /**
   * @param json input string to deserialize
   * @return `ChatChannelModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static ChatChannelModel parseChannels(String json) {
    return (ChatChannelModel) deserialize(json, ChatChannelModel.class);
  }

  /**
   * @param json input string to deserialize
   * @return `Channel`
   * @description deserializes the input string into the model of a single channel, using the base method and reserved key replacement
   */
  public static Channel parseSingleChannel(String json) {
    return (Channel) deserialize(json, Channel.class);
  }
}
