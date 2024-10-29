/**
 * @description A class that represents the configuration options for Library Callout Action
 * @author Shivam Swaraj
 * @since 10/2024
 * @group Util
 */
public inherited sharing class Lib_HttpCalloutConfig {
  public Boolean logResponseBody = true;

  /**
   * @description Sets the logResponseBody to save the response body or not on successful callout
   * @param logResponseBodyOrNot Boolean to decide whether to save the logResponseBody or not in secure logs
   * @return The current instance of the Lib_HttpCalloutConfig class.
   */
  public Lib_HttpCalloutConfig logResponseBody(Boolean logResponseBodyOrNot) {
    this.logResponseBody = logResponseBodyOrNot;
    return this;
  }
}
