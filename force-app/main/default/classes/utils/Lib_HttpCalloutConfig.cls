/**
 * @description A class that represents the configuration options for Library Callout Action
 * @author Shivam Swaraj
 * @since 10/2024
 * @group Util
 */
public inherited sharing class Lib_HttpCalloutConfig {

   private Boolean logResponseBody ;

   /**
   * @description Setter to set the value of logResponseBody to true.
   * @return boolean value to true for logging response body
   */
   public Boolean getLogResponseBody()
    {
        return this.logResponseBody;
    }

   /**
   * @description Setter to set the value of logResponseBody whether to log or not.
   * @param logResponseBodyOrNot boolean value to set for logResponseBody
   */
    public void setLogResponseBody(Boolean logResponseBodyOrNot)
    {
        this.logResponseBody = logResponseBodyOrNot;
    }
}