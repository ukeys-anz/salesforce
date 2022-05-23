/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2021
 * @description  IDRCollectionActions class is used to handle all collection related activities in case trigger
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
public with sharing class IDRCollectionActions {
  private static final String STOP_COLLEC_TASK_SUBJECT = 'STOP Collection is triggered from Salesforce for ';

  private static final String START_COLLEC_TASK_SUBJECT = 'START Collection is triggered from Salesforce for ';

  private static final String ACC_NUMBER_NA = 'N/A';

  private static Boolean isCollectionEventFailed = false;

  private static List<IDRCollectionsAccounts> stopCollectionAccList = new List<IDRCollectionsAccounts>();

  private static List<Task> stopCollectionTaskList = new List<Task>();

  private static List<IDRCollectionsAccounts> startCollectionAccList = new List<IDRCollectionsAccounts>();

  private static List<Task> startCollectionTaskList = new List<Task>();

  public static Map<Id, Product2> productNameMap = new Map<Id, Product2>();

  /**
   * @description method to copy customer account number in bankend field for collection purposes
   * @param record Case record from the trigger
   */
  public static void populateCollectionNumber(Case record) {
    if (record.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number__c) &&
        record.IDR_Account_Card_Policy_Number__c != ACC_NUMBER_NA &&
        String.isBlank(record.IDR_Collection_Number__c)
      ) {
        record.IDR_Collection_Number__c = record.IDR_Account_Card_Policy_Number__c;
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_2__c) &&
        record.IDR_Account_Card_Policy_Number_2__c != ACC_NUMBER_NA &&
        String.isBlank(record.IDR_Collection_Number_2__c)
      ) {
        record.IDR_Collection_Number_2__c = record.IDR_Account_Card_Policy_Number_2__c;
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_3__c) &&
        record.IDR_Account_Card_Policy_Number_3__c != ACC_NUMBER_NA &&
        String.isBlank(record.IDR_Collection_Number_3__c)
      ) {
        record.IDR_Collection_Number_3__c = record.IDR_Account_Card_Policy_Number_3__c;
      }
    }
  }

  /**
   * @description  validates the account number pattern when the user enters multiple account numbers in issue two or issue three
   * @param record The actual case record from the trigger
   * @param oldRecord trigger context variable to check on old values.
   */
  public static void validateAccNumberPattern(Case record, Case oldRecord) {
    if (record.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number__c) &&
        record.IDR_Account_Card_Policy_Number__c !=
        oldRecord.IDR_Account_Card_Policy_Number__c &&
        record.IDR_Account_Card_Policy_Number__c != ACC_NUMBER_NA &&
        !isAccountNumberRegexValid(record.IDR_Account_Card_Policy_Number__c)
      ) {
        record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_2__c) &&
        record.IDR_Account_Card_Policy_Number_2__c !=
        oldRecord.IDR_Account_Card_Policy_Number_2__c &&
        record.IDR_Account_Card_Policy_Number_2__c != ACC_NUMBER_NA &&
        !isAccountNumberRegexValid(record.IDR_Account_Card_Policy_Number_2__c)
      ) {
        record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
      }
      if (
        String.isNotBlank(record.IDR_Account_Card_Policy_Number_3__c) &&
        record.IDR_Account_Card_Policy_Number_3__c !=
        oldRecord.IDR_Account_Card_Policy_Number_3__c &&
        record.IDR_Account_Card_Policy_Number_3__c != ACC_NUMBER_NA &&
        !isAccountNumberRegexValid(record.IDR_Account_Card_Policy_Number_3__c)
      ) {
        record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
      }
    }
  }

  /**
   * @description  returns true if the account number matches the regex pattern
   * @param matcherValue value to match with regex pattern
   * @return true or false
   */
  private static Boolean isAccountNumberRegexValid(String matcherValue) {
    Matcher m = System.Pattern.compile(IDRConstants.MULTIPLE_ACCOUNT_NO_REGEX)
      .matcher(matcherValue);
    return m.matches();
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
    //get product names from Product2 table and store the mapping in local variable
    productNameMap = getProductNames(records);

    List<IDR_Collections_Event__e> collectionsCasesEventList = new List<IDR_Collections_Event__e>();

    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
        validateRecordForStopCollection(rec, oldRec);
        if (!stopCollectionAccList.isEmpty() && !rec.IsClosedOnCreate) {
          collectionsCasesEventList.add(
            buildCollectionEvent(rec, stopCollectionAccList)
          );
        }
      }
    }
    if (!collectionsCasesEventList.isEmpty()) {
      publishCollectionEvent(collectionsCasesEventList);
      stopCollectionAccList.clear();
    }
    if (!isCollectionEventFailed && !stopCollectionTaskList.isEmpty()) {
      insertSystemTasks(stopCollectionTaskList);
      stopCollectionTaskList.clear();
    }
  }
  /**
   * @description method to validate whether the complaint issues are eligible for stop collections
   * @param rec current record from trigger
   * @param oldRec old record from trigger
   */
  private static void validateRecordForStopCollection(Case rec, Case oldRec) {
    if (checkIssueOne(rec, oldRec)) {
      stopCollectionForIssueOne(rec);
    }
    if (checkIssueTwo(rec, oldRec)) {
      stopCollectionForIssueTwo(rec);
    }
    if (checkIssueThree(rec, oldRec)) {
      stopCollectionForIssueThree(rec);
    }
  }

  /**
   * @description method to add issue one into stop collection event and task creation if it is eligible
   * @param rec Case record from the trigger
   */
  private static void stopCollectionForIssueOne(Case rec) {
    for (
      String accNumber : String.valueOf(rec.IDR_Collection_Number__c).split(';')
    ) {
      stopCollectionAccList.add(
        new IDRCollectionsAccounts(
          accNumber,
          productNameMap.get(rec.Product__c).Name
        )
      );
      stopCollectionTaskList.add(
        populateSystemTask(rec, STOP_COLLEC_TASK_SUBJECT, accNumber)
      );
    }
  }

  /**
   * @description method to add issue two into stop collection event and task creation if it is eligible
   * @param rec Case record from the trigger
   */
  private static void stopCollectionForIssueTwo(Case rec) {
    for (
      String accNumber2 : String.valueOf(rec.IDR_Collection_Number_2__c)
        .split(';')
    ) {
      stopCollectionAccList.add(
        new IDRCollectionsAccounts(
          accNumber2,
          productNameMap.get(rec.IDR_Product_2__c).Name
        )
      );
      stopCollectionTaskList.add(
        populateSystemTask(rec, STOP_COLLEC_TASK_SUBJECT, accNumber2)
      );
    }
  }

  /**
   * @description method to add issue three into stop collection event and task creation if it is eligible
   * @param rec Case record from the trigger
   */
  private static void stopCollectionForIssueThree(Case rec) {
    for (
      String accNumber3 : String.valueOf(rec.IDR_Collection_Number_3__c)
        .split(';')
    ) {
      stopCollectionAccList.add(
        new IDRCollectionsAccounts(
          accNumber3,
          productNameMap.get(rec.IDR_Product_3__c).Name
        )
      );
      stopCollectionTaskList.add(
        populateSystemTask(rec, STOP_COLLEC_TASK_SUBJECT, accNumber3)
      );
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
      ) ||
      (oldRec.status != c.status &&
      c.status == IDRConstants.REOPENED_STATUS)) &&
      String.isNotBlank(c.IDR_Collection_Number__c) &&
      productNameMap.containsKey(c.Product__c) &&
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
      ) ||
      (oldRec.status != c.status &&
      c.status == IDRConstants.REOPENED_STATUS)) &&
      String.isNotBlank(c.IDR_Collection_Number_2__c) &&
      productNameMap.containsKey(c.IDR_Product_2__c) &&
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
      ) ||
      (oldRec.status != c.status &&
      c.status == IDRConstants.REOPENED_STATUS)) &&
      String.isNotBlank(c.IDR_Collection_Number_3__c) &&
      productNameMap.containsKey(c.IDR_Product_3__c) &&
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
   * @description populate task fields for creating task after successful collection or complaint event
   * @param c case record from the trigger
   * @param subject of the task record
   * @param accountNumber of the each issue
   * @return An instance of a Task
   */
  public static Task populateSystemTask(
    Case c,
    String subject,
    String accountNumber
  ) {
    String taskType = '';
    taskType = subject.contains('Collection')
      ? IDRConstants.TASK_TYPE_COLLECTION
      : IDRConstants.TASK_TYPE_COMPLIANTS_FLAG;
    return new Task(
      RecordTypeId = IDRConstants.IDR_SYSTEM_TASK_RT_ID,
      IDR_Collection_Number__c = accountNumber,
      WhatId = c.Id,
      Subject = subject + accountNumber,
      Status = 'Completed',
      Priority = 'High',
      Type = taskType
    );
  }

  /**
   * @description method to trigger collections activity in downstream systems when collections flag is turned on for a customer on a complaint.
   * @param c A case record
   * @param collectionAccList list of account number applicable for collections
   * @return Platform event record
   */
  private static IDR_Collections_Event__e buildCollectionEvent(
    Case c,
    List<IDRCollectionsAccounts> collectionAccList
  ) {
    IDR_Collections_Event__e collectionsEvent = new IDR_Collections_Event__e();
    collectionsEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    collectionsEvent.IDR_OCV_Id__c = c.OCV_Id__c; // When AR&C Customer are in SF replace this line with Account's OCV
    collectionsEvent.IDR_Complaint_Received_Date__c = c.IDR_Date_Received__c;

    if (c.isClosed) {
      collectionsEvent.IDR_Complaint_Resolved_Date__c = (c.ClosedDate == null
        ? System.now()
        : c.ClosedDate);
    }

    collectionsEvent.IDR_Complaint_Number__c = c.CaseNumber;
    collectionsEvent.IDR_Complaint_Status__c = c.Status;
    collectionsEvent.IDR_Complaint_Case_Id__c = c.Id;
    collectionsEvent.IDR_Account_Details__c = JSON.serialize(collectionAccList);
    collectionsEvent.IDR_Closed_On_Create__c = c.IsClosedOnCreate;

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
      if (!publishResults[i].isSuccess()) {
        isCollectionEventFailed = true;
      }
    }
    Lib_SystemLog log = new Lib_SystemLog(
      IDRCollectionActions.class.getName(),
      'publishCollectionEvent'
    );
    log.addDatabaseSaveResult(
      'IDR_Collections_Event__e',
      publishResults,
      collectionsEventList
    );
    log.insertLogAsync();
  }

  /**
   * @description method to insert collection tasks and handle errors
   * @param collectionTaskList List of collection tasks
   */
  public static void insertSystemTasks(List<Task> collectionTaskList) {
    List<Database.SaveResult> results = Database.insert(
      collectionTaskList,
      false
    );
    lib_systemLog log = new lib_systemLog(
      'IDRCollectionActions',
      'insertSystemTasks'
    );
    log.addDatabaseSaveResult('Task', results, collectionTaskList);
    log.insertLogAsync();
  }

  /**
   * @description method to trigger start collections activity in downstream systems when collections flag is turned on for an account number on a complaint.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
  public static void startCollections(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    Set<String> collectionAcctsList = new Set<String>();
    List<Case> finalList = new List<Case>();
    List<Id> caseIds = new List<Id>();
    Map<String, Set<Id>> startCollecMap = new Map<String, Set<Id>>();
    List<IDR_Collections_Event__e> collectionsStartEventList = new List<IDR_Collections_Event__e>();

    //get only closed records for start collections
    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (
        rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID &&
        rec.isClosed &&
        (oldRec == null ||
        oldRec.Status != rec.Status)
      ) {
        if (String.isNotBlank(rec.IDR_Collection_Number__c)) {
          collectionAcctsList.addAll(
            String.valueOf(rec.IDR_Collection_Number__c).split(';')
          );
        }
        if (String.isNotBlank(rec.IDR_Collection_Number_2__c)) {
          collectionAcctsList.addAll(
            String.valueOf(rec.IDR_Collection_Number_2__c).split(';')
          );
        }
        if (String.isNotBlank(rec.IDR_Collection_Number_3__c)) {
          collectionAcctsList.addAll(
            String.valueOf(rec.IDR_Collection_Number_3__c).split(';')
          );
        }
        caseIds.add(rec.Id);
        finalList.add(rec);
      }
    }

    //Build collection map
    startCollecMap = getStartCollectionMap(collectionAcctsList, caseIds);

    //validate all closed records whether the stop collection is already triggered or not
    for (Case rec : finalList) {
      validateRecordForStartCollection(rec, startCollecMap);
      if (!startCollectionAccList.isEmpty()) {
        collectionsStartEventList.add(
          buildCollectionEvent(rec, startCollectionAccList)
        );
      }
    }

    if (!collectionsStartEventList.isEmpty()) {
      publishCollectionEvent(collectionsStartEventList);
      startCollectionAccList.clear();
    }
    if (!isCollectionEventFailed && !startCollectionTaskList.isEmpty()) {
      insertSystemTasks(startCollectionTaskList);
      startCollectionTaskList.clear();
    }
  }

  /**
   * @description method for building start collection map.
   * @param collectionAcctsList collection accounts list
   * @param caseIds list of case ids
   * @return startCollectionMap start collection map
   */
  @SuppressWarnings(
    'PMD.ApexCRUDViolation'
  ) //Apex CRUD validation already added below
  public static Map<String, Set<Id>> getStartCollectionMap(
    Set<String> collectionAcctsList,
    List<Id> caseIds
  ) {
    Map<String, Set<Id>> startCollectionMap = new Map<String, Set<Id>>();
    for(String accNumber : collectionAcctsList){
      accNumber = (accNumber.replaceFirst('^0+', ''));
      collectionAcctsList.add(accNumber);
    }

    //query all stop collections task and put it in map with key as account number
    if (Task.sObjectType.getDescribe().isQueryable()) {
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
          if (
            !startCollectionMap.containsKey(taskRec.IDR_Collection_Number__c)
          ) {
            startCollectionMap.put(
              taskRec.IDR_Collection_Number__c,
              new Set<Id>{ taskRec.WhatId }
            );
          } else {
            startCollectionMap.get(taskRec.IDR_Collection_Number__c)
              .add(taskRec.WhatId);
          }
        }
      }
    }
    return startCollectionMap;
  }

  /**
   * @description method to validate whether the complaint issues are eligible for start collections
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   */
  private static void validateRecordForStartCollection(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    if (
      String.isNotBlank(rec.IDR_Collection_Number__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.Type) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue__c
      )
    ) {
      startCollectionForIssueOne(rec, startCollecMap);
    }
    if (
      String.isNotBlank(rec.IDR_Collection_Number_2__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.IDR_Issue_Type_2__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue_2__c
      )
    ) {
      startCollectionForIssueTwo(rec, startCollecMap);
    }
    if (
      String.isNotBlank(rec.IDR_Collection_Number_3__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.IDR_Issue_Type_3__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue_3__c
      )
    ) {
      startCollectionForIssueThree(rec, startCollecMap);
    }
  }

  /**
   * @description method to add issue one into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   */
  private static void startCollectionForIssueOne(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    for (
      String accNumber : String.valueOf(rec.IDR_Collection_Number__c).split(';')
    ) {
      String accNumberTrim = (accNumber.replaceFirst('^0+', ''));
      if (
        (startCollecMap.containsKey(accNumber) || startCollecMap.containsKey(accNumberTrim)) &&
        (startCollecMap.get(accNumber).contains(rec.Id) || startCollecMap.get(accNumberTrim).contains(rec.Id) )
      ) {
        if(
          (startCollecMap.get(accNumber).size() == 1 || startCollecMap.get(accNumberTrim).size() == 1) &&
           productNameMap.containsKey(rec.Product__c)
        ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber,
              productNameMap.get(rec.Product__c).Name
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber)
          );
        }
      }
    }
  }

  /**
   * @description method to add issue two into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   */
  private static void startCollectionForIssueTwo(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    for (
      String accNumber2 : String.valueOf(rec.IDR_Collection_Number_2__c)
        .split(';')
    ) {
      String accNumberTrim = (accNumber2.replaceFirst('^0+', ''));
      if (
        (startCollecMap.containsKey(accNumber2) || startCollecMap.containsKey(accNumberTrim)) &&
        (startCollecMap.get(accNumber2).contains(rec.Id) || startCollecMap.get(accNumberTrim).contains(rec.Id) ) 
      ) {
        if(
          (startCollecMap.get(accNumber2).size() == 1 ||startCollecMap.get(accNumberTrim).size() == 1  ) &&
          productNameMap.containsKey(rec.IDR_Product_2__c)
        ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber2,
              productNameMap.get(rec.IDR_Product_2__c).Name
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber2)
          );
        }
      }
    }
  }

  /**
   * @description method to add issue three into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   */
  private static void startCollectionForIssueThree(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    for (
      String accNumber3 : String.valueOf(rec.IDR_Collection_Number_3__c)
        .split(';')
    ) {
      String accNumberTrim = (accNumber3.replaceFirst('^0+', ''));
      if (
        (startCollecMap.containsKey(accNumber3) || startCollecMap.containsKey(accNumberTrim)) &&
        (startCollecMap.get(accNumber3).contains(rec.Id) || startCollecMap.get(accNumberTrim).contains(rec.Id)) 
      ) {
        if (
          (startCollecMap.get(accNumber3).size() == 1 || startCollecMap.get(accNumberTrim).size() == 1 ) &&
          productNameMap.containsKey(rec.IDR_Product_3__c)
          ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber3,
              productNameMap.get(rec.IDR_Product_3__c).Name
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber3)
          );
        }
      }
    }
  }

  /**
   * @description method to query product names using product ids
   * @param records List of case records from trigger
   * @return Map<Id, String> product id as key and Product Name as value
   */
  public static Map<Id, Product2> getProductNames(List<Case> records) {
    Set<Id> productIds = new Set<Id>();
    Map<Id, Product2> productMap = new Map<Id, Product2>();

    for (Case rec : records) {
      if (rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
        if (String.isNotBlank(rec.Product__c)) {
          productIds.add(rec.Product__c);
        }
        if (String.isNotBlank(rec.IDR_Product_2__c)) {
          productIds.add(rec.IDR_Product_2__c);
        }
        if (String.isNotBlank(rec.IDR_Product_3__c)) {
          productIds.add(rec.IDR_Product_3__c);
        }
      }
    }
    if (
      !productIds.isEmpty() && Product2.sObjectType.getDescribe().isQueryable()
    ) {
      productMap = new Map<Id, Product2>(
        [SELECT Id, Name FROM Product2 WHERE Id IN :productIds]
      );
    }
    return productMap;
  }
}
