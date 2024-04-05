/**
 * @description Wrapper class to store Interaction Context Response parameters
 */
global class InteractionContextResponse {
  /**
   * @description Response result (true or false)
   */
  public Boolean success { get; set; }
  /**
   * @description Response code. 200 for success. 400 for failure.
   */
  public Integer statusCode { get; set; }
  /**
   * @description Record ID
   */
  public String recordId { get; set; }
  /**
   * @description Interaction ID
   */
  public String externalId { get; set; }
  /**
   * @description Error Message for failure response
   */
  public String errorMessage { get; set; }
  /**
   * @description Customer OCV ID
   */
  public String ocvId { get; set; }
  /**
   * @description Label for chat to display
   */
  public String chatLabel { get; set; }
}
