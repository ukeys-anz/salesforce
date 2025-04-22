/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Model of AEM data for pushing task to App
 */
public with sharing class AemDataModel extends CalloutModel {
  /**
   * @description This holds the push notification data
   */
  public Data data;

  /**
   * @description This class holds the main data structure of the push notification
   */
  public class Data {
    public PushToAppList pushToAppList;
  }

  /**
   * @description This class represents pushToAppList
   */
  public class PushToAppList {
    public Items[] items;
  }

  /**
   * @description This class represents an individual item in the push notification
   */
  public class Items {
    public String id;
    public String title;
    public String subtitle;
    public String bodyText;
    public String reference;
    public String iconLightURI;
    public String iconDarkURI;
    public Steps[] steps;
  }

  /**
   * @description The class represents a step in the notification process
   */
  public class Steps {
    public String title;
    public Actions[] actions;
  }

  /**
   * @description The class represents an action associated with a step in the notification
   */
  public class Actions {
    public String type;
    public String description;
    public String deepLink;
    public String iconLightURI;
    public String iconDarkURI;
  }

  /**
   * @param aemData input string to deserialize
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return `AemDataModel`
   * @description deserializes the input string into the model, using the base method and reserved key replacement
   */
  public static AemDataWrapper parse(String aemData, Id recordId) {
    String aemDataWithReplacedFields = AemDataMergeFieldProcessor.replaceMergedFields(
      aemData,
      recordId
    );
    AemDataModel notificationData = (AemDataModel) deserialize(
      aemDataWithReplacedFields,
      AemDataModel.class
    );
    AemDataWrapper notificationWrapper = new AemDataWrapper(notificationData);
    return notificationWrapper;
  }
}
