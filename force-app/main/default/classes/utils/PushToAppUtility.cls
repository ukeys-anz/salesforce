/**
 * @author Shivam Swaraj
 * @since Oct 2024
 * @description This class is used to create Task Instance, Notification Data Instance
 * various activity like fetching Notification Data, WhoId
 */
public with sharing class PushToAppUtility {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  private static final String TASK_TYPE = 'Push To App';

  /**
   * @description This method is used to create Notification Data Instance
   * @param notifData Notification Data Wrapper instance having values from UI
   * @return Customer_Task_Data__c instance to be created
   */
  public static Customer_Task_Data__c createNotificationData(String notifData) {
    return new Customer_Task_Data__c(AEM_Content_Data__c = notifData);
  }

  /**
   * @description This method is used to create Notification Data Instance
   * @param customerTaskData Notification Data Wrapper instance having values from UI
   * @param recordId Customer_Task_Data__c record Id
   * @return List<Customer_Action__c>
   */
  public static List<Customer_Action__c> createCustomerActions(
    CustomerActionWrapper customerTaskData,
    Id recordId
  ) {
    List<Customer_Action__c> actionsToInsert = new List<Customer_Action__c>();
    for (CustomerActionWrapper.Step step : customerTaskData.steps) {
      if (step.actions != null) {
        for (CustomerActionWrapper.Action action : step.actions) {
          Customer_Action__c customerActionRecord = new Customer_Action__c();
          customerActionRecord.RecordTypeId = RTCustomerAction.customerNotificationAction;
          customerActionRecord.Status__c = CustomerActionConstants.STATUS_UNSPECIFIED;
          customerActionRecord.Action_Name__c = action.description;
          customerActionRecord.Customer_Task_Data__c = recordId;
          customerActionRecord.Action_UUID__c = CommonUtil.generateUUID();
          actionsToInsert.add(customerActionRecord);
        }
      }
    }
    return actionsToInsert;
  }

  /**
   * @description This method is used to create Notification Data Instance
   * @param taskData Task data to be utilized to create Customer Nudge Task
   * @param notifDataId notificationData record Id created when click on send now to link the task
   * @return Task Customer Nudge Task record instance to be created
   */
  public static Task createPushToAppTask(
    PushToAppTaskWrapper taskData,
    Id notifDataId
  ) {
    return new Task(
      Subject = taskData.subject + ' - ' + TASK_TYPE,
      Type = TASK_TYPE,
      WhatId = taskData.whatId,
      WhoId = PUSH_TO_APP_REPOSITORY.queryCustomerContactId(taskData.whatId),
      ActivityDate = Date.parse(taskData.activityDate),
      Pub_Sub_Event_Id__c = CommonUtil.generateUUID(),
      Customer_Task_Configuration__c = taskData.notificationConfigId,
      Description = taskData.description,
      Customer_Task_Data__c = notifDataId,
      RecordTypeId = RTTask.customerNudge,
      OwnerId = UserInfo.getUserId()
    );
  }
}
