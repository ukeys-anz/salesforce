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
      Id customerTaskDataRecId = insertCustomerTaskDataAndActions(
        customerTaskData
      );

      Id pushToAppTaskRecId = insertPushToAppTask(
        pushToAppTaskData,
        customerTaskDataRecId
      );

      Task taskRecord = PUSH_TO_APP_REPOSITORY.queryTaskDetails(
        pushToAppTaskRecId
      );

      return taskRecord;
    } catch (Exception objException) {
      throw CommonUtil.logException(objException);
    }
  }

  /**
   * @description create Notification Data record
   * @param customerTaskData notification data from the lwc component
   * @return Notification Data Record Id created
   */
  @TestVisible
  private static Id insertCustomerTaskDataAndActions(
    CustomerTaskDataWrapper customerTaskData
  ) {
    Database.SaveResult notifDataResult = DML_REPOSITORY.doInsert(
      new Customer_Task_Data__c(
        AEM_Content_Data__c = customerTaskData.aemContentData
      ),
      new DmlConfig().systemMode()
    );
    Id insertedCustomerTaskDataId = notifDataResult.getId();
    List<Customer_Action__c> listOfCustomerActions = PushToAppHelper.prepareCustomerActions(
      customerTaskData.aemContentObject,
      insertedCustomerTaskDataId
    );
    List<Database.SaveResult> customerActionResult = DML_REPOSITORY.doInsert(
      listOfCustomerActions,
      new DmlConfig().systemMode()
    );
    return insertedCustomerTaskDataId;
  }

  /**
   * @description create push to app task record
   * @param pushToAppTaskData task data from the lwc component
   * @param customerTaskDataRecId notification data record id created
   * @return Task Record Id created
   */
  @TestVisible
  private static Id insertPushToAppTask(
    PushToAppTaskWrapper pushToAppTaskData,
    Id customerTaskDataRecId
  ) {
    Task pushToAppTask = PushToAppHelper.preparePushToAppTask(
      pushToAppTaskData,
      customerTaskDataRecId
    );

    Database.SaveResult taskSaveResult = DML_REPOSITORY.doInsert(pushToAppTask);

    return taskSaveResult.getId();
  }
}
