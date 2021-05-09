/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2021
 * @description  IDRCollectionActions class is used to handle all collection related activities in case trigger
 */
public with sharing class IDRCollectionActions {
  private static final String STOP_COLLEC_QUEUE_NAME = 'Stop_Collections';

  private static final String START_COLLEC_QUEUE_NAME = 'Restart_Collections';

  private static Group stopCollecQueue = [
    SELECT id
    FROM group
    WHERE developername = :STOP_COLLEC_QUEUE_NAME AND Type = 'Queue'
  ];

  private static Group startCollecQueue = [
    SELECT id
    FROM group
    WHERE developername = :START_COLLEC_QUEUE_NAME AND Type = 'Queue'
  ];

  private static final String STOP_COLLEC_TASK_SUBJECT = 'Stop Collection is triggered from Salesforce for ';

  private static final String START_COLLEC_TASK_SUBJECT = 'Start Collection is triggered from Salesforce for ';

  private static final String ADD_COMPLAINT_TASK_SUBJECT = 'Add Complaint event is triggered from Salesforce';

  private static final String REMOVE_COMPLAINT_TASK_SUBJECT = 'Remove Complaint event is triggered from Salesforce';

  private static Set<Id> collectionProductIds = IDRConstants.getCollectionProductIds();

  /**
   * @description method to copy customer account number in bankend field for collection purposes
   * @param record Case record from the trigger
   */
  public static void populateCollectionNumber(Case record) {
    if (record.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number__c) &&
        String.isBlank(record.IDR_Collection_Number__c)
      ) {
        record.IDR_Collection_Number__c = record.IDR_Account_Card_Policy_Number__c;
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_2__c) &&
        String.isBlank(record.IDR_Collection_Number_2__c)
      ) {
        record.IDR_Collection_Number_2__c = record.IDR_Account_Card_Policy_Number_2__c;
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_3__c) &&
        String.isBlank(record.IDR_Collection_Number_3__c)
      ) {
        record.IDR_Collection_Number_3__c = record.IDR_Account_Card_Policy_Number_3__c;
      }
    }
  }

  /**
   * @description method to trigger stop collections activity in downstream systems when collections flag is turned on for an account number on a complaint.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  public static void stopCollections(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<String> collectionAcctsList = new List<String>();
    List<Task> collectionTaskList = new List<Task>();
    List<IDR_Collections_Event__e> collectionsCasesEventList = new List<IDR_Collections_Event__e>();

    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
        if (checkIssueOne(rec, oldRec)) {
          collectionAcctsList.add(rec.IDR_Account_Card_Policy_Number__c);
          collectionTaskList.add(
            populateSystemTask(
              rec,
              STOP_COLLEC_TASK_SUBJECT,
              rec.IDR_Account_Card_Policy_Number__c,
              rec.IDR_Collection_Number__c
            )
          );
          if (collectionProductIds.contains(rec.Product__c)) {
            collectionTaskList.add(
              populateUserTask(
                rec,
                'STOP',
                rec.IDR_Account_Card_Policy_Number__c
              )
            );
          }
        }
        if (checkIssueTwo(rec, oldRec)) {
          collectionAcctsList.add(rec.IDR_Account_Card_Policy_Number_2__c);
          collectionTaskList.add(
            populateSystemTask(
              rec,
              STOP_COLLEC_TASK_SUBJECT,
              rec.IDR_Account_Card_Policy_Number_2__c,
              rec.IDR_Collection_Number_2__c
            )
          );
          if (collectionProductIds.contains(rec.IDR_Product_2__c)) {
            collectionTaskList.add(
              populateUserTask(
                rec,
                'STOP',
                rec.IDR_Account_Card_Policy_Number_2__c
              )
            );
          }
        }
        if (checkIssueThree(rec, oldRec)) {
          collectionAcctsList.add(rec.IDR_Account_Card_Policy_Number_3__c);
          collectionTaskList.add(
            populateSystemTask(
              rec,
              STOP_COLLEC_TASK_SUBJECT,
              rec.IDR_Account_Card_Policy_Number_3__c,
              rec.IDR_Collection_Number_3__c
            )
          );
          if (collectionProductIds.contains(rec.IDR_Product_3__c)) {
            collectionTaskList.add(
              populateUserTask(
                rec,
                'STOP',
                rec.IDR_Account_Card_Policy_Number_3__c
              )
            );
          }
        }
        if (!collectionAcctsList.isEmpty()) {
          collectionsCasesEventList.add(
            buildCollectionEvent(rec, oldRec, collectionAcctsList)
          );
        }
      }
    }
    if (!collectionsCasesEventList.isEmpty() && !collectionTaskList.isEmpty()) {
      publishCollectionEvent(collectionsCasesEventList);
      insertCollectionTasks(collectionTaskList);
    }
  }

  /**
   * @description method to check if issue one is eligible for stop collections
   * @param c Case record from the trigger
   * @param oldRec Old Case record from the trigger
   * @return true or false
   */
  private static Boolean checkIssueOne(Case c, Case oldRec) {
    if (
      (oldRec == null ||
      !IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(oldRec.Type) ||
      !IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        oldRec.IDR_Subsequent_Issue__c
      )) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(c.Type) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        c.IDR_Subsequent_Issue__c
      )
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description method to check if issue two is eligible for stop collections
   * @param c Case record from the trigger
   * @param oldRec Old Case record from the trigger
   * @return true or false
   */
  private static Boolean checkIssueTwo(Case c, Case oldRec) {
    if (
      c.IDR_Second_Issue__c &&
      (oldRec == null ||
      !IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(
        oldRec.IDR_Issue_Type_2__c
      ) ||
      !IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        oldRec.IDR_Subsequent_Issue_2__c
      )) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(c.IDR_Issue_Type_2__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        c.IDR_Subsequent_Issue_2__c
      )
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description method to check if issue three is eligible for stop collections
   * @param c Case record from the trigger
   * @param oldRec Old Case record from the trigger
   * @return true or false
   */
  private static Boolean checkIssueThree(Case c, Case oldRec) {
    if (
      c.IDR_Third_Issue__c &&
      (oldRec == null ||
      !IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(
        oldRec.IDR_Issue_Type_3__c
      ) ||
      !IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        oldRec.IDR_Subsequent_Issue_3__c
      )) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(c.IDR_Issue_Type_3__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        c.IDR_Subsequent_Issue_3__c
      )
    ) {
      return true;
    }
    return false;
  }

  /**
   * @description populate task fields for creating possible systemic issue task
   * @param c case record from the trigger
   * @param subject of the task record
   * @param accountNumber of the each issue
   * @param collectionNumber of the each issue
   * @return An instance of a Task
   */
  @SuppressWarnings('PMD.ExcessiveParameterList')
  private static Task populateSystemTask(
    Case c,
    String subject,
    String accountNumber,
    String collectionNumber
  ) {
    return new Task(
      RecordTypeId = IDRConstants.IDR_COLLECTIONS_RT_ID,
      IDR_Collection_Number__c = collectionNumber,
      OwnerId = c.OwnerId,
      WhatId = c.Id,
      Subject = subject + accountNumber,
      Status = 'Completed',
      Priority = 'High'
    );
  }

  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param c A case record
   * @param oldCase An old case record
   * @param collectionAccList list of account number applicable for collections
   * @return Platform event record
   */
  private static IDR_Collections_Event__e buildCollectionEvent(
    Case c,
    Case oldCase,
    List<String> collectionAccList
  ) {
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    collectionsEvent.IDR_OCV_Id__c = null; // When AR&C Customer are in SF replace this line with Account's OCV
    collectionsEvent.IDR_Complaint_Received_Date__c = c.IDR_Date_Received__c;

    if (c.isClosed) {
      collectionsEvent.IDR_Complaint_Resolved_Date__c = (c.ClosedDate == null
        ? System.now()
        : c.ClosedDate);
      if (oldCase == null) {
        collectionsEvent.IDR_Closed_On_Create__c = true;
      }
    }

    collectionsEvent.IDR_Complaint_Number__c = c.CaseNumber;
    collectionsEvent.IDR_Complaint_Status__c = c.Status;
    collectionsEvent.IDR_Account_Details__c = JSON.serialize(collectionAccList);

    return collectionsEvent;
  }

  /**
   * @description method to publish collection event and handle errors
   * @param collectionsEventList List of collection events
   */
  private static void publishCollectionEvent(
    List<IDR_Collections_Event__e> collectionsEventList
  ) {
    List<Database.SaveResult> publishResults = EventBus.publish(
      collectionsEventList
    );
    for (Integer i = 0; i < publishResults.size(); i++) {
      Database.SaveResult sr = publishResults[i];
      if (!publishResults[i].isSuccess()) {
        for (Database.Error err : publishResults[i].getErrors()) {
          Lib_SystemLog.logAPIError(
            IDRCaseActions.class.getName(),
            'Error in publishing collection platform event for Case' +
            collectionsEventList[i].IDR_Complaint_Number__c,
            err.getMessage(),
            null,
            IDRCaseActions.class.getName(),
            null,
            null
          );
        }
      }
    }
  }

  /**
   * @description method to insert collection tasks and handle errors
   * @param collectionTaskList List of collection tasks
   */
  private static void insertCollectionTasks(List<Task> collectionTaskList) {
    List<Database.SaveResult> results = Database.insert(
      collectionTaskList,
      false
    );
    lib_systemLog log = new lib_systemLog(
      'IDRCollectionActions',
      'insertCollectionTasks'
    );
    log.addDatabaseSaveResult('Task', results, collectionTaskList);
    log.insertLog();
  }

  /**
   * @description method to trigger start collections activity in downstream systems when collections flag is turned on for an account number on a complaint.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  public static void startCollections(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Set<String> collectionAcctsList = new Set<String>();
    List<String> startCollectionList = new List<String>();
    List<Case> finalList = new List<Case>();
    List<Id> caseIds = new List<Id>();
    Map<String, Set<Id>> startCollecMap = new Map<String, Set<Id>>();
    List<Task> startTaskList = new List<Task>();
    List<IDR_Collections_Event__e> collectionsStartEventList = new List<IDR_Collections_Event__e>();

    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (
        rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID &&
        rec.isClosed == true &&
        (oldRec == null ||
        oldRec.isClosed == false)
      ) {
        collectionAcctsList.add(rec.IDR_Collection_Number__c);
        if (String.isNotBlank(rec.IDR_Collection_Number_2__c)) {
          collectionAcctsList.add(rec.IDR_Collection_Number_2__c);
        }
        if (String.isNotBlank(rec.IDR_Collection_Number_3__c)) {
          collectionAcctsList.add(rec.IDR_Collection_Number_3__c);
        }
        caseIds.add(rec.Id);
        finalList.add(rec);
      }
    }

    if (!collectionAcctsList.isEmpty()) {
      for (Task taskRec : [
        SELECT WhatId, IDR_Collection_Number__c
        FROM Task
        WHERE
          IDR_Collection_Number__c IN :collectionAcctsList
          AND WhatId IN (
            SELECT id
            FROM case
            WHERE isClosed = FALSE OR Id IN :caseIds
          )
      ]) {
        if (!startCollecMap.containsKey(taskRec.IDR_Collection_Number__c)) {
          startCollecMap.put(
            taskRec.IDR_Collection_Number__c,
            new Set<Id>{ taskRec.WhatId }
          );
        } else if (
          startCollecMap.containsKey(taskRec.IDR_Collection_Number__c)
        ) {
          Set<Id> caseIdSet = startCollecMap.get(
            taskRec.IDR_Collection_Number__c
          );
          caseIdSet.add(taskRec.WhatId);
          startCollecMap.put(taskRec.IDR_Collection_Number__c, caseIdSet);
        }
      }
    }

    for (Case rec : finalList) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (
        startCollecMap.containsKey(rec.IDR_Collection_Number__c) &&
        startCollecMap.get(rec.IDR_Collection_Number__c).size() == 1
      ) {
        startCollectionList.add(rec.IDR_Collection_Number__c);
        startTaskList.add(
          populateSystemTask(
            rec,
            START_COLLEC_TASK_SUBJECT,
            rec.IDR_Account_Card_Policy_Number__c,
            null
          )
        );
        if (collectionProductIds.contains(rec.Product__c)) {
          startTaskList.add(
            populateUserTask(
              rec,
              'START',
              rec.IDR_Account_Card_Policy_Number__c
            )
          );
        }
      }
      if (
        startCollecMap.containsKey(rec.IDR_Collection_Number_2__c) &&
        startCollecMap.get(rec.IDR_Collection_Number_2__c).size() == 1
      ) {
        startCollectionList.add(rec.IDR_Collection_Number_2__c);
        startTaskList.add(
          populateSystemTask(
            rec,
            START_COLLEC_TASK_SUBJECT,
            rec.IDR_Account_Card_Policy_Number_2__c,
            null
          )
        );
        if (collectionProductIds.contains(rec.IDR_Product_2__c)) {
          startTaskList.add(
            populateUserTask(
              rec,
              'START',
              rec.IDR_Account_Card_Policy_Number_2__c
            )
          );
        }
      }
      if (
        startCollecMap.containsKey(rec.IDR_Collection_Number_3__c) &&
        startCollecMap.get(rec.IDR_Collection_Number_3__c).size() == 1
      ) {
        startCollectionList.add(rec.IDR_Collection_Number_3__c);
        startTaskList.add(
          populateSystemTask(
            rec,
            START_COLLEC_TASK_SUBJECT,
            rec.IDR_Account_Card_Policy_Number_3__c,
            null
          )
        );
        if (collectionProductIds.contains(rec.IDR_Product_3__c)) {
          startTaskList.add(
            populateUserTask(
              rec,
              'START',
              rec.IDR_Account_Card_Policy_Number_3__c
            )
          );
        }
      }
      if (!startCollectionList.isEmpty()) {
        collectionsStartEventList.add(
          buildCollectionEvent(rec, oldRec, startCollectionList)
        );
      }
    }

    if (!collectionsStartEventList.isEmpty() && !startTaskList.isEmpty()) {
      publishCollectionEvent(collectionsStartEventList);
      insertCollectionTasks(startTaskList);
    }
  }

  /**
   * @description method to populate stop and start collection task and assigned to collections queue
   * @param c case record from trigger
   * @param type stop or start collections type
   * @param accountNumber account number of each issue
   */
  private static Task populateUserTask(
    Case c,
    String type,
    String accountNumber
  ) {
    Task userTask = new Task();
    if (type == 'Stop') {
      userTask.OwnerId = stopCollecQueue.Id;
    } else {
      userTask.OwnerId = startCollecQueue.Id;
    }
    userTask.recordTypeId = IDRConstants.IDR_COLLECTIONS_RT_ID;
    userTask.WhatId = c.Id;
    userTask.Subject = type + ' COLLECTIONS FOR ' + accountNumber;
    userTask.Status = 'Open';
    userTask.Priority = 'High';
    return userTask;
  }

  /**
   * @description method to publish complaints event flag to downstreams systems whenever the complaint is created and closed.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  public static void setComplaintsFlag(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<Task> complaintTaskList = new List<Task>();
    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (
        oldRec == null &&
        rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID
      ) {
        complaintTaskList.add(
          populateSystemTask(rec, ADD_COMPLAINT_TASK_SUBJECT, null, null)
        );
      }
      if (oldRec != null && rec.isClosed == true && oldRec.isClosed == false) {
        complaintTaskList.add(
          populateSystemTask(rec, REMOVE_COMPLAINT_TASK_SUBJECT, null, null)
        );
      }
    }
    if (!complaintTaskList.isEmpty()) {
      insert complaintTaskList;
    }
  }

  /**
   * @description method to populate compliant platform event fields
   * @param c case record from trigger
   * @param oldCase An old case record from trigger
   * @return Platform event record
   */
  private static IDR_OCV_Complaint_Event__e buildComplaintEvent(
    Case c,
    Case oldCase
  ) {
    IDR_OCV_Complaint_Event__e complaintEvent = new IDR_OCV_Complaint_Event__e();
    complaintEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    complaintEvent.IDR_OCV_Id__c = null; // When AR&C Customer are in SF replace this line with Account's OCV
    complaintEvent.IDR_Complaint_Created_Date__c = c.IDR_Date_Received__c;
    if (c.isClosed) {
      complaintEvent.IDR_Complaint_Resolved_Date__c = (c.ClosedDate == null
        ? System.now()
        : c.ClosedDate);
      if (oldCase == null) {
        complaintEvent.IDR_Closed_On_Create__c = true;
      }
    }
    complaintEvent.IDR_Complaint_Number__c = c.CaseNumber;
    complaintEvent.IDR_Complaint_Status__c = c.Status;
    complaintEvent.IDR_Product_Updated__c = true;
    complaintEvent.IDR_Complaint_Case_Id__c = c.Id;
    return complaintEvent;
  }
}
