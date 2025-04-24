/**
 * @author Nilesh Kalal
 * @since April 2025
 * @description Wrapper class customer action creation based on aem content data
 */
public class CustomerActionWrapper {
  @AuraEnabled
  public String bodyText;
  @AuraEnabled
  public String expiryDate;
  @AuraEnabled
  public String id;
  @AuraEnabled
  public String notificationConfigId;
  @AuraEnabled
  public String reference;
  @AuraEnabled
  public String subtitle;
  @AuraEnabled
  public String title;
  @AuraEnabled
  public List<Step> steps;
  /**
   * @description Step to set steps fields
   */

  public class Step {
    @AuraEnabled
    public String title;
    @AuraEnabled
    public List<Action> actions;
  }
  /**
   * @description Action to set action fields
   */
  public class Action {
    @AuraEnabled
    public String deepLink;
    @AuraEnabled
    public String description;
    @AuraEnabled
    public String icon;
    @AuraEnabled
    public String type;
  }
}
