/**
 * Suppressing PMD property naming convention warnings as some fields include underscore in the naming convention.
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
/**
 * @author Nilesh Kalal
 * @since April 2025
 * @description Wrapper class customer action creation based on aem content data
 */
public class CustomerActionWrapper {
  /**
   * @description bodyText
   */
  @AuraEnabled
  public String bodyText { get; set; }
  /**
   * @description expiryDate
   */
  @AuraEnabled
  public String expiryDate { get; set; }
  /**
   * @description id
   */
  @AuraEnabled
  public String id { get; set; }
  /**
   * @description notificationConfigId
   */
  @AuraEnabled
  public String notificationConfigId { get; set; }
  /**
   * @description reference
   */
  @AuraEnabled
  public String reference { get; set; }
  /**
   * @description subtitle
   */
  @AuraEnabled
  public String subtitle { get; set; }
  /**
   * @description title
   */
  @AuraEnabled
  public String title { get; set; }

  /**
   * @description action_uri
   */
  public String action_uri { get; set; }

  /**
   * @description steps
   */
  @AuraEnabled
  public List<Step> steps { get; set; }
  /**
   * @description Step
   */
  public class Step {
    /**
     * @description title
     */
    @AuraEnabled
    public String title { get; set; }
    /**
     * @description bodyText
     */
    @AuraEnabled
    public List<Action> actions { get; set; }
  }
  /**
   * @description Action to set action fields
   */

  public class Action {
    /**
     * @description deepLink
     */
    @AuraEnabled
    public String deepLink { get; set; }
    /**
     * @description description
     */
    @AuraEnabled
    public String description { get; set; }
    @AuraEnabled
    /**
     * @description icon
     */
    public String icon { get; set; }
    /**
     * @description type
     */
    @AuraEnabled
    public String type { get; set; }
  }
}
