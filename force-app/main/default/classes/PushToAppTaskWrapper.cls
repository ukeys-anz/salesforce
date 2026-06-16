/**
 * @description Wrapper Class for Customer Nudge Task Record.
 * @name PushToAppTaskWrapper
 */
public with sharing class PushToAppTaskWrapper {
  /**
   * @description Subject of the Task from Title of the AEM Fragement
   */
  @AuraEnabled
  public String subject { get; set; }
  /**
   * @description ActivityDate from PushTaskToApp LWC
   */
  @AuraEnabled
  public String activityDate { get; set; }
  /**
   * @description Description of the Task shown in Notification Preview
   */
  @AuraEnabled
  public String description { get; set; }
  /**
   * @description Customer_Task_Configuration__c selected by the coach
   */
  @AuraEnabled
  public String notificationConfigId { get; set; }
  /**
   * @description SObject record Id from where the action called out
   */
  @AuraEnabled
  public String whatId { get; set; }
  /**
   * @description Available actions from AEM fragment
   */
  @AuraEnabled
  public String callToAction { get; set; }
  /**
   * @description CaseNumber of the case
   */
  @AuraEnabled
  public String caseNumber { get; set; }
  /**
   * @description Template ID from Customer_Task_Configuration__c used for dynamic task configuration
   */
  @AuraEnabled
  public String templateId { get; set; }
}
