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

  /**
   * @description Constructor
   * @param theTask The task record
   */
  public CustomerNudgeTaskCloudEventModel(Task theTask) {
    super(theTask, null);
    this.ce_type =
      System.Label.ANZX_Customer_Nudge_event_ce_type +
      theTask.Status.toLowerCase();
    this.ce_source = 'com.anzx.salesforce.customertask.v1alpha1';
    this.ce_subject = 'TaskExternalId/' + theTask.Pub_Sub_Event_Id__c;
    this.ce_dataschema = System.Label.ANZX_Customer_Nudge_Event_Proto_Data_Schema;
    this.ce_partitionkey = 'TaskExternalId/' + theTask.Pub_Sub_Event_Id__c;
    this.ce_xtargets = 'Notification/' + theTask.Pub_Sub_Event_Id__c;
    this.systemData = new CloudEventSystemModel(
      theTask.LastModifiedDate,
      theTask.LastModifiedBy
    );
    this.ce_data = new CustomerNudgeTaskCloudDataModel(theTask);
  }

  /**
   * @description the model for dispute Case cloud event data part
   */
  public virtual class CustomerNudgeTaskCloudDataModel extends TaskCloudEventModel.TaskCloudEventDataModel {
    /**
     * @description Holds producer command key
     */
    public String producer_command_key { get; set; }
    /**
     * @description Holds title of the aemcontendata
     */
    public String title { get; set; }
    /**
     * @description Holds body of the aemcontentdata
     */
    public String body { get; set; }
    /**
     * @description Holds subtitle and bodytext of the aemcontentdata
     */
    public String action_uri { get; set; }
    /**
     * @description Holds iconDarkURI of the aemcontentdata
     */
    public String iconDarkURI { get; set; }
    /**
     * @description Holds iconLightURI of the aemcontentdata
     */
    public String iconLightURI { get; set; }

    /**
     * @description Constructor
     * @param theTask The task record
     */
    public CustomerNudgeTaskCloudDataModel(Task theTask) {
      String deeplinkvalue = '';
      String aemContentData = PUSH_TO_APP_REPOSITORY.queryCustomerTaskDataDetails(
          theTask.Customer_Task_Data__c
        )
        .AEM_Content_Data__c;

      if (String.isBlank(aemContentData)) {
        return;
      }

      AemDataWrapper.Items itemValue = (AemDataWrapper.Items) JSON.deserialize(
        aemContentData,
        AemDataWrapper.Items.class
      );

      for (AemDataWrapper.Steps stepValue : itemValue.steps) {
        for (AemDataWrapper.actions actionValue : stepValue.actions) {
          deeplinkvalue +=
            actionValue.deepLink +
            theTask.Pub_Sub_Event_Id__c +
            ',';
        }
      }

      this.producer_command_key = theTask.Pub_Sub_Event_Id__c;
      this.title = itemValue.title;
      this.body = itemValue.subtitle + '\n' + itemValue.bodyText;
      this.action_uri = deeplinkvalue;
      this.iconDarkURI = itemValue.iconDarkURI;
      this.iconLightURI = itemValue.iconLightURI;
    }
  }
}
