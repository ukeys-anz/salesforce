/**
 * @author Aman Gupta
 * @since  01/2024
 * @description Wrapper Class for Tasks' metadata and data
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
public virtual without sharing class TaskCloudEventModel extends CloudEventModel {
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
    ce_dataschema =
      System.Label.ANZX_Coach_Nudge_Event_Proto_Data_Schema +
      '#CoachNudgeStatus' +
      theTask.Status +
      'Event';
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
    //Confirmation End
  }

  /**
   * @description the model for Case cloud event data part
   */
  public virtual class TaskCloudEventDataModel extends CloudEventModel.CloudEventDataModel {
  }
}
