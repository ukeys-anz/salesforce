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
  private static final Set<String> ARCHIVED_STATUSES = new Set<String>{
    'TASK_STATE_CUSTOMER_ARCHIVED',
    'TASK_STATE_COACH_ARCHIVED',
    'TASK_STATE_AUTO_ARCHIVED'
  };

  /**
   * @description Constructor
   * @param theTask The task record
   * @param theAccount Holds ocvId of the customer associated to the task
   * @param aemContentData Holds aemContentData Information
   * @param theOwner Holds Owner Information
   */
  public CustomerNudgeTaskCloudEventModel(
    Task theTask,
    Account theAccount,
    String aemContentData,
    UserModel theOwner
  ) {
    super(theTask, theAccount);
    String operationMode = 'updated';
    if (theTask.Status == 'New') {
      operationMode = 'created';
    } else if (ARCHIVED_STATUSES.contains(theTask.Status)) {
      operationMode = 'archived';
    }
    this.ce_type =
      System.Label.ANZX_Customer_Nudge_event_ce_type + operationMode;
    this.ce_source = 'anzx.salesforce.appnotification.v1alpha1';
    this.ce_subject = 'Pub_Sub_Event_Id__c/' + theTask.Pub_Sub_Event_Id__c;
    this.ce_dataschema = System.Label.ANZX_Customer_Nudge_Event_Proto_Data_Schema;
    this.ce_partitionkey = 'Pub_Sub_Event_Id__c/' + theTask.Pub_Sub_Event_Id__c;
    this.ce_data = new CustomerNudgeTaskCloudDataModel(
      theTask,
      aemContentData,
      theAccount,
      theOwner
    );
  }

  /**
   * @description this model is for customer nudge cloud event data part
   */
  public virtual class CustomerNudgeTaskCloudDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description Wrapper Class to hold ce_data inside the data node
     */
    public CustomerNudgeTaskCloudEventWrapper data { get; set; }
    /**
     * @description Constructor
     * @param theTask The task record
     * @param aemContentData Holds aemContentData Information
     * @param theAccount Holds Account Information
     * @param theOwner Holds Owner Information
     */
    public CustomerNudgeTaskCloudDataModel(
      Task theTask,
      String aemContentData,
      Account theAccount,
      UserModel theOwner
    ) {
      this.data = new CustomerNudgeTaskCloudEventWrapper(
        theTask,
        aemContentData,
        theAccount,
        theOwner
      );
    }
  }

  /**
   * @description this wrapper is for customer nudge cloud event ce_data part
   */
  public class CustomerNudgeTaskCloudEventWrapper extends TaskCloudEventModel.TaskCloudEventDataModel {
    /**
     * @description Holds producer command key
     */
    public String producerCommandKey { get; set; }
    /**
     * @description Holds idempotency key
     */
    public String idempotencyKey { get; set; }
    /**
     * @description Holds notification
     */
    public CustomerNudgeNotificationModel notification { get; set; }

    /**
     * @description Constructor
     * @param theTask The task record
     * @param aemContentData Holds aemContentData Information
     * @param theAccount Holds Account Information
     * @param theOwner Holds Owner Information
     */
    public CustomerNudgeTaskCloudEventWrapper(
      Task theTask,
      String aemContentData,
      Account theAccount,
      UserModel theOwner
    ) {
      super(theTask, theAccount, theOwner);
      this.producerCommandKey = theTask.Pub_Sub_Event_Id__c;
      this.idempotencyKey = theTask.Pub_Sub_Event_Id__c.split('_')[0];

      if (String.isBlank(aemContentData) || theTask.Status != 'New') {
        return;
      }

      AemDataModel.Items item = (AemDataModel.Items) JSON.deserialize(
        aemContentData,
        AemDataModel.Items.class
      );
      this.notification = new CustomerNudgeNotificationModel(item, theTask);
    }
  }
}
