/**
 * @author Kopal Goswami
 * @since Oct 2024
 * @description  Model of AEM data for pushing task to App
 */
public with sharing class AemDataWrapper {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  /**
   * @description This is the main data wrapper class that holds the push notification data
   */
  @AuraEnabled
  public Data data { get; set; }

  /**
   * @description This class represents the main data structure of the push notification
   */
  public class Data {
    /**
     * @description This field represent pushToAppList
     */
    @AuraEnabled
    public PushToAppList pushToAppList { get; set; }
  }

  /**
   * @description class represents PushToAppList information
   */
  public class PushToAppList {
    /**
     * @description This class represnts a list of items for the push notification
     */
    @AuraEnabled
    public Items[] items { get; set; }
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
   * @description The class represnts a step in the notification process
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
   * @description The class represnts an action associated with a step in the notification
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
   * @description Constructor for AemDataWrapper that intializes the object with notification data
   * @param notificationData The input model containing the notification data
   */
  public AemDataWrapper(AemDataModel notificationData) {
    if (notificationData.data != null) {
      this.data = convertData(notificationData.data);
    }
  }

  private static AemDataWrapper.data convertData(AemDataModel.data sourcedata) {
    AemDataWrapper.data destData = new AemDataWrapper.data();
    if (sourcedata?.pushToAppList != null) {
      destData.pushToAppList = convertpushToAppList(sourcedata.pushToAppList);
    }
    return destData;
  }

  private static AemDataWrapper.pushToAppList convertpushToAppList(
    AemDataModel.pushToAppList sourcedpushToAppList
  ) {
    AemDataWrapper.pushToAppList destpushToAppList = new AemDataWrapper.pushToAppList();
    if (sourcedpushToAppList?.items != null) {
      destpushToAppList.items = convertitems(sourcedpushToAppList.items);
    }
    return destpushToAppList;
  }

  private static List<AemDataWrapper.Items> convertitems(
    List<AemDataModel.Items> sourceItems
  ) {
    List<AemDataWrapper.Items> destItemsList = new List<AemDataWrapper.Items>();
    AemDataModel.Items sourceItem = sourceItems[0];
    Customer_Task_Configuration__c notificationConfigRecord = PUSH_TO_APP_REPOSITORY.selectedNotificationConfigDetail(
      sourceItem.id
    );
    Integer expireAfterDays = (notificationConfigRecord?.Expire_After_Days__c !=
      null)
      ? Integer.valueOf(notificationConfigRecord?.Expire_After_Days__c)
      : 0;
    AemDataWrapper.Items destItem = new AemDataWrapper.Items();
    destItem.id = sourceItem.id;
    destItem.title = sourceItem.title;
    destItem.subtitle = sourceItem.subtitle;
    destItem.bodyText = sourceItem.bodyText;
    destItem.reference = sourceItem.reference;
    destItem.iconLightURI = sourceItem.iconLightURI;
    destItem.iconDarkURI = sourceItem.iconDarkURI;
    if (sourceItem.steps != null) {
      destItem.steps = convertSteps(sourceItem.steps);
    }
    destItem.expiryDate = convertExpiryDate(expireAfterDays);
    destItem.notificationConfigId = notificationConfigRecord?.Id;
    destItemsList.add(destItem);

    return destItemsList;
  }

  private static List<AemDataWrapper.Steps> convertSteps(
    List<AemDataModel.Steps> sourceSteps
  ) {
    List<AemDataWrapper.Steps> destStepsList = new List<AemDataWrapper.Steps>();
    for (AemDataModel.Steps sourceStep : sourceSteps) {
      AemDataWrapper.Steps destStep = new AemDataWrapper.Steps();
      destStep.title = sourceStep.title;
      if (sourceStep.actions != null) {
        destStep.actions = convertAction(sourceStep.actions);
      }

      destStepsList.add(destStep);
    }
    return destStepsList;
  }

  private static List<AemDataWrapper.Actions> convertAction(
    List<AemDataModel.Actions> sourceActions
  ) {
    List<AemDataWrapper.Actions> destActionsList = new List<AemDataWrapper.Actions>();
    for (AemDataModel.Actions sourceAction : sourceActions) {
      AemDataWrapper.Actions destAction = new AemDataWrapper.Actions();
      destAction.type = sourceAction.type;
      destAction.description = sourceAction.description;
      destAction.deepLink = sourceAction.deepLink;
      destAction.iconLightURI = sourceAction.iconLightURI;
      destAction.iconDarkURI = sourceAction.iconDarkURI;
      destActionsList.add(destAction);
    }
    return destActionsList;
  }

  private static String convertExpiryDate(Integer expireAfterDays) {
    if (expireAfterDays == 0) {
      return null;
    }
    DateTime expiryDateTime = DateTime.now().addDays(expireAfterDays);
    return expiryDateTime.format('dd/MM/yyyy');
  }
}
