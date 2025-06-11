/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Model of AEM data for pushing task to App
 */
public with sharing class AemDataModel extends CalloutModel {
  /**
   * @description This holds the push notification data
   */
  @AuraEnabled
  public Data data { get; set; }

  /**
   * @description This class holds the main data structure of the push notification
   */
  public class Data {
    /**
     * @description This field represent pushToAppList
     */
    @AuraEnabled
    public PushToAppList pushToAppList { get; set; }
  }

  /**
   * @description This class represents pushToAppList
   */
  public class PushToAppList {
    /**
     * @description This class represnts a list of items for the push notification
     */
    @AuraEnabled
    public List<Items> items { get; set; }
  }

  /**
   * @description This class represents an individual item in the push notification
   */
  public class Items {
    /**
     * @description The unique identifier for the push notification item
     */
    @AuraEnabled
    public String id { get; set; }
    /**
     * @description The title of the push notification item
     */
    @AuraEnabled
    public String title { get; set; }
    /**
     * @description The subtitle of the push notification item
     */
    @AuraEnabled
    public String subtitle { get; set; }
    /**
     * @description The bodyText of the push notification item
     */
    @AuraEnabled
    public String bodyText { get; set; }
    /**
     * @description The reference of the push notification item
     */
    @AuraEnabled
    public String reference { get; set; }
    /**
     * @description The iconLightURI of the push notification item
     */
    @AuraEnabled
    public String iconLightURI { get; set; }
    /**
     * @description The iconDarkURI of the push notification item
     */
    @AuraEnabled
    public String iconDarkURI { get; set; }
    /**
     * @description The list of steps of the push notification item
     */
    @AuraEnabled
    public List<Steps> steps { get; set; }
    /**
     * @description The expiryDate of the push notification item
     */
    @AuraEnabled
    public String expiryDate { get; set; }
    /**
     * @description Record Id for Notification Configuration
     */
    @AuraEnabled
    public String notificationConfigId { get; set; }
  }

  /**
   * @description The class represents a step in the notification process
   */
  public class Steps {
    /**
     * @description The title of the step in the notificartion process
     */
    @AuraEnabled
    public String title { get; set; }
    /**
     * @description A list of actions associated with the step
     */
    @AuraEnabled
    public List<Actions> actions { get; set; }
  }

  /**
   * @description The class represents an action associated with a step in the notification
   */
  public class Actions {
    /**
     * @description The type of the action
     */
    @AuraEnabled
    public String type { get; set; }
    /**
     * @description A description of the action
     */
    @AuraEnabled
    public String description { get; set; }
    /**
     * @description A deeplink associated with the action
     */
    @AuraEnabled
    public String deepLink { get; set; }
    /**
     * @description An iconLightURI representing the action visually
     */
    @AuraEnabled
    public String iconLightURI { get; set; }
    /**
     * @description An iconDarkURI representing the action visually
     */
    @AuraEnabled
    public String iconDarkURI { get; set; }
  }

  /**
   * @param aemData input string to deserialize
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return `AemDataModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static AemDataModel parse(String aemData, Id recordId) {
    AemDataModel notificationData = (AemDataModel) deserialize(
      aemData,
      AemDataModel.class
    );
    return notificationData;
  }
}
