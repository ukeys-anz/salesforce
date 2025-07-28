/**
 * @author Kopal Goswami
 * @since  May 2025
 * @description Wrapper Class for Tasks' metadata and data
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
public virtual without sharing class TaskCloudEventModel extends CloudEventModel {
  private static final Map<String, String> PRIORITY_TYPES = new Map<String, String>{
    'Normal' => 'TASK_PRIORITY_NORMAL',
    'High' => 'TASK_PRIORITY_HIGH'
  };

  /**
   * @description Constructor
   * @param theTask The task record
   * @param theAccount the account record
   */
  public TaskCloudEventModel(Task theTask, Account theAccount) {
    super();
    ce_source = 'com.anzx.salesforce.interaction.v1alpha1';
    ce_subject = 'TaskExternalId/' + theTask.Pega_CDH_Id__c;
    ce_partitionkey = 'TaskExternalId/' + theTask.Pega_CDH_Id__c;
    ce_type =
      System.Label.ANZX_Coach_Nudge_event_ce_type +
      theTask.Status.toLowerCase();
    ce_dataschema = System.Label.ANZX_Coach_Nudge_Event_Proto_Data_Schema;
    String sourceSystemName = '';
    if (
      theAccount?.Source_System_Name__c != null &&
      theAccount?.Source_System_ID__c != null
    ) {
      sourceSystemName =
        ',' +
        theAccount.Source_System_Name__c.toLowerCase() +
        '/' +
        theAccount?.Source_System_ID__c;
    }
    ce_xtargets = 'ocv/' + theAccount?.OCV_ID__c + sourceSystemName;
  }

  /**
   * @description the model for Case cloud event data part
   */
  public virtual class TaskCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
    /**
     * @description Task Details
     */
    public TaskDetailsModel taskDetails { get; set; }
    /**
     * @description get an instance of TaskCloudEventDataModel
     * @param theTask the Case record
     * @param theAccount the Account record
     * @param theOwner the User/Group record
     */
    public TaskCloudEventDataModel(
      Task theTask,
      Account theAccount,
      UserModel theOwner
    ) {
      this.taskDetails = new TaskDetailsModel(theTask, theAccount, theOwner);
    }
  }

  /**
   * @description Inner Wrapper Class for the Task Details
   */
  public class TaskDetailsModel {
    /**
     * @description Task subject
     */
    public String subject { get; set; }
    /**
     * @description Task priority
     */
    public String priority { get; set; }
    /**
     * @description Task status
     */
    public String status { get; set; }
    /**
     * @description Task taskNumber
     */
    public String taskNumber { get; set; }
    /**
     * @description Task type
     */
    public String type { get; set; }
    /**
     * @description Task expiryDate
     */
    public Date expiryDate { get; set; }
    /**
     * @description Task createdDateTime
     */
    public DateTime createdDateTime { get; set; }
    /**
     * @description Task completedDateTime
     */
    public DateTime completedDateTime { get; set; }
    /**
     * @description Task description
     */
    public String description { get; set; }
    /**
     * @description systemData
     */
    public CloudEventSystemModel systemData { get; set; }
    /**
     * @description Task What Id details
     */
    public ParentReferenceModel parentReference { get; set; }
    /**
     * @description Task customer details
     */
    public AccountModel customer { get; set; }
    /**
     * @description Owner details
     */
    public UserModel owner { get; set; }

    /**
     * @description get an instance of Task Details
     * @param theTask the Task record
     * @param theAccount the Account record
     * @param theOwner the Owner details
     *
     */
    public TaskDetailsModel(
      Task theTask,
      Account theAccount,
      UserModel theOwner
    ) {
      this.subject = theTask.Subject;
      this.priority = PRIORITY_TYPES.get(theTask.Priority);
      this.status = theTask.Status == 'New' ? 'TASK_STATE_NEW' : theTask.Status;
      this.taskNumber = theTask.TaskNumber__c;
      this.type = theTask.Type;
      this.expiryDate = theTask.ActivityDate;
      this.createdDateTime = theTask.CreatedDate;
      this.completedDateTime = theTask.CompletedDateTime;
      this.description = theTask.Description;
      this.systemData = new CloudEventSystemModel(
        theTask.LastModifiedDate,
        theTask.LastModifiedBy
      );
      this.parentReference = new ParentReferenceModel(theTask);
      this.customer = new AccountModel(theAccount);
      this.owner = theOwner;
    }
  }

  /**
   * @description Inner Wrapper Class for the parent details
   */
  public class ParentReferenceModel {
    /**
     * @description Task WhatId
     */
    public String externalId { get; set; }
    /**
     * @description Task WhatId's object name
     */
    public String objectName { get; set; }

    /**
     * @description get an instance of ParentReferenceModel
     * @param theTask the Task record
     */
    public ParentReferenceModel(Task theTask) {
      this.externalId = theTask?.WhatId;
      this.objectName = theTask.WhatId.getSObjectType().getDescribe().getName();
    }
  }
}
