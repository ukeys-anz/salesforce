/**
 * @description       : ManageOpsWorkflowRequestModal
 * @author            : Shivraj Kadam
 * @group             :
 * @last modified on  : 06-27-2024
 * @last modified by  : Shivraj Kadam
 **/
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class ManageOpsWorkflowRequestModal extends CalloutModel {
  /**
  * @description case_id
  */
  @AuraEnabled
  public String case_id { get; set; }
  /**
  * @description action
  */
  @AuraEnabled
  public String action { get; set; }
  /**
  * @description case_comments
  */
  @AuraEnabled
  public String case_comments { get; set; }
  /**
  * @description workflow_id
  */
  @AuraEnabled
  public String workflow_id { get; set; }

  /**
   * @description Represents details body for request action
   * @param json details body for request action
   * @return `ManageOpsWorkflowRequestModal` api response is serialised into ManageOpsWorkflowRequestModal
   */
  public static ManageOpsWorkflowRequestModal parse(String json) {
    return (ManageOpsWorkflowRequestModal) deserialize(
      json,
      ManageOpsWorkflowRequestModal.class
    );
  }
}
