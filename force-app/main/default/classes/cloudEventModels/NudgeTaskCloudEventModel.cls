/**
 * @author Aman Gupta
 * @since  01/2024
 * @description Wrapper Class for Coach Nudge Tasks' metadata and data
 */
@SuppressWarnings('PMD.PropertyNamingConventions')
public virtual without sharing class NudgeTaskCloudEventModel extends TaskCloudEventModel {
  /**
   * @description Constructor
   * @param theTask The task record
   * @param theAccount the account record
   */
  public NudgeTaskCloudEventModel(Task theTask, Account theAccount) {
    super(theTask, theAccount);
    this.ce_data = new NudgeTaskCloudEventDataModel(theTask);
  }

  /**
   * @description the model for dispute Case cloud event data part
   */
  public virtual class NudgeTaskCloudEventDataModel extends TaskCloudEventModel.TaskCloudEventDataModel {
    /**
     * @description interaction referance
     */
    public String interaction_reference { get; set; }
    /**
     * @description action referance
     */
    public String action_reference { get; set; }
    /**
     * @description outcome
     */
    public String outcome { get; set; }
    /**
     * @description outcome time
     */
    public String outcome_time { get; set; }

    /**
     * @description Constructor
     * @param theTask The task record
     */
    public NudgeTaskCloudEventDataModel(Task theTask) {
      this.interaction_reference = theTask.Pega_CDH_Id__c;
      this.action_reference = theTask.IDR_COR_ID__c;
      this.outcome = theTask.Status;
      this.outcome_time = String.valueOf(theTask.CompletedDateTime);
    }
  }
}
