/**
 * Suppressing PMD property naming convention warnings as some fields include underscore in the naming convention.
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
/**
 * @author Kopal Goswami
 * @since  4/2025
 * @description Wrapper Class for preparing the notification node for cloud events
 */
public with sharing class PushToAppNotificationWrapper {
  /**
   * @description Holds title
   */
  public String title { get; set; }
  /**
   * @description Holds body
   */
  public String body { get; set; }
  /**
   * @description Holds action_uri
   */
  public String action_uri { get; set; }
  /**
   * @description Holds icon_uri
   */
  public IconUri icon_uri { get; set; }

  /**
   * @description this model is for holding icon details
   */
  public class IconUri {
    /**
     * @description Holds light icon
     */
    public String icon_light_uri { get; set; }
    /**
     * @description Holds dark icon
     */
    public String icon_dark_uri { get; set; }
  }

  /**
   * @description Constructor for PushToAppNotificationWrapper that intializes the object with notification data
   * @param item Aemcontendata associated with customer task notification
   * @param theTask task records details
   */
  public PushToAppNotificationWrapper(AemDataModel.Items item, Task theTask) {
    this.title = item.title;
    this.body = item.subtitle + '\n' + item.bodyText;
    this.action_uri =
      System.Label.Push_Task_To_App_Deeplink + theTask.Pub_Sub_Event_Id__c;
    this.icon_uri = convertIcon(item.iconLightURI, item.iconDarkURI);
  }

  private static PushToAppNotificationWrapper.IconUri convertIcon(
    String iconLightURI,
    String iconDarkURI
  ) {
    IconUri iconvalue = new IconUri();
    iconvalue.icon_light_uri = iconLightURI;
    iconvalue.icon_dark_uri = iconDarkURI;
    return iconvalue;
  }
}
