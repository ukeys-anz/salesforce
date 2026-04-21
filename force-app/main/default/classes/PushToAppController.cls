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

  private static final UserInfoRepository USER_INFO = (UserInfoRepository) Lib_InstanceProvider.forType(
    UserInfoRepository.class
  );

  private static final string TASK_CREATION_FAILED = 'Task Creation Failed: We encountered an issue while creating the task. Raise a fault though TechAssist if the issue persist.';

  private static final string TEMPLATE_FETCH_ERROR = 'Unable to fetch template: There was an error retrieving content from AEM. Try again or raise a fault through TechAssist if the issue persists.';
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
    return PUSH_TO_APP_REPOSITORY.queryNotificationConfigrecords(
      recordId,
      recordTypeId
    );
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
    try {
      AemDataModel aemData = AemApiRepository.getAemContentDataForNotification(
        aemContentId,
        recordId
      );

      AemDataModel enrichedAemData = enrichAemData(aemData);

      return enrichedAemData;
    } catch (AemApiRepository.AccessErrorException ex) {
      throw new AuraHandledException(
        'Error fetching AEM template content.You don\'t have required permission to perform this action.'
      );
    } catch (AemApiRepository.ServerErrorException ex) {
      throw new AuraHandledException(
        'Error fetching AEM template content.The server encountered an unexpected error. Please retry after some time.'
      );
    } catch (Exception objException) {
      Logger.error(
          'Error fetching AEM template content for ' +
            aemContentId +
            ' for recordId ' +
            recordId +
            ' with error message: ',
          objException
        )
        .save();
      throw new AuraHandledException(TEMPLATE_FETCH_ERROR);
    }
  }

  /**
   * @description This method is used to update expiryDate and notificationConfigId nodes
   * only when expiryAfterDays is populated in the config record. This ensures AEM content
   * enrichment only runs when necessary and follows best practices for conditional operations.
   * @param aemData AemDataModel AEM content from AEM system
   * @return AemDataModel enriched AemDataModel or original if no enrichment needed
   */
  private static AemDataModel enrichAemData(AemDataModel aemData) {
    AemDataModel.Items item = aemData.data.pushToAppList.items[0];

    Customer_Task_Configuration__c config = PUSH_TO_APP_REPOSITORY.selectedNotificationConfigDetail(
      item.id
    );

    item.notificationConfigId = config?.Id;

    if (String.isNotBlank(item.subtitle)) {
      item.bodyText = item.subtitle + ' ' + item.bodyText;
    }

    //Only enrich expiry date if expiryAfterDays is populated
    if (config.Expire_After_Days__c == null) {
      return aemData;
    }

    Integer expireAfterDays = Integer.valueOf(config.Expire_After_Days__c);

    item.expiryDate = BusinessHours.add(
        QueryBusinessHours.get(PushToAppConstant.BUSINESS_HOURS_NAME).Id,
        System.now(),
        expireAfterDays * PushToAppConstant.MILLISECONDS_PER_DAY
      )
      .format('dd/MM/yyyy');

    return aemData;
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
      Customer_Task_Data__c custTaskRecord = new Customer_Task_Data__c(
        AEM_Content_Data__c = customerTaskData.aemContentData
      );

      DML_REPOSITORY.doInsert(custTaskRecord, new DMLConfig().systemMode());

      Id insertedCustomerTaskDataId = custTaskRecord.Id;

      List<Customer_Action__c> listOfCustomerActions = prepareCustomerActions(
        customerTaskData.aemContentObject,
        insertedCustomerTaskDataId
      );

      // As no edit access should be given to any users in the system, Insert Customer Action in system mode
      DML_REPOSITORY.doUpsert(
        listOfCustomerActions,
        new DmlConfig().systemMode()
      );
      Id taskWhoId = PUSH_TO_APP_REPOSITORY.queryCustomerContactId(
        pushToAppTaskData.whatId
      );

      Task pushToAppTask = preparePushToAppTask(
        pushToAppTaskData,
        insertedCustomerTaskDataId,
        taskWhoId
      );

      //Insert Task in System Mode because no edit access to be given to the fields in the system related to PushToApp
      DML_REPOSITORY.doInsert(pushToAppTask, new DmlConfig().systemMode());

      Task taskRecord = PUSH_TO_APP_REPOSITORY.queryTaskDetails(
        pushToAppTask.Id
      );

      return taskRecord;
    } catch (DMLException dmlException) {
      Logger.error(
          'Push To App Task and Related Records Creation Failed for ' +
            pushToAppTaskData.caseNumber +
            'with error message: ',
          dmlException
        )
        .save();
      throw new AuraHandledException(dmlException.getDMLMessage(0));
    } catch (Exception objException) {
      Logger.error(
          'Push To App Task and Related Records Creation Failed for ' +
            pushToAppTaskData.caseNumber +
            'with error message: ',
          objException
        )
        .save();
      throw new AuraHandledException(TASK_CREATION_FAILED);
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
      for (CustomerActionWrapper.Action action : step.actions) {
        if (action.actionUUID == null) {
          continue;
        }
        Customer_Action__c customerActionRecord = new Customer_Action__c();
        customerActionRecord.RecordTypeId = RTCustomerAction.customerNotificationAction;
        customerActionRecord.Action_Name__c = action.description;
        customerActionRecord.Customer_Task_Data__c = customerTaskDatarecordId;
        customerActionRecord.Action_UUID__c = action.actionUUID;
        actionsToInsert.add(customerActionRecord);
      }
    }
    return actionsToInsert;
  }

  /**
   * @description This method is used to create Notification Data Instance
   * @param taskData Task data to be utilized to create Customer Nudge Task
   * @param notifDataId notificationData record Id created when click on send now to link the task
   * @param taskWhoId whoid to be linked to the push to app task
   * @return Task Customer Nudge Task record instance to be created
   */
  private static Task preparePushToAppTask(
    PushToAppTaskWrapper taskData,
    Id notifDataId,
    Id taskWhoId
  ) {
    return new Task(
      Subject = taskData.subject +
        ' - ' +
        PushToAppConstant.TEMPLATE_TO_TASK_SUBJECT.get(taskData.templateId),
      Type = PushToAppConstant.TEMPLATE_TO_TASK_TYPE.get(taskData.templateId),
      WhatId = taskData.whatId,
      WhoId = taskWhoId,
      Case__c = taskData.whatId,
      ActivityDate = String.isNotBlank(taskData.activityDate)
        ? Date.parse(taskData.activityDate)
        : null,
      Pub_Sub_Event_Id__c = CommonUtil.generateUUID(),
      Customer_Task_Configuration__c = taskData.notificationConfigId,
      Description = taskData.description,
      Customer_Task_Data__c = notifDataId,
      RecordTypeId = RTTask.customerNudge,
      OwnerId = USER_INFO.getUser().Id
    );
  }
}
