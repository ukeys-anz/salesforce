/**
 * @description       : ManageOpsWorkflowRequestModel
 * @author            : Shivraj Kadam
 * @group             :
 * @last modified on  : 06-27-2024
 * @last modified by  : Shivraj Kadam
 **/
@SuppressWarnings('PMD.FieldNamingConventions,PMD.PropertyNamingConventions')
public with sharing class ManageOpsWorkflowRequestModel extends CalloutModel {
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
   * @return `ManageOpsWorkflowRequestModel` api response is serialised into ManageOpsWorkflowRequestModel
   */
  public static ManageOpsWorkflowRequestModel parse(String json) {
    return (ManageOpsWorkflowRequestModel) deserialize(
      json,
      ManageOpsWorkflowRequestModel.class
    );
  }
}
