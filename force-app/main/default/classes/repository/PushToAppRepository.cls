/**
 * @author Kopal Goswami
 * @since Sep 2024
 * @description  Helps to get push notification template name
 */
public with sharing class PushToAppRepository {
  /**
   * @description Retrieves notification templates based on the logged-in user's role and the recordtype.
   * @param userRoleInfo Logged in user role details
   * @param recordTypeName Record type name of the object from where push to app notification is triggered.
   * @param sObjectName The name of the object.
   * @return List of Customer_Task_Configuration__c records including Name and AEM content ID.
   */
  public List<Customer_Task_Configuration__c> queryNotificationConfigrecords(
    UserRole userRoleInfo,
    String recordTypeName,
    String sObjectName
  ) {
    // Query Notification Configuration using the fetched role and record type name
    return [
      SELECT Id, AEM_Content_Id__c, Name
      FROM Customer_Task_Configuration__c
      WHERE
        Applicable_User_Role__c INCLUDES (:userRoleInfo.DeveloperName)
        AND Applicable_Record_Types__c INCLUDES (:recordTypeName)
        AND SObject_Type__c = :sObjectName
      WITH USER_MODE
    ];
  }

  /**
   * @description Retrieves name of the record Type based on the sobject
   * @param recordId The Id of the record (e.g., Case) to determine applicable templates.
   * @param sObjectName The name of the object to determine applicable templates.
   * @return Name of the record Type
   */
  public String getRecordTypeName(Id recordId, String sObjectName) {
    String sObjectRecordTypeQuery =
      'SELECT RecordType.DeveloperName FROM ' +
      sObjectName +
      ' WHERE Id = :recordId LIMIT 1';

    SObject sObjectRecord = Database.query(sObjectRecordTypeQuery);
    return (String) sObjectRecord.getSObject('RecordType').get('DeveloperName');
  }

  /**
   * @description Retrieves details of the selected notification configuration by coach
   * @param templateName The Id or Name of the template
   * @return details of the selected notification configuration
   */
  public Customer_Task_Configuration__c selectedNotificationConfigDetail(
    String templateName
  ) {
    if (String.isBlank(templateName)) {
      return null;
    }

    return [
      SELECT Id, Name, Expire_After_Days__c
      FROM Customer_Task_Configuration__c
      WHERE AEM_Content_Id__c = :templateName
      WITH USER_MODE
    ];
  }

  /**
   * @description Retreives the Customer Contact Id based on the record Id
   * @param sobjectRecId The Id of the Sobject Record
   * @return PersonContactId if exist.
   */
  public Id queryCustomerContactId(Id sobjectRecId) {
    if (String.isBlank(sobjectRecId)) {
      return null;
    }
    String sObjectName = sobjectRecId.getSObjectType().toString();
    String sObjectRecordTypeQuery =
      'SELECT Account.PersonContactId FROM ' +
      sObjectName +
      ' WHERE Id = :sobjectRecId LIMIT 1';
    sObject sObjectRecord = (sObject) Database.query(sObjectRecordTypeQuery);
    return (Id) sObjectRecord.getSobject('Account')?.get('PersonContactId');
  }

  /**
   * @description Fetch task details for creating cloud task event
   * @param taskId Task record Id
   * @return Task record details
   */
  public Task queryTaskDetails(Id taskId) {
    return [
      SELECT
        Id,
        Description,
        Call_To_Action__c,
        Action_Taken__c,
        Action_Taken_Date_Time__c,
        Status,
        Subject,
        Type,
        Pub_Sub_Event_Id__c,
        Pega_CDH_Id__c,
        CreatedDate,
        LastModifiedDate,
        LastModifiedBy.Name,
        LastModifiedBy.Email,
        LastModifiedBy.UserName,
        LastModifiedBy.Lan_Id__c,
        Customer_Task_Data__r.AEM_Content_Data__c,
        Customer_Task_Configuration__r.Name,
        TaskNumber__c
      FROM Task
      WHERE Id = :taskId
    ];
  }

  /**
   * @description Fetch task details for creating cloud task event
   * @param fieldsToQuery list of merged fields present in aem content data
   * @param recordId The Id of the record for which notification needs to send.
   * @param sObjectName The Object name for which push notification is initiated
   * @return List of field values retrieved from database
   */
  public List<SObject> queryMergeFieldsData(
    Set<String> fieldsToQuery,
    Id recordId,
    String sObjectName
  ) {
    String allFields = String.join(new List<String>(fieldsToQuery), ',');
    List<SObject> recordsFromDatabase = Database.query(
      'SELECT ' + allFields + ' FROM ' + sObjectName + ' WHERE Id = :recordId'
    );
    return recordsFromDatabase;
  }

  /**
   * @description To query all the tasks records which needs to be updated archived
   * @return List<Task> list of Tasks in system to archive
   */
  public List<Task> queryCustomerNudgeTasksToArchive() {
    if (SObjectType.Task.isQueryable() == false) {
      return new List<Task>();
    }
    return [
      SELECT Id, Status
      FROM Task
      WHERE ActivityDate < TODAY AND RecordTypeId = :RTTask.customerNudge
    ];
  }

  /**
   * @description To query the Logged in user record access
   * @param userId Id of the logged in User
   * @param recordId The Id of the record for which notification needs to send.
   * @return Boolean value that determines whether the person can edit the record or not.
   */
  public Boolean queryUserAccess(String userId, String recordId) {
    UserRecordAccess userAccess = [
      SELECT HasEditAccess, RecordId
      FROM UserRecordAccess
      WHERE UserId = :userId AND RecordId = :recordId
      WITH USER_MODE
    ];
    return userAccess.HasEditAccess;
  }

  /**
   * @description Retrieves details of the customer task data record
   * @param customerTaskDataIds The Id of the record
   * @return details of the customer task data record
   */
  public List<Customer_Task_Data__c> queryCustomerTaskDataDetails(
    Set<Id> customerTaskDataIds
  ) {
    if (customerTaskDataIds.isEmpty()) {
      return new List<Customer_Task_Data__c>();
    }

    return [
      SELECT Id, AEM_Content_Data__c
      FROM Customer_Task_Data__c
      WHERE Id IN :customerTaskDataIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Query OcvId of the Account
   * @param accountIds set of account Ids
   * @return List<Account> List of accounts with their ocvIds
   */
  public List<Account> queryAccountOcvId(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, OCV_ID__c
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
    ];
  }
}
