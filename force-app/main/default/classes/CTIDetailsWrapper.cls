/**
 * @author Nilesh Kalal
 * @since May 2026
 * @description Wrapper class for CTI details from inbound calls and chats
 */
public class CTIDetailsWrapper {
  /**
   * @description Contact ID from CTI system
   */
  @AuraEnabled
  public String contactId { get; set; }

  /**
   * @description Original Contact ID from CTI system
   */
  @AuraEnabled
  public String originalContactId { get; set; }

  /**
   * @description Parses CTI JSON data into CTIDetailsWrapper wrapper
   * @param jsonData JSON string to parse
   * @return CTIDetailsWrapper wrapper instance
   */
  public static CTIDetailsWrapper parseCTIJson(String jsonData) {
    return (CTIDetailsWrapper) JSON.deserialize(
      jsonData,
      CTIDetailsWrapper.class
    );
  }
}
