/**
 * Suppressing PMD property naming convention warnings as some fields include underscore in the naming convention.
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
/**
 * @author Kopal Goswami
 * @since  10/2024
 * @description Wrapper Class for sending Customer Nudge Tasks details (Notification) to Mobile
 */
public virtual with sharing class CustomerNudgeTaskCloudEventModel extends TaskCloudEventModel {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  private static final String OPERATION_MODE_UPDATED = 'updated';

  /**
   * @description Constructor
   * @param theTask The task record
   * @param operationMode Holds created/updated
   */
  public CustomerNudgeTaskCloudEventModel(Task theTask, String operationMode) {
    super(theTask, null);
    String pubsubId = theTask.Pub_Sub_Event_Id__c;

    this.ce_type =
      System.Label.ANZX_Customer_Nudge_event_ce_type + operationMode;
    this.ce_source = 'anzx.salesforce.appnotification.v1alpha1';
    this.ce_subject = 'Pub_Sub_Event_Id__c/' + pubsubId;
    this.ce_dataschema = System.Label.ANZX_Customer_Nudge_Event_Proto_Data_Schema;
    this.ce_partitionkey = 'Pub_Sub_Event_Id__c/' + pubsubId;
    this.ce_xtargets = 'Notification/' + pubsubId;
    this.systemData = new CloudEventSystemModel(
      theTask.LastModifiedDate,
      theTask.LastModifiedBy
    );
    this.ce_data = new CustomerNudgeTaskCloudDataModel(
      theTask,
      pubsubId,
      operationMode
    );
  }

  /**
   * @description this model is for customer nudge cloud event data part
   */
  public virtual class CustomerNudgeTaskCloudDataModel extends TaskCloudEventModel.TaskCloudEventDataModel {
    /**
     * @description Holds producer command key
     */
    public String producer_command_key { get; set; }
    /**
     * @description Holds idempotency key
     */
    public String idempotency_key { get; set; }
    /**
     * @description Holds notification
     */
    public Notification notification { get; set; }

    /**
     * @description Constructor
     * @param theTask The task record
     * @param pubsubId The pub sub event id
     * @param operationMode The operationMode
     */
    public CustomerNudgeTaskCloudDataModel(
      Task theTask,
      String pubsubId,
      String operationMode
    ) {
      this.producer_command_key = pubsubId;
      this.idempotency_key = pubsubId;

      String aemContentData = PUSH_TO_APP_REPOSITORY
        .queryCustomerTaskDataDetails(theTask.Customer_Task_Data__c)
        .AEM_Content_Data__c;

      if (
        String.isBlank(aemContentData) ||
        operationMode == OPERATION_MODE_UPDATED
      ) {
        return;
      }

      AemDataWrapper.Items item = (AemDataWrapper.Items) JSON.deserialize(
        aemContentData,
        AemDataWrapper.Items.class
      );
      this.notification = buildNotification(item, pubsubId);
    }

    private Notification buildNotification(
      AemDataWrapper.Items item,
      String pubsubId
    ) {
      return new Notification(
        item.title,
        item.subtitle + '\n' + item.bodyText,
        pubsubId,
        new IconUri(item.iconLightURI, item.iconDarkURI)
      );
    }
  }

  /**
   * @description this model is for holding notification details
   */
  public class Notification {
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
     * @description Constructor
     * @param title The title of aemcontendata
     * @param body The body of aemcontentdata
     * @param pubsubId The pubsubeventid of the task
     * @param iconuri The icon details of aemcontendata
     */
    public Notification(
      String title,
      String body,
      String pubsubId,
      IconUri iconuri
    ) {
      this.title = title;
      this.body = body;
      this.action_uri = System.Label.Push_Task_To_App_Deeplink + pubsubId;
      this.icon_uri = iconuri;
    }
  }

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

    /**
        * @description Constructor
         @param iconLightURI The iconLightURI of aemcontendata
         @param iconDarkURI The iconDarkURI of aemcontentdata
        */
    public IconUri(String iconLightURI, String iconDarkURI) {
      this.icon_light_uri = iconLightURI;
      this.icon_dark_uri = iconDarkURI;
    }
  }
}
