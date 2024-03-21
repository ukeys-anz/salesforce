/**
 * @description Wrapper class to store Twilio Context Response parameters
 */
global class TwilioContextResponse {
  /**
   * @description Response result (true or false)
   */
  public Boolean success { get; set; }
  /**
   * @description Response code. 200 for success. 400 for failure.
   */
  public Integer statusCode { get; set; }
  /**
   * @description Error Message for failure response
   */
  public String errorMessage { get; set; }
}
