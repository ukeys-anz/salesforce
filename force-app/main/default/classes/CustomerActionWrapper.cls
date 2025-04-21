/**
 * @author Nilesh Kalal
 * @since April 2025
 * @description Wrapper class customer action creation based on aem content data
 */
public class CustomerActionWrapper {
  public String bodyText;
  public String expiryDate;
  public String id;
  public String notificationConfigId;
  public String reference;
  public String subtitle;
  public String title;
  public List<Step> steps;
  /**
   * @description Step to set steps fields
   */
  public class Step {
    public String title;
    public List<Action> actions;
  }
  /**
   * @description Action to set action fields
   */
  public class Action {
    public String deepLink;
    public String description;
    public String icon;
    public String type;
  }
}
