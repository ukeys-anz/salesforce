/**
 * @author Boobalakrishnan Duraisamy
 * @since 05/2021
 * @description  IDRComplaintFlagActions class is used to publish complaint flag event during case creation and closure.
 * @group IDR(Internal Dispute Resolution)
 */
@SuppressWarnings('PMD.ApexCRUDViolation,PMD.StdCyclomaticComplexity')
public with sharing class IDRComplaintFlagActions {
  private static final String ADD_COMPLAINT_TASK_SUBJECT = 'Add Complaint event is triggered from Salesforce';

  private static final String REMOVE_COMPLAINT_TASK_SUBJECT = 'Remove Complaint event is triggered from Salesforce';

  private static Set<String> existCustNumbers = new Set<String>();

  private static Boolean isComplaintEventFailed = false;

  private static List<IDR_Complaints_Event__e> complaintEventList = new List<IDR_Complaints_Event__e>();

  private static List<Task> complaintTaskList = new List<Task>();

  /**
   * @description method to publish complaints event flag to downstreams systems whenever the complaint is created and closed.
   * @param records List of Case records in current  trigger context
   * @param oldMap old Map of Case records in current  trigger context
   */
  @SuppressWarnings('PMD.StdCyclomaticComplexity, PMD.CyclomaticComplexity')
  public static void setComplaintsFlag(
    List<Case> records,
    Map<Id, SObject> oldMap
  ) {
    List<String> customerNumbers = new List<String>();
    List<Id> caseIds = new List<Id>();

    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      if (
        rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID &&
        (oldRec == null || (rec.isClosed && !oldRec.isClosed))
      ) {
        customerNumbers.add(rec.IDR_Customer_Number__c);
        caseIds.add(rec.Id);
      }
    }
    getExistingCustNumbers(customerNumbers, caseIds);

    for (Case rec : records) {
      Case oldRec = (oldMap != null ? (Case) oldMap.get(rec.Id) : null);
      validateComplaintFlag(rec, oldRec);
    }

    if (!complaintEventList.isEmpty()) {
      publishComplaintEvent(complaintEventList);
      complaintEventList.clear();
    }

    if (!isComplaintEventFailed && !complaintTaskList.isEmpty()) {
      IDRCollectionActions.insertSystemTasks(complaintTaskList);
      complaintTaskList.clear();
    }
  }

  /**
   * @description method to check if the case record has open complaint in the system
   * @param customerNumbers List of customer numbers from complaint records
   * @param caseIds list of case ids from complaint records
   */
  private static void getExistingCustNumbers(
    List<String> customerNumbers,
    List<Id> caseIds
  ) {
    for (Case existingCase : [
      SELECT Id, IDR_Customer_Number__c
      FROM Case
      WHERE
        isClosed = FALSE
        AND IDR_Customer_Number__c IN :customerNumbers
        AND Id NOT IN :caseIds
    ]) {
      existCustNumbers.add(existingCase.IDR_Customer_Number__c);
    }
  }

  /**
   * @description method to validate whether the complaint record is eligible for complaint flag event.
   * @param rec current record from trigger
   * @param oldRec old record from trigger
   */
  private static void validateComplaintFlag(Case rec, Case oldRec) {
    if (rec.recordTypeId == IDRConstants.CUSTOMER_COMPLAINT_RT_ID) {
      if (oldRec == null) {
        complaintTaskList.add(
          IDRCollectionActions.populateSystemTask(
            rec,
            ADD_COMPLAINT_TASK_SUBJECT,
            '',
            ''
          )
        );
        complaintEventList.add(buildComplaintEvent(rec, null));
      } else if (oldRec != null && rec.isClosed && !oldRec.isClosed) {
        complaintTaskList.add(
          IDRCollectionActions.populateSystemTask(
            rec,
            REMOVE_COMPLAINT_TASK_SUBJECT,
            '',
            ''
          )
        );
        complaintEventList.add(buildComplaintEvent(rec, oldRec));
      }
    }
  }

  /**
   * @description method to populate compliant platform event fields
   * @param c case record from trigger
   * @param oldCase An old case record from trigger
   * @return Platform event record
   */
  private static IDR_Complaints_Event__e buildComplaintEvent(
    Case c,
    Case oldCase
  ) {
    IDR_Complaints_Event__e complaintEvent = new IDR_Complaints_Event__e();
    complaintEvent.IDR_Customer_Number__c = c.IDR_Customer_Number__c;
    complaintEvent.IDR_OCV_Id__c = c.OCV_Id__c; // When AR&C Customer are in SF replace this line with Account's OCV
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
    complaintEvent.IDR_Product_Updated__c = false;
    complaintEvent.IDR_Complaint_Case_Id__c = c.Id;
    complaintEvent.IDR_Product_Details__c = getProductListJson(c);
    complaintEvent.Is_Customer_Last_Complaint__c = true;
    if (existCustNumbers.contains(c.IDR_Customer_Number__c)) {
      complaintEvent.Is_Customer_Last_Complaint__c = false;
    }
    return complaintEvent;
  }

  /**
   * @description Method to return list of product details to be sent for complaint flag event
   * @param c A case record
   * @return Json String
   */
  private static String getProductListJson(Case c) {
    List<IDRComplaintProducts> complaintProductList = new List<IDRComplaintProducts>();

    if (IDRCollectionActions.productNameMap.containsKey(c.Product__c)) {
      complaintProductList.add(
        new IDRComplaintProducts(
          c.Type,
          IDRCollectionActions.productNameMap.get(c.Product__c).Name
        )
      );
    }
    if (
      c.IDR_Second_Issue__c &&
      IDRCollectionActions.productNameMap.containsKey(c.IDR_Product_2__c)
    ) {
      complaintProductList.add(
        new IDRComplaintProducts(
          c.IDR_Issue_Type_2__c,
          IDRCollectionActions.productNameMap.get(c.IDR_Product_2__c).Name
        )
      );
    }

    if (
      c.IDR_Third_Issue__c &&
      IDRCollectionActions.productNameMap.containsKey(c.IDR_Product_3__c)
    ) {
      complaintProductList.add(
        new IDRComplaintProducts(
          c.IDR_Issue_Type_3__c,
          IDRCollectionActions.productNameMap.get(c.IDR_Product_3__c).Name
        )
      );
    }

    return Json.serialize(complaintProductList);
  }

  /**
   * @description method to publish complaint event and handle errors
   * @param complaintEventList List of complaint events
   */
  private static void publishComplaintEvent(
    List<IDR_Complaints_Event__e> complaintEventList
  ) {
    List<Database.SaveResult> publishResults = EventBus.publish(
      complaintEventList
    );
    for (Integer i = 0; i < publishResults.size(); i++) {
      if (!publishResults[i].isSuccess()) {
        isComplaintEventFailed = true;
      }
    }
    Lib_SystemLog log = new Lib_SystemLog(
      IDRComplaintFlagActions.class.getName(),
      'publishComplaintEvent'
    );
    log.addDatabaseSaveResult(
      'IDR_Complaints_Event__e',
      publishResults,
      complaintEventList
    );
    log.insertLogAsync();
  }
}
