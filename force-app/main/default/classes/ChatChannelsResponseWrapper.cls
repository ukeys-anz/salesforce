/**
 * @author Shermal Warnakula
 * @since 01 2021
 * @description Wrapper class to deserialize Chat Channels/Topics returned from Mulesoft(Twilio) API
 */
public with sharing class ChatChannelsResponseWrapper {
  // list of Channels
  public List<Channels> channels;

  // object to store first level '_links' in json
  public Links_Z xlinks;

  /**
   * @description Checks for Channels in the response
   * @return Boolean
   */
  public boolean hasChannels() {
    return this.channels != null;
  }

  /**
   * @description Returns the URL to fetch the next set of records, if there is any
   * @return String
   */
  public String nextUrl() {
    String nextUrl;
    if (xlinks.xlinks.next != null) {
      nextUrl = this.xlinks.xlinks.next.substring(
        xlinks.xlinks.next.indexOf('?')
      );
    }
    return nextUrl;
  }

  /**
   * @description Wrapper class representing Channel attributes
   */
  public class Channels {
    // Twilio Channel SID
    public String id;
  }

  /**
   * @description Wrapper class representing first level '_links' attributes
   */
  public class Links_Z {
    // object to store second level '_links' in json
    public Links xlinks;
  }

  /**
   * @description Wrapper class representing second level '_links' attributes
   */
  public class Links {
    // Endpoint URL to retrieve the next set of Channels
    public String next;
    // Endpoint URL to pointing to current set of Channels
    public String self;
  }
}
