/**
 * @description Wrapper class to store Interaction Context Request parameters
 */
global class InteractionContextRequest {
  /**
   * @description chatOrCallId to identify the Twilio details
   */
  public String chatOrCallId { get; set; }
  /**
   * @description Issue Subtype as a String based on Chat context passed from App in to Twilio
   */
  public String issueSubtype { get; set; }
  /**
   * @description Direction from Twillio
   */
  public String direction { get; set; }
  /**
   * @description Customer OCV ID
   */
  public String ocvId { get; set; }
  /**
   * @description phone number from Twilio
   */
  public String phoneNumber { get; set; }
  /**
   * @description PPID from Twilio
   */
  public String ppid { get; set; }
  /**
   * @description Type from Twilio
   */
  public String type { get; set; }
  /**
   * @description Twilio Id from Twilio
   */
  public String twilioId { get; set; }
  /**
   * @description Call Recording Id from Twilio for inbound calls
   */
  public String callRecordingId { get; set; }
  /**
   * @description chatOrCallStatus from Twilio
   */
  public String chatOrCallStatus { get; set; }
}
