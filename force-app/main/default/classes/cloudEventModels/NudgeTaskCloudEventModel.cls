/**
 * @author Aman Gupta
 * @since  01/2024
 * @description Wrapper Class for Coach Nudge Tasks' metadata and data
 */
@SuppressWarnings('PMD.ApexDoc, PMD.PropertyNamingConventions')
public virtual without sharing class NudgeTaskCloudEventModel extends TaskCloudEventModel {
  public NudgeTaskCloudEventModel(Task theTask, Account theAccount) {
    super(theTask, theAccount);
    this.ce_data = new NudgeTaskCloudEventDataModel(theTask);
  }

  /**
   * @description the model for dispute Case cloud event data part
   */
  public virtual class NudgeTaskCloudEventDataModel extends TaskCloudEventModel.TaskCloudEventDataModel {
    public String interaction_reference { get; set; }
    public String action_reference { get; set; }
    public String outcome { get; set; }
    public String outcome_time { get; set; }

    public NudgeTaskCloudEventDataModel(Task theTask) {
      this.interaction_reference = theTask.Pega_CDH_Id__c;
      this.action_reference = theTask.IDR_COR_ID__c;
      this.outcome = theTask.Status;
      this.outcome_time = String.valueOf(theTask.CompletedDateTime);
    }
  }
}
