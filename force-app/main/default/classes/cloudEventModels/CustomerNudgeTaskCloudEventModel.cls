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
    this.ce_source = 'com.anzx.salesforce.notification.v1alpha1';
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
     * @description Holds Task External Id
     */
    public String taskExternalId { get; set; }
    /**
     * @description Holds status of the task
     */
    public String status { get; set; }
    /**
     * @description Holds subject of the task
     */
    public String subject { get; set; }
    /**
     * @description Holds Description of the task
     */
    public String description { get; set; }
    /**
     * @description Holds CallToAction of the task
     */
    public String callToAction { get; set; }
    /**
     * @description Holds ActionTaken of the task
     */
    public String actionTaken { get; set; }
    /**
     * @description Holds ActionTakenDateTime of the task
     */
    public Datetime actionTakenDateTime { get; set; }
    /**
     * @description Holds Type of the task
     */
    public String type { get; set; }
    /**
     * @description Holds CreatedDate of the task
     */
    public Datetime createdDate { get; set; }
    /**
     * @description Holds LastModifiedDate of the task
     */
    public Datetime lastModifiedDate { get; set; }
    /**
     * @description Holds aemContentData of the task
     */
    public String aemContentData { get; set; }

    /**
     * @description Constructor
     * @param theTask The task record
     */
    public CustomerNudgeTaskCloudDataModel(Task theTask) {
      this.taskExternalId = theTask.Pub_Sub_Event_Id__c;
      this.status = theTask.Status;
      this.subject = PUSH_TO_APP_REPOSITORY.queryCustomerNudgeTaskDetails(
          theTask.Customer_Task_Configuration__c
        )
        .Name;
      this.description = theTask.Description;
      this.callToAction = theTask.Call_To_Action__c;
      this.actionTaken = theTask.Action_Taken__c;
      this.actionTakenDateTime = theTask.Action_Taken_Date_Time__c;
      this.type = theTask.Type;
      this.createdDate = theTask.CreatedDate;
      this.lastModifiedDate = theTask.LastModifiedDate;
      this.aemContentData = PUSH_TO_APP_REPOSITORY.queryCustomerTaskDataDetails(
          theTask.Customer_Task_Data__c
        )
        .AEM_Content_Data__c;
    }
  }
}
