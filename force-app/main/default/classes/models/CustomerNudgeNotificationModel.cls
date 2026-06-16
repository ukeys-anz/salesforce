/**
 * Suppressing PMD property naming convention warnings as some fields include underscore in the naming convention.
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
/**
 * @author Kopal Goswami
 * @since  4/2025
 * @description Model Class for preparing the notification node for cloud events
 */
public with sharing class CustomerNudgeNotificationModel {
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
  public String actionUri { get; set; }
  /**
   * @description Holds icon_uri
   */
  public IconUri iconUri { get; set; }

  /**
   * @description this model is for holding icon details
   */
  public class IconUri {
    /**
     * @description Holds light uri
     */
    public String iconLightUri { get; set; }
    /**
     * @description Holds dark uri
     */
    public String iconDarkUri { get; set; }

    /**
     * @description Constructor for IconuRI
     * @param lightUri holds light uri
     * @param darkUri holds dark uri
     */
    public IconUri(String lightUri, String darkUri) {
      this.iconLightUri = lightUri;
      this.iconDarkUri = darkUri;
    }
  }

  /**
   * @description Constructor for CustomerNudgeNotificationModel that intializes the object with notification data
   * @param item Aemcontendata associated with customer task notification
   * @param theTask task records details
   */
  public CustomerNudgeNotificationModel(AemDataModel.Items item, Task theTask) {
    this.title = item.title;
    this.body = item.bodyText;
    if (String.isNotBlank(item.subtitle)) {
      this.body = item.subtitle + '\n' + item.bodyText;
    }
    this.actionUri =
      System.Label.Push_Task_To_App_Deeplink + theTask.Pub_Sub_Event_Id__c;
    this.iconUri = new IconUri(item.iconLightURI, item.iconDarkURI);
  }
}
