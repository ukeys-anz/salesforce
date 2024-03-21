/**
 * @author Shivam Swaraj
 * @since  July 2023
 * @description Wrapper class to store Twilio Context Response parameters
 */
global class UpdateInteractionByTwilioPayload {
  /**
   * @description Interaction ID
   */
  public Id interactionId { get; set; }
  /**
   * @description twilioId
   */
  public String twilioId { get; set; }
  /**
   * @description chatOrCallId
   */
  public String chatOrCallId { get; set; }
  /**
   * @description chatOrCallStatus
   */
  public String chatOrCallStatus { get; set; }
  /**
   * @description callRecordingId
   */
  public String callRecordingId { get; set; }
  /**
   * @description queueName
   */
  public String queueName { get; set; }
  /**
   * @description agentEmail
   */
  public String agentEmail { get; set; }
  /**
   * @description store the id of the Twilio Detail
   */
  public String twilioDetailRecordId { get; set; }
  /**
   * @description transfer
   */
  public String transfer { get; set; }
  /**
   * @description attendeePhoneNumber
   */
  public String attendeePhoneNumber { get; set; }
  /**
   * @description attendeeName
   */
  public String attendeeName { get; set; }
  /**
   * @description isConference to detect whether the conference happened
   */
  public Boolean isConference { get; set; }
}
