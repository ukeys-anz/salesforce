/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2021
 * @description  IDRCollectionActions class is used to handle all collection related activities in case trigger
 * @group IDR(Internal Dispute Resolution)
 * @runTests IDRCollectionActionsTest
 * CyclomaticComplexity Surpressed : The complexity of this test class is more than it is expected.
 */
@SuppressWarnings('PMD.CyclomaticComplexity')
public with sharing class IDRCollectionActions {
  private static final String STOP_COLLEC_TASK_SUBJECT = 'STOP Collection is triggered from Salesforce for ';

  private static final String START_COLLEC_TASK_SUBJECT = 'START Collection is triggered from Salesforce for ';

  private static final String ACC_NUMBER_NA = 'N/A';

  private static Boolean isCollectionEventFailed = false;

  private static List<Task> stopCollectionTaskList = new List<Task>();

  private static List<Task> startCollectionTaskList = new List<Task>();

  /**
   * @description method to copy customer account number in bankend field for collection purposes
   * @param record Case record from the trigger
   */
  public static void populateCollectionNumber(Case record) {
    if (record.RecordTypeId != RTCase.customerComplaint) {
      return;
    }
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

  /**
   * @description  validates the account number pattern when the user enters multiple account numbers in issue two or issue three
   * @param record The actual case record from the trigger
   * @param oldRecord trigger context variable to check on old values.
   */
  public static void validateAccNumberPattern(Case record, Case oldRecord) {
    if (record.RecordTypeId != RTCase.customerComplaint) {
      return;
    }

    if (
      isInValidAccount(
        record,
        oldRecord,
        Case.IDR_Account_Card_Policy_Number__c
      )
    ) {
      record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
    }

    if (
      isInValidAccount(
        record,
        oldRecord,
        Case.IDR_Account_Card_Policy_Number_2__c
      )
    ) {
      record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
    }

    if (
      isInValidAccount(
        record,
        oldRecord,
        Case.IDR_Account_Card_Policy_Number_3__c
      )
    ) {
      record.addError(IDRConstants.INVALID_ACC_NO_MESSAGE);
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
    List<Id> caseIds = new List<Id>();
    List<IDR_Collections_Event__e> collectionsCasesEventList = buildCaseCollectionsEvent(
      records,
      oldMap
    );
    for (IDR_Collections_Event__e e : collectionsCasesEventList) {
      caseIds.add(e.IDR_Complaint_Case_Id__c);
    }
    publishCollectionEvent(collectionsCasesEventList);

    if (!isCollectionEventFailed && !stopCollectionTaskList.isEmpty()) {
      //AR-15023 Using IDRTaskActions.insertSystemTasks as it has without sharing, as task creation is failing due to user access
      IDRTaskActions.insertSystemTasks(
        stopCollectionTaskList,
        'Case Ids: ' + String.join(caseIds, ', ')
      );
      stopCollectionTaskList.clear();
    }
  }
  /**
   * @description method to validate whether the complaint issues are eligible for stop collections
   * @param rec current record from trigger
   * @param oldRec old record from trigger
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> validateRecordForStopCollection(
    Case rec,
    Case oldRec
  ) {
    List<IDRCollectionsAccounts> stopCollectionAccList = new List<IDRCollectionsAccounts>();
    if (checkIssueOne(rec, oldRec)) {
      stopCollectionAccList.addAll(
        stopCollectionForIssue(
          rec,
          rec.IDR_Collection_Number__c,
          rec.Product__c
        )
      );
    }
    if (checkIssueTwo(rec, oldRec)) {
      stopCollectionAccList.addAll(
        stopCollectionForIssue(
          rec,
          rec.IDR_Collection_Number_2__c,
          rec.IDR_Product_2__c
        )
      );
    }
    if (checkIssueThree(rec, oldRec)) {
      stopCollectionAccList.addAll(
        stopCollectionForIssue(
          rec,
          rec.IDR_Collection_Number_3__c,
          rec.IDR_Product_3__c
        )
      );
    }
    return stopCollectionAccList;
  }
  /**
   * @description method to add issue into stop collection event and task creation if it is eligible
   * @param rec Case record from the trigger
   * @param collectionNumber Collection Number of case record
   * @param productId  of case record
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> stopCollectionForIssue(
    Case rec,
    String collectionNumber,
    String productId
  ) {
    List<IDRCollectionsAccounts> stopCollectionAccList = new List<IDRCollectionsAccounts>();
    for (String accNumber : collectionNumber.split(';')) {
      if (accNumber == ACC_NUMBER_NA) {
        continue;
      }
      stopCollectionAccList.add(
        new IDRCollectionsAccounts(
          accNumber,
          QueryProducts.getById(productId)?.Name,
          rec.IDR_Product_Category__c
        )
      );
      stopCollectionTaskList.add(
        populateSystemTask(rec, STOP_COLLEC_TASK_SUBJECT, accNumber)
      );
    }
    return stopCollectionAccList;
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
      checkStatusWithIssueTypes(c, oldRec, 1) ||
      //AR-14452 Below scenario is for shell cases ingested by NLP model, hence why it only in checkIssueOne method
      ((String.isBlank(oldRec.IDR_Account_Card_Policy_Number__c) ||
      oldRec.IDR_Account_Card_Policy_Number__c == 'N/A') &&
      oldRec.IDR_Account_Card_Policy_Number__c !=
      c.IDR_Account_Card_Policy_Number__c)) &&
      String.isNotBlank(c.IDR_Collection_Number__c) &&
      (QueryProducts.getById(c.Product__c) != null ||
      c.IDR_Product_Category__c != null) &&
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
      checkStatusWithIssueTypes(c, oldRec, 2)) &&
      String.isNotBlank(c.IDR_Collection_Number_2__c) &&
      (QueryProducts.getById(c.IDR_Product_2__c) != null ||
      c.IDR_Product_Category__c != null) &&
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
      checkStatusWithIssueTypes(c, oldRec, 3)) &&
      String.isNotBlank(c.IDR_Collection_Number_3__c) &&
      (QueryProducts.getById(c.IDR_Product_3__c) != null ||
      c.IDR_Product_Category__c != null) &&
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

    if (c.IsClosed) {
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
    if (collectionsEventList.isEmpty()) {
      return;
    }
    List<Database.SaveResult> publishResults = EventBus.publish(
      collectionsEventList
    );
    for (Integer i = 0; i < publishResults.size(); i++) {
      if (!publishResults[i].isSuccess()) {
        isCollectionEventFailed = true;
      }
    }
    Logger.error('', publishResults);
    Logger.saveLog();
  }

  /**
   * @description method to insert collection tasks and handle errors
   * @param collectionTaskList List of collection tasks
   * @param strFailureMessage Message for Logger if Database.insert fails
   */
  public static void insertSystemTasks(
    List<Task> collectionTaskList,
    String strFailureMessage
  ) {
    List<Database.SaveResult> results = Database.insert(
      collectionTaskList,
      false
    );
    Logger.error(strFailureMessage, results);
    Logger.saveLog();
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
    List<Case> finalList = new List<Case>();
    List<Id> caseIds = new List<Id>();
    Map<String, Set<Id>> startCollecMap = new Map<String, Set<Id>>();
    List<IDR_Collections_Event__e> collectionsStartEventList = new List<IDR_Collections_Event__e>();

    //get only closed records for start collections
    List<Case> casesUpdatedwithStatus = ListUtil.filter(records, oldMap)
      .changed(Case.Status)
      .equals(Case.RecordTypeId, RTCase.customerComplaint)
      .equals(Case.IsClosed, true)
      .toList();
    for (Case rec : casesUpdatedwithStatus) {
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

    //Build collection map (will ony contain trimmed account numbers)
    startCollecMap = getStartCollectionMap(collectionAcctsList, caseIds);

    List<IDRCollectionsAccounts> startCollectionAccList;
    //validate all closed records whether the stop collection is already triggered or not
    for (Case rec : finalList) {
      startCollectionAccList = validateRecordForStartCollection(
        rec,
        startCollecMap
      );
      if (!startCollectionAccList.isEmpty()) {
        collectionsStartEventList.add(
          buildCollectionEvent(rec, startCollectionAccList)
        );
      }
    }

    if (!collectionsStartEventList.isEmpty()) {
      publishCollectionEvent(collectionsStartEventList);
    }
    if (!isCollectionEventFailed && !startCollectionTaskList.isEmpty()) {
      insertSystemTasks(
        startCollectionTaskList,
        'Case Ids: ' + String.join(caseIds, ', ')
      );
      startCollectionTaskList.clear();
    }
  }

  /**
   * @description method for building start collection map.
   * @param collectionAcctsList collection accounts list
   * @param caseIds list of case ids
   * @return startCollectionMap start collection map
   */
  public static Map<String, Set<Id>> getStartCollectionMap(
    Set<String> collectionAcctsList,
    List<Id> caseIds
  ) {
    Map<String, Set<Id>> startCollectionMap = new Map<String, Set<Id>>();
    for (String accNumber : collectionAcctsList) {
      if (accNumber.length() < 23) {
        collectionAcctsList.add(accNumber.leftPad(23, '0'));
      }
      accNumber = (accNumber.replaceFirst('^0+', ''));
      collectionAcctsList.add(accNumber);
    }

    //query all stop collections task and put it in map with key as account number
    if (
      Task.SObjectType.getDescribe().isQueryable() &&
      (!collectionAcctsList.isEmpty())
    ) {
      for (Task taskRec : [
        SELECT WhatId, IDR_Collection_Number__c
        FROM Task
        WHERE
          IDR_Collection_Number__c IN :collectionAcctsList
          AND WhatId IN (
            SELECT Id
            FROM Case
            WHERE IsClosed = FALSE OR Id IN :caseIds
          )
      ]) {
        // Only build startCollectionMap on trimmed Account Numbers.
        if (String.isBlank(taskRec.IDR_Collection_Number__c)) {
          continue;
        }
        String strAccountNumber = taskRec.IDR_Collection_Number__c.replaceFirst(
          '^0+',
          ''
        );
        if (!startCollectionMap.containsKey(strAccountNumber)) {
          startCollectionMap.put(
            strAccountNumber,
            new Set<Id>{ taskRec.WhatId }
          );
        } else {
          startCollectionMap.get(strAccountNumber).add(taskRec.WhatId);
        }
      }
    }
    return startCollectionMap;
  }

  /**
   * @description method to validate whether the complaint issues are eligible for start collections
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> validateRecordForStartCollection(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    List<IDRCollectionsAccounts> startCollectionAccList = new List<IDRCollectionsAccounts>();
    if (
      String.isNotBlank(rec.IDR_Collection_Number__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.Type) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue__c
      )
    ) {
      startCollectionAccList.addAll(
        startCollectionForIssueOne(rec, startCollecMap)
      );
    }
    if (
      String.isNotBlank(rec.IDR_Collection_Number_2__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.IDR_Issue_Type_2__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue_2__c
      )
    ) {
      startCollectionAccList.addAll(
        startCollectionForIssueTwo(rec, startCollecMap)
      );
    }
    if (
      String.isNotBlank(rec.IDR_Collection_Number_3__c) &&
      IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(rec.IDR_Issue_Type_3__c) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(
        rec.IDR_Subsequent_Issue_3__c
      )
    ) {
      startCollectionAccList.addAll(
        startCollectionForIssueThree(rec, startCollecMap)
      );
    }
    return startCollectionAccList;
  }

  /**
   * @description method to add issue one into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> startCollectionForIssueOne(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    List<IDRCollectionsAccounts> startCollectionAccList = new List<IDRCollectionsAccounts>();

    for (
      String accNumber : String.valueOf(rec.IDR_Collection_Number__c).split(';')
    ) {
      if (accNumber == ACC_NUMBER_NA) {
        continue;
      }
      String accNumberTrim = (accNumber.replaceFirst('^0+', ''));
      Set<Id> stCaseIds;
      if (
        (stCaseIds = startCollecMap.get(accNumberTrim)) != null &&
        stCaseIds.contains(rec.Id)
      ) {
        if (
          (stCaseIds.size() == 1) &&
          QueryProducts.getById(rec.Product__c) != null
        ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber,
              QueryProducts.getById(rec.Product__c)?.Name,
              null
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber)
          );
        }
      }
    }
    return startCollectionAccList;
  }

  /**
   * @description method to add issue two into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> startCollectionForIssueTwo(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    List<IDRCollectionsAccounts> startCollectionAccList = new List<IDRCollectionsAccounts>();

    for (
      String accNumber2 : String.valueOf(rec.IDR_Collection_Number_2__c)
        .split(';')
    ) {
      if (accNumber2 == ACC_NUMBER_NA) {
        continue;
      }
      String accNumberTrim = (accNumber2.replaceFirst('^0+', ''));
      Set<Id> stCaseIds;
      if (
        ((stCaseIds = startCollecMap.get(accNumber2)) != null &&
        stCaseIds.contains(rec.Id)) ||
        ((stCaseIds = startCollecMap.get(accNumberTrim)) != null &&
        stCaseIds.contains(rec.Id))
      ) {
        if (
          (stCaseIds.size() == 1) &&
          QueryProducts.getById(rec.IDR_Product_2__c) != null
        ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber2,
              QueryProducts.getById(rec.IDR_Product_2__c)?.Name,
              null
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber2)
          );
        }
      }
    }
    return startCollectionAccList;
  }

  /**
   * @description method to add issue three into start collection event and task list
   * @param rec current case record from the trigger
   * @param startCollecMap Map with account number as key and set of case ids as values
   * @return List<IDRCollectionsAccounts> collection account list
   */
  private static List<IDRCollectionsAccounts> startCollectionForIssueThree(
    Case rec,
    Map<String, Set<Id>> startCollecMap
  ) {
    List<IDRCollectionsAccounts> startCollectionAccList = new List<IDRCollectionsAccounts>();

    for (
      String accNumber3 : String.valueOf(rec.IDR_Collection_Number_3__c)
        .split(';')
    ) {
      if (accNumber3 == ACC_NUMBER_NA) {
        continue;
      }
      String accNumberTrim = (accNumber3.replaceFirst('^0+', ''));
      Set<Id> stCaseIds;
      if (
        ((stCaseIds = startCollecMap.get(accNumber3)) != null &&
        stCaseIds.contains(rec.Id)) ||
        ((stCaseIds = startCollecMap.get(accNumberTrim)) != null &&
        stCaseIds.contains(rec.Id))
      ) {
        if (
          (stCaseIds.size() == 1) &&
          QueryProducts.getById(rec.IDR_Product_3__c) != null
        ) {
          startCollectionAccList.add(
            new IDRCollectionsAccounts(
              accNumber3,
              QueryProducts.getById(rec.IDR_Product_3__c)?.Name,
              null
            )
          );
          startCollectionTaskList.add(
            populateSystemTask(rec, START_COLLEC_TASK_SUBJECT, accNumber3)
          );
        }
      }
    }
    return startCollectionAccList;
  }

  /**
   * @description method to combine Type nad Subsequent Issue Type and determine if they are collections related.
   * @param strIssueType Primary type of Issue
   * @param strSubIssueType Secondary type of Issue
   * @return Boolean if Issue Type and Subsequent Issue Type together represent a collection issue.
   */
  public static Boolean isCollectionsIssue(
    String strIssueType,
    String strSubIssueType
  ) {
    return IDRConstants.ISSUE_TYPE_COLLECTIONS.contains(strIssueType) &&
      IDRConstants.SUB_ISSUE_TYPE_COLLECTIONS.contains(strSubIssueType);
  }
  /**
   * @description method to check if Issue Types and Sub-Issue Types are changed on Complaint.
   * @param newRecord New Version of Record
   * @param oldRecord Old Version of Record
   * @return Boolean if Issue Type and Subsequent Issue Type changed.
   */
  @testVisible
  private static Boolean checkForIssueTypesChanged(
    Case newRecord,
    Case oldRecord
  ) {
    if (oldRecord == null || newRecord.Status == IDRConstants.REOPENED_STATUS) {
      return true;
    }
    List<SObjectField> changedfieldAPIName = RecordComparisonUtil.detectWhichFieldWasChangedAndNotEqualNull(
      newRecord,
      oldRecord,
      IDRConstants.COLLECTIONS_FIELDS
    );

    return !changedfieldAPIName.isEmpty();
  }
  /**
   * @description method to check if Account Policy Number is invalid
   * @param newRecord new Case record
   * @param oldRecord old Case record
   * @param accPolicyNumber Account Policy Number
   * @return Boolean which indicates its an invalid Account Policy Number
   */
  @testVisible
  private static Boolean isInValidAccount(
    Case newRecord,
    Case oldRecord,
    SObjectField accPolicyNumber
  ) {
    if (newRecord.get(accPolicyNumber) == null) {
      return false;
    }
    if (
      RecordComparisonUtil.fieldWasChanged(
        newRecord,
        oldRecord,
        accPolicyNumber
      ) &&
      String.valueOf(newRecord.get(accPolicyNumber)) != ACC_NUMBER_NA &&
      !isAccountNumberRegexValid(String.valueOf(newRecord.get(accPolicyNumber)))
    ) {
      return true;
    }

    return false;
  }

  /**
   * @description method to populate IDR Collection Events
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   * @return List<IDR_Collections_Event__e> Filtered list of IDR Collection Events
   */
  private static List<IDR_Collections_Event__e> buildCaseCollectionsEvent(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<IDR_Collections_Event__e> collectionsCasesEventList = new List<IDR_Collections_Event__e>();
    List<IDRCollectionsAccounts> stopCollectionAccList = new List<IDRCollectionsAccounts>();

    for (Case rec : records) {
      if (rec.RecordTypeId != RTCase.customerComplaint) {
        continue;
      }
      Case oldRec = (Case) oldMap.get(rec.Id);
      if (!checkForIssueTypesChanged(rec, oldRec)) {
        continue;
      }
      stopCollectionAccList = validateRecordForStopCollection(rec, oldRec);
      if (!stopCollectionAccList.isEmpty() && !rec.IsClosedOnCreate) {
        collectionsCasesEventList.add(
          buildCollectionEvent(rec, stopCollectionAccList)
        );
      }
    }
    return collectionsCasesEventList;
  }
  /**
   * @description method to check Issue Type is changed on status changed
   * @param newCase New Case record in current  trigger context
   * @param oldRec old Case record in current  trigger context
   * @param issueNumber indicates IssueType Number
   * @return Boolean if stop collection should trigger or not
   */
  private static Boolean checkStatusWithIssueTypes(
    Case newCase,
    Case oldRec,
    Integer issueNumber
  ) {
    if (
      RecordComparisonUtil.fieldWasChanged(newCase, oldRec, Case.Status) &&
      newCase.status == IDRConstants.REOPENED_STATUS
    ) {
      return true;
    }

    if (issueNumber == 1) {
      return (RecordComparisonUtil.fieldWasChanged(
        newCase,
        oldRec,
        Case.Status
      ) &&
      RecordComparisonUtil.fieldWasChanged(newCase, oldRec, Case.Type) &&
      IDRConstants.STATUS_STOP_COLLECTIONS.contains(newCase.Status));
    }

    if (issueNumber == 2) {
      return (RecordComparisonUtil.fieldWasChanged(
        newCase,
        oldRec,
        Case.Status
      ) &&
      RecordComparisonUtil.fieldWasChanged(
        newCase,
        oldRec,
        Case.IDR_Issue_Type_2__c
      ) &&
      IDRConstants.STATUS_STOP_COLLECTIONS.contains(newCase.Status));
    }
    if (issueNumber == 3) {
      return (RecordComparisonUtil.fieldWasChanged(
        newCase,
        oldRec,
        Case.Status
      ) &&
      RecordComparisonUtil.fieldWasChanged(
        newCase,
        oldRec,
        Case.IDR_Issue_Type_3__c
      ) &&
      IDRConstants.STATUS_STOP_COLLECTIONS.contains(newCase.Status));
    }
    return false;
  }
}
