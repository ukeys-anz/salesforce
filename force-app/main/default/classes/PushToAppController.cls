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

  private static final Map<String, String> TASK_TYPE = new Map<String, String>{
    'ACTIVITY_TYPE_PUSH_TO_APP' => 'Push to App'
  };

  /**
   * @description Retrieves notification templates based on the logged-in user's role and the recordtype.
   * @param recordId The Id of the record (e.g., Case) to determine applicable templates.
   * @param recordTypeId record type Id of the record
   * @return List of Customer_Task_Configuration__c records including Name and AEM content ID.
   */
  @AuraEnabled(cacheable=true)
  public static List<Customer_Task_Configuration__c> getTemplateDetails(
    Id recordId,
    Id recordTypeId
  ) {
    try {
      //Get the current logged-in user's role information
      Id userRoleId = UserInfo.getUserRoleId();
      UserRole userRoleInfo = QueryRole.get(userRoleId);

      //Get the name of the object for the given record
      String sObjectName = recordId.getSObjectType().toString();

      //Get the  RecordType name for the given record
      String recordTypeName = QueryRT.of(recordId.getSObjectType())
        .get(recordTypeId)
        .getDeveloperName();

      return PUSH_TO_APP_REPOSITORY.queryNotificationConfigrecords(
        userRoleInfo,
        recordTypeName,
        sObjectName
      );
    } catch (Exception objException) {
      throw CommonUtil.logExceptionWithMessage(
        'Error fetching Push-to-App Customer Nudge Template details for record id ' +
        recordId,
        objException
      );
    }
  }

  /**
   * @description Get AEM Content data based on the user selected AEM Content Id
   * @param aemContentId The user selected template or AEM content Id
   * @param recordId The Id of the record for which notification needs to be sent.
   * @return AemDataModel
   */
  @AuraEnabled
  public static AemDataModel getAemContentData(
    String aemContentId,
    Id recordId
  ) {
    if (String.isBlank(aemContentId) || recordId == null) {
      return null;
    }

    try {
      AemDataModel aemData = AemApiRepository.getAemContentDataForNotification(
        aemContentId,
        recordId
      );
      enrichAemData(aemData.data.pushToAppList.items[0]);
      return aemData;
    } catch (Exception objException) {
      throw CommonUtil.logExceptionWithMessage(
        'Error fetching AEM template content for ' +
          aemContentId +
          ' for recordId ' +
          recordId,
        objException
      );
    }
  }

  /**
   * @description This method is used to update expiryDate and notificationConfigId nodes
   * @param item AEMContentData Items node
   */
  private static void enrichAemData(AemDataModel.Items item) {
    Customer_Task_Configuration__c config = PUSH_TO_APP_REPOSITORY.selectedNotificationConfigDetail(
      item.id
    );
    Integer expireAfterDays = config?.Expire_After_Days__c != null
      ? Integer.valueOf(config.Expire_After_Days__c)
      : 0;

    item.expiryDate = expireAfterDays != 0
      ? DateTime.now().addDays(expireAfterDays).format('dd/MM/yyyy')
      : null;
    item.notificationConfigId = config?.Id;
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
      //Insert Customer Task Data in System Mode because no read access given to AEM_Content_Data__c field in the system
      Database.SaveResult notifDataResult = DML_REPOSITORY.doInsert(
        new Customer_Task_Data__c(
          AEM_Content_Data__c = customerTaskData.aemContentData
        ),
        new DmlConfig().systemMode()
      );
      Id insertedCustomerTaskDataId = notifDataResult.getId();
      List<Customer_Action__c> listOfCustomerActions = prepareCustomerActions(
        customerTaskData.aemContentObject,
        insertedCustomerTaskDataId
      );

      // As no edit access should be given to any users in the system, Insert Customer Action in system mode
      DML_REPOSITORY.doUpsert(
        listOfCustomerActions,
        new DmlConfig().systemMode()
      );

      Task pushToAppTask = preparePushToAppTask(
        pushToAppTaskData,
        insertedCustomerTaskDataId
      );

      //Insert Task in System Mode because no edit access to be given to the fields in the system related to PushToApp
      Database.SaveResult taskSaveResult = DML_REPOSITORY.doInsert(
        pushToAppTask,
        new DmlConfig().systemMode()
      );
      Task taskRecord = PUSH_TO_APP_REPOSITORY.queryTaskDetails(
        taskSaveResult.getId()
      );

      //Updating AEM Content To Include Task PubSubEventId in the deep link of the content
      enrichAemContentData(
        customerTaskData.aemContentObject,
        taskRecord.Pub_Sub_Event_Id__c
      );

      DML_REPOSITORY.doUpdate(
        new Customer_Task_Data__c(
          Id = insertedCustomerTaskDataId,
          AEM_Content_Data__c = customerTaskData.enrichedAemContentData()
        ),
        new DmlConfig().systemMode()
      );

      return taskRecord;
    } catch (Exception objException) {
      throw CommonUtil.logExceptionWithMessage(
        'Push To App Task and Related Records Creation Failed : ',
        objException
      );
    }
  }

  /**
   * @description This method is used to create Notification Data Instance
   * @param customerTaskData Notification Data Wrapper instance having values from UI
   * @param customerTaskDatarecordId Customer_Task_Data__c record Id
   * @return List<Customer_Action__c>
   */
  private static List<Customer_Action__c> prepareCustomerActions(
    CustomerActionWrapper customerTaskData,
    Id customerTaskDatarecordId
  ) {
    List<Customer_Action__c> actionsToInsert = new List<Customer_Action__c>();
    for (CustomerActionWrapper.Step step : customerTaskData.steps) {
      if (step.actions != null) {
        for (CustomerActionWrapper.Action action : step.actions) {
          Customer_Action__c customerActionRecord = new Customer_Action__c();
          customerActionRecord.RecordTypeId = RTCustomerAction.customerNotificationAction;
          customerActionRecord.Action_Name__c = action.description;
          customerActionRecord.Customer_Task_Data__c = customerTaskDatarecordId;
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
      Subject = taskData.subject +
        ' - ' +
        TASK_TYPE.get('ACTIVITY_TYPE_PUSH_TO_APP'),
      Type = 'ACTIVITY_TYPE_PUSH_TO_APP',
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

  /**
   * @description This method is used to update the deeplink of the AEM Content with Task PubSubEventId
   * @param aemContenData Customer Task Data content
   * @param taskPubSubEventId pubSubEventId of the Task record created
   */
  private static void enrichAemContentData(
    CustomerActionWrapper aemContenData,
    String taskPubSubEventId
  ) {
    aemContenData.action_uri =
      System.Label.Push_Task_To_App_Deeplink + taskPubSubEventId;
    for (CustomerActionWrapper.Step step : aemContenData.steps) {
      if (step.actions != null) {
        for (CustomerActionWrapper.Action action : step.actions) {
          action.deepLink = action.deepLink + '/' + taskPubSubEventId;
        }
      }
    }
  }
}
