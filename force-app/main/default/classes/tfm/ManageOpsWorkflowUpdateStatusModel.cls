/**
 * @description       : ManageOpsWorkflowUpdateStatusModel
 * @author            : Anuj JAIN
 * @group             :
 * @last modified on  : 08-09-2024
 * @last modified by  : Anuj Jain
 **/
public with sharing class ManageOpsWorkflowUpdateStatusModel {
  /**
   * @description idValue
   */
  @AuraEnabled
  public String idValue { get; set; }
  /**
   * @description cobId
   */
  @AuraEnabled
  public String cobId { get; set; }
  /**
   * @description status
   */
  @AuraEnabled
  public String status { get; set; }
  /**
   * @description failedReason
   */
  @AuraEnabled
  public String failedReason { get; set; }
}
