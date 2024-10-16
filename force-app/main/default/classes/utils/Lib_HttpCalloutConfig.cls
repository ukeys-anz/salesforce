/**
 * @description A class that represents the configuration options for Library Callout Action
 * @author Shivam Swaraj
 * @since 10/2024
 * @group Util
 */
public inherited sharing class Lib_HttpCalloutConfig {
   /**
   * @description determines whether to not log response body on successful callouts default
   */
   public Boolean logResponseBody = false;

    /**
   * @description Setter to set the value of logResponseBody to true.
   * @return boolean value to true for logging response body
   */
   public Boolean logResponseBody()
    {
        this.logResponseBody = true ;
        return this.logResponseBody;
    }
}