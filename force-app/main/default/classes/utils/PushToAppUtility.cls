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
    public static Customer_Task_Data__c createNotificationData(PushToAppWrapper.NotificationDataWrapper notifData){
        return new Customer_Task_Data__c(
            AEM_Content_Data__c = notifData.aemContentData
        );
    }


    /**
     * @description This method is used to create Notification Data Instance
     * @param taskData Task data to be utilized to create Customer Nudge Task
     * @param notifDataId notificationData record Id created when click on send now to link the task
     * @return Task Customer Nudge Task record instance to be created
     */
    public static Task createPushToAppTask(PushToAppWrapper.PushToAppTaskWrapper taskData, Id notifDataId){
        return new Task(
            Subject = taskData.subject+ ' - ' + TASK_TYPE,
            Type = TASK_TYPE,
            WhatId = taskData.whatId,
            WhoId = PUSH_TO_APP_REPOSITORY.queryCustomerContactId(taskData.whatId),
            ActivityDate = Date.parse(taskData.activityDate),
            Pub_Sub_Event_Id__c = CommonUtil.generateUUID(),
            Customer_Task_Configuration__c = taskData.notificationConfigId,
            Description = taskData.description,
            Call_To_Action__c = taskData.callToAction,
            Customer_Task_Data__c = notifDataId,
            RecordTypeId = RTTask.customerNudge,
            OwnerId = UserInfo.getUserId());
    }

}