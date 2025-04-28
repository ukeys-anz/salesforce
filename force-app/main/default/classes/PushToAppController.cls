/**
 * @author Kopal Goswami,Shivam Swaraj
 * @since Sep 2024
 * @description  Helps to get data based on AEM content Id from the AEM system ,
 * Customer Nudge Task Creation, Notification Data Creation
 */

public with sharing class PushToAppController {
  private static final PushToAppRepository PUSH_TO_APP_REPOSITORY = (PushToAppRepository) Lib_InstanceProvider.forType(
    PushToAppRepository.class
  );

  private static final DmlRepository DML_REPOSITORY = (DmlRepository) Lib_InstanceProvider.forType(
    DmlRepository.class
  );

  private static final String TASK_TYPE = 'Push To App';

  /**
   * @description Retrieves notification templates based on the logged-in user's role and the recordtype.
   * @param recordId The Id of the record (e.g., Case) to determine applicable templates.
   * @return List of Customer_Task_Configuration__c records including Name and AEM content ID.
   */
  @AuraEnabled(cacheable=true)
  public static List<Customer_Task_Configuration__c> getTemplateDetails(
    Id recordId
  ) {
    try {
      //Get the current logged-in user's role information
      Id userRole = UserInfo.getUserRoleId();
      UserRole userRoleInfo = QueryRole.get(userRole);

      //Get the name of the object for the given record
      String sObjectName = recordId.getSObjectType().toString();

      //Get the  RecordType name for the given record
      String recordTypeName = PUSH_TO_APP_REPOSITORY.getRecordTypeName(
        recordId,
        sObjectName
      );

      return PUSH_TO_APP_REPOSITORY.queryNotificationConfigrecords(
        userRoleInfo,
        recordTypeName,
        sObjectName
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description Get AEM Content data based on the user selected AEM Content Id
   * @param aemContentId The user selected template or AEM content Id
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return AemDataModel
   */
  @AuraEnabled
  public static AemDataWrapper getAemContentData(
    String aemContentId,
    Id recordId
  ) {
    try {
      if (String.isBlank(aemContentId) || recordId == null) {
        return null;
      }
      return AemApiRepository.getAemContentDataForNotification(
        aemContentId,
        recordId
      );
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }
  /**
   * @description Receive data from AEM and Sobject Record from where this push to app action triggered
   * to create Task and Notification Data in Salesforce
   * @param pushToAppTaskData wrapper class to store the values to create task.
   * @param customerTaskData wrapper class to store the values to create notification data.
   * @return Customer Nudge Task record Id post creation
   */
  @AuraEnabled
  public static Task createTaskAndRelatedRecords(
    PushToAppTaskWrapper pushToAppTaskData,
    CustomerTaskDataWrapper customerTaskData
  ) {
    try {
      Database.SaveResult notifDataResult = DML_REPOSITORY.doInsert(
        new Customer_Task_Data__c(
          AEM_Content_Data__c = customerTaskData.aemContentData
        )
      );
      Id insertedCustomerTaskDataId = notifDataResult.getId();
      List<Customer_Action__c> listOfCustomerActions = prepareCustomerActions(
        customerTaskData.aemContentObject,
        insertedCustomerTaskDataId
      );
      List<Database.SaveResult> customerActionResult = DML_REPOSITORY.doInsert(
        listOfCustomerActions
      );
      Task pushToAppTask = preparePushToAppTask(
        pushToAppTaskData,
        insertedCustomerTaskDataId
      );
      Database.SaveResult taskSaveResult = DML_REPOSITORY.doInsert(
        pushToAppTask
      );
      Task taskRecord = PUSH_TO_APP_REPOSITORY.queryTaskDetails(
        taskSaveResult.getId()
      );
      return taskRecord;
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description This method is used to create Notification Data Instance
   * @param customerTaskData Notification Data Wrapper instance having values from UI
   * @param recordId Customer_Task_Data__c record Id
   * @return List<Customer_Action__c>
   */
  private static List<Customer_Action__c> prepareCustomerActions(
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
  private static Task preparePushToAppTask(
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
      Call_To_Action__c = taskData.callToAction,
      Customer_Task_Data__c = notifDataId,
      RecordTypeId = RTTask.customerNudge,
      OwnerId = UserInfo.getUserId()
    );
  }
}
