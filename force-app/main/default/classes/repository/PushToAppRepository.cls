/**
 * @author Kopal Goswami
 * @since Sep 2024
 * @description  Helps to get push notification template name
 */
public with sharing class PushToAppRepository {
  /**
   * @description Retrieves notification templates based on the logged-in user's role and the recordtype.
   * @param recordId The Id of the record (e.g., Case) to determine applicable templates.
   * @param recordTypeId record type Id of the record
   * @return List of Customer_Task_Configuration__c records including Name and AEM content ID.
   */
  public List<Customer_Task_Configuration__c> queryNotificationConfigrecords(
    Id recordId,
    Id recordTypeId
  ) {
    if(String.isBlank(recordId) || String.isBlank(recordTypeId)){
      return new List<Customer_Task_Configuration__c>();
    }
    Id userRoleId = UserInfo.getUserRoleId();
    // Query Notification Configuration using the fetched role and record type name
    return [
      SELECT Id, AEM_Content_Id__c, Name
      FROM Customer_Task_Configuration__c
      WHERE
        Applicable_User_Role__c INCLUDES (
          :QueryRole.get(userRoleId).DeveloperName
        )
        AND Applicable_Record_Types__c INCLUDES (
          :QueryRT.of(recordId.getSObjectType())
            .get(recordTypeId)
            .getDeveloperName()
        )
        AND SObject_Type__c = :recordId.getSObjectType().toString()
      WITH USER_MODE
    ];
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
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Retreives the Customer Contact Id based on the task whatId
   * @param taskWhatId The whatId of the Task Record
   * @return PersonContactId if exist.
   */
  public Id queryCustomerContactId(Id taskWhatId) {
    if (String.isBlank(taskWhatId)) {
      return null;
    }
    String sObjectName = taskWhatId.getSObjectType().toString();
    String sObjectRecordTypeQuery =
      'SELECT Account.PersonContactId FROM ' +
      sObjectName +
      ' WHERE Id = :taskWhatId WITH USER_MODE LIMIT 1';
    sObject sObjectRecord = (sObject) Database.query(sObjectRecordTypeQuery);
    return (Id) sObjectRecord.getSobject('Account')?.get('PersonContactId');
  }

  /**
   * @description Fetch task details for creating cloud task event
   * @param taskId Task record Id
   * @return Task record details
   */
  public Task queryTaskDetails(Id taskId) {
    if (taskId == null) {
      return null;
    }
    return [
      SELECT
        Id,
        Description,
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
        Customer_Task_Configuration__r.Name,
        TaskNumber__c
      FROM Task
      WHERE Id = :taskId
      WITH USER_MODE
      LIMIT 1
    ] ?? null;
  }

  /**
   * @description Fetch task details for creating cloud task event
   * @param fieldsToQuery list of merged fields present in aem content data
   * @param recordId The Id of the record for which notification needs to send.
   * @return List of field values retrieved from database
   */
  public List<SObject> queryMergeFieldsData(
    Set<String> fieldsToQuery,
    Id recordId
  ) {
    if (fieldsToQuery.isEmpty() || String.isBlank(recordId)) {
      return new List<SObject>();
    }

    String sObjectName = recordId.getSObjectType().toString();
    String allFields = String.join(new List<String>(fieldsToQuery), ',');
    return Database.query(
      'SELECT ' +
        allFields +
        ' FROM ' +
        sObjectName +
        ' WHERE Id = :recordId WITH USER_MODE'
    );
  }

  /**
   * @description To query all the tasks records which needs to be updated archived
   * @return List<Task> list of Tasks in system to archive
   */
  public List<Task> queryCustomerNudgeTasksToArchive() {
    return [
      SELECT Id, Status
      FROM Task
      WHERE
        ActivityDate < TODAY
        AND RecordTypeId = :RTTask.customerNudge
        AND IsClosed != TRUE
    ];
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
    // Running query in System Mode because no read access given to AEM_Content_Data__c
    return [
      SELECT Id, AEM_Content_Data__c
      FROM Customer_Task_Data__c
      WHERE Id IN :customerTaskDataIds
      WITH SYSTEM_MODE
    ];
  }

  /**
   * @description Query OcvId of the Account
   * @param accountIds set of account Ids
   * @return List<Account> List of accounts with their ocvIds
   */
  public List<Account> queryAccountDetails(Set<Id> accountIds) {
    if (accountIds.isEmpty()) {
      return new List<Account>();
    }
    return [
      SELECT Id, OCV_ID__c, Source_System_Name__c, Source_System_ID__c
      FROM Account
      WHERE Id IN :accountIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Query OcvId of the Account
   * @param taskIds set of account Ids
   * @return List<Account> List of accounts with their ocvIds
   */
  public List<Task> queryTaskRecords(Set<Id> taskIds) {
    if (taskIds.isEmpty()) {
      return new List<Task>();
    }
    return [
      SELECT
        Id,
        Pub_Sub_Event_Id__c,
        LastModifiedDate,
        LastModifiedBy.Name,
        AccountId,
        Customer_Task_Data__c,
        Pega_CDH_Id__c,
        LastModifiedBy.Email,
        LastModifiedBy.UserName,
        OwnerId,
        Owner.Email,
        Owner.Name,
        Subject,
        Priority,
        Status,
        TaskNumber__c,
        Type,
        CreatedDate,
        Description,
        ActivityDate,
        WhatId,
        CompletedDateTime,
        RecordTypeId
      FROM Task
      WHERE Id IN :taskIds
      WITH USER_MODE
    ];
  }

  /**
   * @description Query related data of task records when owner is user
   * @param ownerIds List of Task records Owner Ids
   * @return List<User> User records
   */
  public List<User> getUsers(Set<Id> ownerIds) {
    if (ownerIds.isEmpty()) {
      return new List<User>();
    }
    return [
      SELECT Id, Username, Email
      FROM User
      WHERE Id IN :ownerIds
      WITH USER_MODE
    ];
  }
}